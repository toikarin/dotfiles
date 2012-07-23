import os
import shutil

def create_installer_from_parser_opts(data_root):
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-n", "--no-dry-run", action="store_false", default=True, dest="dryrun", help="Don't do a dry run.")
    parser.add_option("-d", "--destination", default="~/", dest="dest", help="Destination directory.")
    parser.add_option("-v", "--verbosity-level", type="int", default=2, dest="verbosity", help="Be more verbose.")

    (opts, args) = parser.parse_args()
    return Installer(data_root=data_root, dest_root=opts.dest, dry_run=opts.dryrun, verbosity=opts.verbosity)


class Installer(object):
    def __init__(self, data_root, dest_root, dry_run, verbosity):
        self.data_root = data_root
        self.destination_root = os.path.expanduser(dest_root)
        self.dry_run = dry_run
        self.verbosity = verbosity

        if not os.path.exists(self.destination_root):
            self.create_directory("")

    def _log(self, msg, level):
        if self.verbosity >= level:
            print(msg)

    def create_directory(self, target):
        dst = self._d(target)

        if not os.path.exists(dst):
            self._log("Making directories for {dest}.".format(dest=dst), 1)

            if not self.dry_run:
                os.makedirs(dst)

    def create_symlink(self, source, target=None):
        if not target:
            target = source

        src = self._s(source)
        dst = self._d(target)

        if os.path.exists(dst):
            if os.path.islink(dst):
                link = os.readlink(dst)
                abs_link = link if os.path.isabs(link) else self._d(link)

                if abs_link == src:
                    self._log("Not installing file '{dest}' because identical symlink already exists.".format(dest=dst), 3)
                    return

            bu_dst = self._find_free_fn(dst)
            self._log("Renaming '{src}' to '{dest}'.".format(src=dst, dest=bu_dst), 1)
            if not self.dry_run:
                os.rename(dst, bu_dst)

        self._log("Creating symlink from '{src}' to '{dest}'.".format(src=src, dest=dst), 1)

        if not self.dry_run:
            os.symlink(src, dst)

    def create_copy(self, source, target=None):
        if not target:
            target = source

        src = self._s(source)
        dst = self._d(target)

        if os.path.exists(dst):
            bu_dst = self._find_free_fn(dst)
            self._log("Renaming '{src}' to '{dest}'.".format(src=dst, dest=bu_dst), 1)
            if not self.dry_run:
                os.rename(dst, bu_dst)

        self._log("Copying '{src}' to '{dest}'.".format(src=src, dest=dst), 1)

        if not self.dry_run:
            shutil.copyfile(src, dst)

    def create_file(self, target):
        dst = self._d(target)

        if os.path.exists(dst):
            return

        self._log("Creating empty file '{dest}'.".format(dest=dst), 1)

        if not self.dry_run:
            with open(dst, 'a'):
                pass

    def _s(self, f):
        return os.path.abspath(os.path.join(self.data_root, f))

    def _d(self, f):
        return os.path.abspath(os.path.join(self.destination_root, f))

    def _find_free_fn(self, target):
        target = target + ".bu"

        if not os.path.exists(target):
            return target

        i = 1
        while True:
            fn = "{filename}-{num}".format(filename=target, num=i)
            if os.path.exists(fn):
                i += 1
            else:
                return fn

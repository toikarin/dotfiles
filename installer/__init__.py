import os
import shutil

def create_installer_from_parser_opts(data_root):
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-n", "--no-dry-run", action="store_false", default=True, dest="dryrun", help="Don't do a dry run.")
    parser.add_option("-d", "--destination", default="~/", dest="dest", help="Destination directory.")

    (opts, args) = parser.parse_args()
    return Installer(data_root=data_root, dest_root=opts.dest, dry_run=opts.dryrun)


class Installer(object):
    def __init__(self, data_root, dest_root, dry_run=True):
        self.data_root = data_root
        self.destination_root = os.path.expanduser(dest_root)
        self.dry_run = dry_run

        if not os.path.exists(self.destination_root):
            self.create_directory("")

    def set_real_run(self):
        self.dy_run = False

    def create_directory(self, target):
        dst = self._d(target)

        if not os.path.exists(dst):
            print "Making directories for %s" % dst

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
                    print "Not installing file '%s' because identical symlink already exists." % src
                    return

            bu_dst = self._find_free_fn(dst)
            print "Renaming '%s' to '%s'." % (dst, bu_dst)
            if not self.dry_run:
                os.rename(dst, bu_dst)

        print "Creating symlink from '%s' to '%s'." % (src, dst)

        if not self.dry_run:
            os.symlink(src, dst)

    def create_copy(self, source, target=None):
        if not target:
            target = source

        src = self._s(source)
        dst = self._d(target)

        if os.path.exists(dst):
            bu_dst = self._find_free_fn(dst)
            print "Renaming '%s' to '%s'." % (dst, bu_dst)
            if not self.dry_run:
                os.rename(dst, bu_dst)

        print "Copying '%s' to '%s'." % (src, dst)

        if not self.dry_run:
            shutil.copyfile(src, dst)

    def touch(self, target):
        dst = self._d(target)

        print "Touching '%s'." % dst

        if not self.dry_run:
            with open(dst, 'a'):
                os.utime(dst, None)

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
            fn = "%s-%s" % (target, i)
            if os.path.exists(fn):
                i += 1
            else:
                return fn

import os
import shutil
import subprocess
import sys


def create_installer_from_parser_opts(data_root):
    from optparse import OptionParser
    parser = OptionParser()
    parser.add_option("-n", "--no-dry-run", action="store_false", default=True, dest="dryrun", help="Don't do a dry run.")
    parser.add_option("-d", "--destination", default="~/", dest="dest", help="Destination directory.")
    parser.add_option("-v", "--verbosity-level", type="int", default=2, dest="verbosity", help="Be more verbose.")
    parser.add_option("--vim", action="store_false", default=True, help="Skip vim install")
    parser.add_option("--bin", action="store_false", default=True, help="Skip bin utils")
    parser.add_option("--bash", action="store_false", default=True, help="Skip bash files")
    parser.add_option("--mutt", action="store_false", default=True, help="Skip mutt files")
    parser.add_option("--i3", action="store_false", default=True, help="Skip i3 files")
    parser.add_option("--X", action="store_false", default=True, help="Skip X files")
    parser.add_option("--git", action="store_false", default=True, help="Skip git files")
    parser.add_option("--screen", action="store_false", default=True, help="Skip screen files")
    parser.add_option("--vimperator", action="store_false", default=True, help="Skip vimperator files")
    parser.add_option("--pentadactyl", action="store_false", default=True, help="Skip pentadactyl files")
    parser.add_option("--cmus", action="store_false", default=True, help="Skip cmus files")
    
    (opts, args) = parser.parse_args()
    return Installer(data_root=data_root, dest_root=opts.dest, dry_run=opts.dryrun, verbosity=opts.verbosity), opts


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

    def create_directory(self, target, skip=False):
        if skip:
            self._log("Skipping create directory '{target}'".format(target=target), 1)
            return
        
        dst = self._d(target)

        if not os.path.exists(dst):
            self._log("Making directories for {dest}.".format(dest=dst), 1)

            if not self.dry_run:
                os.makedirs(dst)

    def create_symlink(self, source, target=None, skip=False):
        if skip:
            self._log("Skipping create symlink '{source}'".format(source=source), 1)
            return
        
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

    def create_file(self, target, skip=False):
        if skip:
            self._log("Skipping create file '{target}'".format(target=target), 1)
            return
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


def git_submodule_init(verbosity):
    _call(["git", "submodule", "init"], verbosity)


def git_submodule_update(verbosity):
    _call(["git", "submodule", "update"], verbosity)


def _call(args, verbosity):
    with open(os.devnull, 'w') as devnull:
        stdout = sys.stdout if verbosity >= 3 else devnull
        subprocess.call(args, stdout=stdout)

import os
import shutil
import subprocess
import sys
import platform
import contextlib
import re


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
        self._aptget_update_run = False

        if not os.path.exists(self.destination_root):
            self.create_directory("")

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

    def install_package(self, target, freebsd=None, freebsd_cat=None, debian=None):
        if sys.platform.startswith('freebsd'):
            if freebsd is not False and freebsd_cat:
                self._install_package_freebsd(target if freebsd is None else freebsd, freebsd_cat)
        elif sys.platform.startswith('linux'):
            if platform.linux_distribution()[0] == 'debian':
                if debian is not False:
                    self._install_package_debian(target if debian is None else debian)
            else:
                self._log("Unknown distribution {dist}. Unable to install package {pkg}.".format(dist=platform.linux_distribution()[0], pkg=target))

    def _package_installed_debian(self, target):
        code, out, err = self._execute("apt-cache", "policy", target)
        if code != 0:
            self._log("error: {err}".format(err=err), 1)
            return

        for line in out.splitlines():
            m = re.match("\s\sInstalled: (.+)$", line)
            if m:
                return m.group(1) != "(none)"

        self._log("error: unable to check if package {pkg} is installed".format(pkg=target), 1)
        return False

    def _install_package_debian(self, target):
        if self._package_installed_debian(target):
            return

        self._log("Installing package '{pkg}' via apt-get.".format(pkg=target), 1)

        if not self.dry_run:
            # Run apt-get update (once)
            if not self._aptget_update_run:
                code, out, err = self._execute("sudo", "apt-get", "-q", "update")
                if code != 0:
                    self._log("error: {err}".format(err=err), 1)
                    return

                self._aptget_update_run = True

            code, out, err = self._execute("sudo", "apt-get", "install", "-q", "-y", target)
            if code != 0:
                self._log("error: {err}".format(err=err), 1)

    def _install_package_freebsd(self, target, category):
        package = target + "/" + category

        code, out, _ = self._execute("pkg", "version", "-e", package)
        if code != 0:
            self._log("error", 1)
            return

        # check if installed
        if out != "":
            return

        self._log("Installing package '{pkg}' via ports.".format(pkg=package), 1)

        if not self.dry_run:
            with chdir(os.path.join("/usr/ports", package)):
                code, out, err = self._execute("sudo", "make", "install", "BATCH=yes")
                if code != 0:
                    self._log("error: {err}".format(err=err), 1)

    def _log(self, msg, level):
        if self.verbosity >= level:
            print(msg)

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


    def git_submodule_init(self):
        self._call(["git", "submodule", "init"])

    def git_submodule_update(self):
        self._call(["git", "submodule", "update"])

    def _call(self, args):
        _, out, err = self._execute(*args)
        self._log(out, 3)

    def _execute(self, *args):
        proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        exitcode = proc.returncode

        return exitcode, out, err


@contextlib.contextmanager
def chdir(path):
    old_dir = os.getcwd()
    os.chdir(path)
    yield
    os.chdir(old_dir)

#!/usr/bin/env python

import installer
import os

script_dir = os.path.dirname(os.path.realpath(__file__))
i = installer.create_installer_from_parser_opts(script_dir)

if i.dry_run:
    print
    print "Doing dry-run. Nothing is installed. Use -n flag to do real installation if everything looks ok."
    print

i.create_symlink(".gitconfig")
i.create_symlink(".git-excludes")
i.create_symlink(".pentadactylrc")
i.create_symlink(".screenrc")
i.create_symlink(".vim")
i.create_symlink(".vimrc")

i.create_symlink(".bashrc")
i.create_symlink(".bash_aliases")
i.create_symlink(".bash_bindings")
i.create_symlink(".bash_completion")
i.create_symlink(".bash_functions")
i.create_symlink(".bash_prompt")
i.create_symlink(".bash_exports.tmpl")

i.create_directory("bin")
i.create_symlink("bin/find-parent-dir")
i.create_symlink("bin/wminit.sh")

i.create_directory(".i3")
i.create_symlink(".i3-config", ".i3/config")

#!/usr/bin/env python

from __future__ import print_function

import installer
import os

script_dir = os.path.dirname(os.path.realpath(__file__))
i = installer.create_installer_from_parser_opts(script_dir)

if i.dry_run and i.verbosity >= 2:
    print("")
    print("Doing dry-run. Nothing is installed. Use -n flag to do real installation if everything looks ok.")
    print("")

i.create_symlink(".git-hook-post-receive", os.path.join(script_dir, ".git", "hooks", "post-receive"))

i.create_symlink(".gitconfig")
i.create_symlink(".git-excludes")
i.create_symlink(".pentadactylrc")
i.create_symlink(".vimperatorrc")
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
i.create_symlink("bin/mntusb")
i.create_symlink("bin/umntusb")
i.create_symlink("bin/i3-change-layout.sh")
i.create_symlink("bin/my_dmenu_run")
i.create_symlink("bin/screenshot")

i.create_symlink(".muttrc")
i.create_symlink(".mutt_sidebar.tmpl")
i.create_symlink(".mutt_mailboxes.tmpl")
i.create_symlink(".mutt_sensitive.tmpl")
i.create_file(".mutt_aliases")
i.create_file(".mutt_mailboxes")
i.create_file(".mutt_sidebar")

i.create_symlink(".Xmodmap")
i.create_symlink(".Xresources")

i.create_directory(".i3")
i.create_symlink(".i3-config", ".i3/config")
i.create_symlink(".i3status.conf")

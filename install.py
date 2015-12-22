#!/usr/bin/env python

from __future__ import print_function

import installer
import os

script_dir = os.path.dirname(os.path.realpath(__file__))
i, opts = installer.create_installer_from_parser_opts(script_dir)

if i.verbosity >= 3:
    print("Initializing git submodules.")
installer.git_submodule_init(i.verbosity)

if i.verbosity >= 3:
    print("Updating git submodules.")
installer.git_submodule_update(i.verbosity)

if i.dry_run and i.verbosity >= 2:
    print("")
    print("Doing dry-run. Nothing is installed. Use -n flag to do real installation if everything looks ok.")
    print("")

i.create_symlink(".git-hook-post-receive", os.path.join(script_dir, ".git", "hooks", "post-receive"), skip=not opts.git)

i.create_symlink(".gitconfig", skip=not opts.git)
i.create_symlink(".git-excludes", skip=not opts.git)
i.create_symlink(".pentadactylrc", skip=not opts.pentadactyl)
i.create_symlink(".vimperatorrc", skip=not opts.vimperator)
i.create_symlink(".screenrc", skip=not opts.screen)
i.create_symlink(".vim", skip=not opts.vim)
i.create_symlink(".vimrc", skip=not opts.vim)

i.create_directory(".cmus", skip=not opts.cmus)
i.create_symlink(".cmus-rc", ".cmus/rc", skip=not opts.cmus)
exit
i.create_symlink(".bashrc", skip=not opts.bash)
i.create_symlink(".bash_profile", skip=not opts.bash)
i.create_symlink(".bash_aliases", skip=not opts.bash)
i.create_symlink(".bash_bindings", skip=not opts.bash)
i.create_symlink(".bash_completion", skip=not opts.bash)
i.create_symlink(".bash_functions", skip=not opts.bash)
i.create_symlink(".bash_prompt", skip=not opts.bash)
i.create_symlink(".bash_exports.tmpl", skip=not opts.bash)
i.create_symlink(".bash_cdable.tmpl", skip=not opts.bash)

i.create_directory("bin", skip=not opts.bin)
i.create_symlink("bin/find-parent-dir", skip=not opts.bin)
i.create_symlink("bin/wminit.sh", skip=not opts.bin)
i.create_symlink("bin/mntusb", skip=not opts.bin)
i.create_symlink("bin/umntusb", skip=not opts.bin)
i.create_symlink("bin/i3-change-layout.sh", skip=not opts.bin)
i.create_symlink("bin/my_dmenu_run", skip=not opts.bin)
i.create_symlink("bin/screenshot", skip=not opts.bin)
i.create_symlink("bin/py-ical-view.py", skip=not opts.bin)
i.create_symlink("bin/git-check-is-master-branch", skip=not opts.bin)

i.create_symlink(".muttrc", skip=not opts.mutt)
i.create_symlink(".mutt_sidebar.tmpl", skip=not opts.mutt)
i.create_symlink(".mutt_mailboxes.tmpl", skip=not opts.mutt)
i.create_symlink(".mutt_sensitive.tmpl", skip=not opts.mutt)
i.create_file(".mutt_sensitive", skip=not opts.mutt)
i.create_file(".mutt_aliases", skip=not opts.mutt)
i.create_file(".mutt_mailboxes", skip=not opts.mutt)
i.create_file(".mutt_sidebar", skip=not opts.mutt)
i.create_symlink(".mailcap", skip=not opts.mutt)

i.create_symlink(".Xmodmap", skip=not opts.X)
i.create_symlink(".Xresources", skip=not opts.X)

i.create_directory(".i3", skip=not opts.i3)
i.create_symlink(".i3-config", ".i3/config", skip=not opts.i3)
i.create_symlink(".i3status.conf", skip=not opts.i3)

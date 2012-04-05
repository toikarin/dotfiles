#!/usr/bin/env bash

# Backup directory
function budir {
   date_bin="/bin/date"
   cp_bin="/bin/cp"
   basename_bin="/usr/bin/basename"

   date=`$date_bin +%d%m%y-%H%M%S`
   dest_suffix=""
   suffix_counter=0

   len="${#1}"

   if [ "$len" -eq "0" ];
   then
      echo "Usage: budir DIRECTORY"
   else
      basename=`$basename_bin $1`
      dest_prefix="$basename.$date"
      dest_found=0

      # Loop until dest directory doesn't exists
      while [ $dest_found == 0 ]
      do
         dest=$dest_prefix$dest_suffix

         if [ -e $dest ];
         then
            let suffix_counter++
            dest_suffix="-"$suffix_counter
         else
            dest_found=1
         fi
      done

      echo "Copying $1 to $dest"

      $cp_bin -r $1 $dest
   fi
}

# Call bc with arguments
function bcc {
   bc_bin=$(which bc)

   echo "scale=5; $@" | $bc_bin -l
}

# Reminder to use sudoedit instead of sudo vim
function sudo {
   if [ "$1" == "vim" ]; then
      echo "Use sudoedit instead."
      return 1
   fi

   sudo_bin=$(which sudo)
   $sudo_bin $@
}

# Show cdable directories
function cdable {
   local cdable_file="$HOME/.bash_cdable"
   local grep_bin=$(which grep)
   local awk_bin=$(which awk)

   if [ -f $cdable_file ]; then
      $grep_bin "export" $cdable_file | $awk_bin '{print $2}'
   else
      echo "File '$cdable_file' doesn't exist."
   fi
}

# Open browser
function ob {
   if [ "${1:0:1}" == "/" ]; then
      x-www-browser "$@"
   else
      x-www-browser "$(pwd)/$@"
   fi
}

# Find java classes by name
function fj {
   local find_bin=$(which find)
   $find_bin . -iname "$1*.java"
}

# Find java classes by name and open them in vim
function fjv {
   local find_bin=$(which find)
   local vim_bin=$(which vim)

   $find_bin . -iname "$1*.java" -exec "${vim_bin}" {} +
}

# Compare file to stdout with vimdiff.
function vimdifff() {
   local vim_bin=$(which vim)

   $vim_bin - -c ":vnew $1 | windo diffthis"
}

# Extract file
function e()
{
   local file=$1
   local list=0

   if [ -z "${file}" ]; then
      return 1
   fi

   if [ "$1" == "-t" ]; then
      if [ -z $2 ]; then
         return 1
      else
         list=1
         file=$2
      fi
   else
      file=$1
      list=0
   fi

   if [ -f "${file}" ] ; then
      if [ ${list} -eq 0 ]; then
         case "${file}" in
            *.7z)                  7zr e "${file}"        ;;
            *.tar.bz2 | *.tbz2)    tar xvjf "${file}"     ;;
            *.tar.gz | *.tgz)      tar xvzf "${file}"     ;;
            *.tar)                 tar xvf "${file}"      ;;
            *.bz2)                 bunzip2 "${file}"      ;;
            *.gz)                  gunzip "${file}"       ;;
            *.rar | *.r00)         unrar x "${file}"      ;;
            *.zip)                 unzip "${file}"        ;;
            *.jar | *.ear | *.war) jar -vxf "${file}"     ;;
            *)           echo "Don't know how to extract file '${file}'" ;;
         esac
      else
         case "${file}" in
            *.7z)                  7zr l "${file}"        ;;
            *.tar.bz2 | *.tbz2)    tar tvjf "${file}"     ;;
            *.tar.gz | *.tgz)      tar tvzf "${file}"     ;;
            *.tar)                 tar tvf "${file}"      ;;
            *.rar | *.r00)         unrar l "${file}"      ;;
            *.zip)                 unzip -l "${file}"     ;;
            *.jar | *.ear | *.war) jar -vtf "${file}"     ;;
            *)           echo "Don't know how to list files from '${file}'" ;;
         esac
      fi
   else
      echo "'${file}' is not a valid file."
      return 1
   fi
}


function c() {
   local file=$1
   shift

   case "${file}" in
      *.jar | *.ear | *.war) jar -vcf "${file}" "$@"      ;;
      *.7z)                  7zr a "${file}" "$@"         ;;
      *.tar.bz2 | *.tbz2)    tar cvjf "${file}" "$@"      ;;
      *.tar.gz | *.tgz)      tar cvzf "${file}" "$@"      ;;
      *.bz2)                 cat "$@" | bzip2 > "${file}" ;;
      *.gz)                  cat "$@" | gzip > "${file}"  ;;
      *.tar)                 tar cvf "${file}" "$@"       ;;
      *.rar)                 rar a "${file}" "$@"         ;;
      *.zip)                 zip -r "${file}" "$@"        ;;
      *)           echo "Don't know how to compress to file '${file}'" ;;
   esac
}


# Change keyboard layout between us and finnish
function change_layout() {
   local SETXKBMAP_BIN=$(which setxkbmap)
   local XMODMAP_BIN=$(which xmodmap)
   local GREP_BIN=$(which grep)
   local AWK_BIN=$(which awk)
   local new_layout=${1:-""}

   if [ "$new_layout" == "" ]; then
      local cur_layout=$($SETXKBMAP_BIN -print | $GREP_BIN "xkb_symbols" | $AWK_BIN '{ print $4 }' | $AWK_BIN -F"+" '{print $2}')

      if [ "$cur_layout" != "us" ]; then
         new_layout="us"
      else
         new_layout="fi"
      fi
   fi

   $SETXKBMAP_BIN -layout $new_layout
   $XMODMAP_BIN ~/.Xmodmap
   echo "Current layout: ${new_layout}"
}

function touchpad_initial_state() {
   if [ "${BS_TOUCHPAD_INIT_STATE}" == "off" ]; then
      touchpad_disable
   elif [ "${BS_TOUCHPAD_INIT_STATE}" == "on" ]; then
      touchpad_enable
   fi
}

function touchpad_check_usb_mouse() {
   if [ "${BS_USB_MOUSES}" == "" ]; then
      return
   fi

   OLD_IFS=$IFS
   IFS=',' read -ra MOUSES <<< "$BS_USB_MOUSES"
   IFS=$OLD_IFS

   for mouse in "${MOUSES[@]}"
   do
      lsusb -d "${mouse}" > /dev/null
      if [ $? -eq 0 ]; then
         touchpad_disable
         return
      fi
   done

   touchpad_enable
}

function touchpad_disable() {
   synclient TouchpadOff=1
}

function touchpad_enable() {
   synclient TouchpadOff=0
}

function touchpad_toggle() {
   local cur_state=$(synclient -l | grep "TouchpadOff" | awk '{ print $3 }')
   local new_state=""

   if [ "${cur_state}" == "1" ]; then
      new_state="0"
   else
      new_state="1"
   fi

   synclient TouchpadOff=${new_state}
}

function set_resolutions() {
   if [ "$BS_DEFAULT_MONITOR" == "" ]; then
      echo "export BS_DEFAULT_MONITOR missing."
      return
   fi

   local def_mon="${BS_DEFAULT_MONITOR}"
   local def_res="$(xrandr | grep -A1 """${def_mon} connected""" | tail -1 | cut -f4 -d' ')"
   local other_connected_mon="$(xrandr | grep ' connected' | grep -v "${def_mon}" | cut -f1 -d' ')"
   local disconnected_ports=( $(xrandr | grep ' disconnected' | cut -f1 -d' ') )

   local other_mon_str=""
   local off_str=""
   local sec_mon_pos=${BS_SECOND_MONITOR_POS:-"right"}

   for port in ${disconnected_ports[@]}
   do
      off_str="${off_str} --output ${port} --off"
   done

   if [ "${other_connected_mon}" != "" ]; then
      local other_res="$(xrandr | grep -A1 """${other_connected_mon} connected""" | tail -1 | cut -f4 -d' ')"

      other_mon_str="--output ${other_connected_mon} --mode ${other_res} --${sec_mon_pos}-of ${def_mon}"
   fi

   echo "Primary monitor (${def_mon}): ${def_res}"
   if [ "${other_connected_mon}" != "" ]; then
      echo "Secondary monitor (${other_connected_mon}): ${other_res} pos: ${sec_mon_pos}"
   fi

   xrandr --output ${def_mon} --mode ${def_res} --primary ${other_mon_str} ${off_str}
}

# Tar gz directory
function tard {
   local dir=$1
   local TAR_BIN=$(which tar)

   if [ "${#1}" -eq 0 ];
   then
      echo "Usage: tard <directory>"
      return 1
   fi

   $TAR_BIN -czf "$1.tar.gz" "$1"
}

# Clear tmp directory
function clean_tmp_dirs {
   local delete=${1:-""}

   local tmp_dir=$HOME/tmp
   local download_dir=$HOME/downloads

   clean_directory "$tmp_dir" "$1"
   clean_directory "$download_dir" "$1"
}

# Clean directory from old files and empty directories
function clean_directory {
   local dir=$1
   local delete=${2:-""}
   local delete_param=""

   if [ "${#1}" -eq 0 ];
   then
      echo "Usage: clean_directory <directory> [-delete]"
      return 1
   fi

   if [ ! -d "$dir" ]; then
      return 1
   fi

   if [ "$delete" == "-delete" ]; then
      delete_param="-delete"
   fi

   # Remove files that has not been modified in last 30 days
   find "$dir" -type f -mtime +30 ${delete_param}
   # Remove all empty directories
   find "$dir" -mindepth 1 -type d -empty ${delete_param}
}

function clean_empty_svn_dirs {
   for directory in $(find . -type d ! -path "*.svn*")
   do
      filecount=$(find "${directory}" -type f ! -path "*.svn*" | wc -l)

      if [ "$filecount" -eq 0 ];
      then
         svn rm "${directory}"
      fi
   done
}

function fileswap {
   local file_1=$1
   local file_2=$2

   if [[ -z "${file_1}" || -z "${file_2}" ]]; then
      echo "Usage: fileswap <file1> <file2>"
      return 1
   fi

   if [ ! -e "${file_1}" ]; then
      echo "File '${file_1}' doesn't exists."
      return 1
   fi

   if [ ! -e "${file_2}" ]; then
      echo "File '${file_2}' doesn't exists."
      return 1
   fi

   tmp=$(mktemp)

   mv "$file_1" "$tmp"
   mv "$file_2" "$file_1"
   mv "$tmp" "$file_2"
}

function dclean {
   sudo apt-get -y autoremove
   dpkg -l | grep "^rc" | awk '{ print $2 }' | xargs sudo apt-get -y purge
   dpkg -l | grep "^rc" | awk '{ print $2 }' | xargs --no-run-if-empty sudo dpkg --purge
   sudo apt-get -y clean
}

function smv {
   local local_file=$1
   shift

   scp "${local_file}" $@ && rm "${local_file}"
}

showimage() {
   local file=$1
   local w3mimgdisplay="/usr/lib/w3m/w3mimgdisplay"
   local thumbnail="/tmp/shell-thumb"

   if [ -z "${file}" ]; then
      echo "Usage: showimage <file>"
      return 1
   fi

   type -P "${w3mimgdisplay}" &> /dev/null || {
      echo "w3mimgdisplay not installed."
      echo ""
      echo "Use 'apt-get install w3m-img' to install."
      return 1
   }

   type -P convert &> /dev/null || {
      echo "imagemagick not installed."
      echo ""
      echo "Use 'apt-get install imagemagick' to install."
      return 1
   }

   convert -thumbnail x200 "${file}" "${thumbnail}"
   echo -e "2;3;\n0;1;0;0;0;0;0;0;0;0;${thumbnail}\n4;\n3;" | "${w3mimgdisplay}"
}

# Reload bash configuration
function reload() {
   load_file ~/.bashrc
}

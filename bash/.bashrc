#
# ~/.bashrc
#

# for using ble.sh
source /usr/share/blesh/ble.sh --noattach

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# load .bashrc.d files
for file in ~/.bashrc.d/*.sh;
do
  source "$file"
done

# attach ble.sh
[[ ${BLE_VERSION-} ]] && ble-attach


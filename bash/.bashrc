#
# ~/.bashrc
#
# Bash Line Editor (ble.sh)
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ -f /usr/share/blesh/ble.sh ]]; then
    # Arch Linux path (via AUR)
    source /usr/share/blesh/ble.sh --noattach
elif [[ "$OSTYPE" == "darwin"* ]] && [[ -f ~/.local/share/blesh/ble.sh ]]; then
    # macOS manual build path
    source ~/.local/share/blesh/ble.sh --noattach
fi

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# load .bashrc.d files
for file in ~/.bashrc.d/*.sh;
do
  source "$file"
done

# attach ble.sh
[[ ${BLE_VERSION-} ]] && ble-attach


# uv
export PATH="$HOME/.local/bin:$PATH"

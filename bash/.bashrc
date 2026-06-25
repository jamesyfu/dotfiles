#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# load .bashrc.d files
for file in ~/.bashrc.d/*.sh;
do
  source "$file"
done

# uv
export PATH="/home/james/.local/bin:$PATH"

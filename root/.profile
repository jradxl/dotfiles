# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n 2> /dev/null || true

# Created by `pipx` on 2024-02-14 17:22:49
export PATH="$PATH:/root/.local/bin"

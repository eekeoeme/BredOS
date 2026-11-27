# Start the BredOS session on tty1.
if [ -z "${WAYLAND_DISPLAY:-}" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec labwc
fi
[ -f ~/.bashrc ] && . ~/.bashrc

#!/bin/ash

echo "Preparing db files. You can get them by mounting /w-live folder."

cleanup () {
  kill -s SIGTERM $!
  exit 0
}

trap cleanup SIGINT SIGTERM

if [ ! -f /w-live/.ready ]; then
  cd /w
  find . -type f -name '*.gz' -exec gunzip "{}" \;
  mkdir -p /w-live/
  cp -r /w/* /w-live/
  touch /w-live/.ready
fi

exit 0

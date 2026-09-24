#!/bin/sh

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"
for dir in "${ZPLUGINDIR}"/*/; do
  plugin_name=${dir%/}
  echo "Updating ${plugin_name##*/}..."
  git -C "$dir" pull --ff-only
done

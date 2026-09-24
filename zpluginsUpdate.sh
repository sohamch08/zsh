
ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"
for dir in "${ZPLUGINDIR}"/*/; do
  echo "Updating ${dir:t}..."
  git -C "$dir" pull --ff-only
done

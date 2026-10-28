# =========================================================
# FZF
# =========================================================

export FZF_DEFAULT_OPS='
  --layout=reverse
  --color=fg:#908caa, hl:#ebbcba
  --color=fg+:#e0def4,bg+:#26233a,hl+:#ebbcba
  --color=border:#403d52,header:#31748f,gutter:#191724
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa
'

# Include hidden paths, while respecting ignore files and skipping dependencies/caches.
_fzf_fd_excludes='--exclude .git --exclude .hg --exclude .svn
  --exclude .venv --exclude venv --exclude node_modules --exclude __pycache__
  --exclude .cache --exclude .pytest_cache --exclude .mypy_cache
  --exclude .ruff_cache --exclude .tox --exclude .nox'
_fzf_fd_excludes=${_fzf_fd_excludes//$'\n'/ }
export FZF_CTRL_T_COMMAND="fd --type f --hidden --strip-cwd-prefix $_fzf_fd_excludes"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix $_fzf_fd_excludes"
unset _fzf_fd_excludes

export FZF_CTRL_T_OPTS="--height=60% --layout=reverse
  --preview 'bat --color=always --style=plain,numbers --line-range=:500 -- {}'
  --preview-window=right:60%:wrap"
export FZF_CTRL_R_OPTS='--height=60% --layout=reverse'
export FZF_ALT_C_OPTS="--height=60% --layout=reverse
  --preview 'eza --all --color=always --icons=always --group-directories-first -- {}'
  --preview-window=right:60%"

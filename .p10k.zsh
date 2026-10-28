# Powerlevel10k (Catppuccin Mocha)

'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases'         ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob'         ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob

  unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

  [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return

  # Prompt layout
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    os_icon
    dir
    vcs
    newline
  )

  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
    status
    background_jobs
    code
    direnv
    asdf
    virtualenv
    anaconda
    pyenv
    goenv
    nodenv
    nvm
    nodeenv
    rbenv
    rvm
    fvm
    luaenv
    jenv
    plenv
    perlbrew
    phpenv
    scalaenv
    haskell_stack
    kubecontext
    terraform
    aws_eb_env
    azure
    gcloud
    google_app_cred
    toolbox
    context
    nordvpn
    ranger
    yazi
    nnn
    lf
    xplr
    vim_shell
    midnight_commander
    nix_shell
    chezmoi_shell
    vi_mode
    todo
    timewarrior
    taskwarrior
    per_directory_history
    newline
  )

  # Appearance
  typeset -g POWERLEVEL9K_MODE=nerdfont-v3
  typeset -g POWERLEVEL9K_ICON_PADDING=moderate

  typeset -g POWERLEVEL9K_ICON_BEFORE_CONTENT=

  typeset -g POWERLEVEL9K_PROMPT_ADD_NEWLINE=true

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX='%F{#45475a}╭─'
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX='%F{#45475a}├─'
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='%F{#45475a}╰─'
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_SUFFIX=
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_SUFFIX=

  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR=' '
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_BACKGROUND=
  typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_GAP_BACKGROUND=
  if [[ $POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_CHAR != ' ' ]]; then
    typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_GAP_FOREGROUND='#45475a'
    typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_FIRST_SEGMENT_END_SYMBOL='%{%}'
    typeset -g POWERLEVEL9K_EMPTY_LINE_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='%{%}'
  fi

  typeset -g POWERLEVEL9K_BACKGROUND='#313244'

  typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR='%F{#6c7086}\uE0B1'
  typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR='%F{#6c7086}\uE0B3'
  typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR='\uE0B0'
  typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR='\uE0B2'

  typeset -g POWERLEVEL9K_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL='▓▒░'
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_FIRST_SEGMENT_START_SYMBOL='░▒▓'
  typeset -g POWERLEVEL9K_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=''
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_LAST_SEGMENT_END_SYMBOL=''
  typeset -g POWERLEVEL9K_EMPTY_LINE_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=

  # os_icon
  typeset -g POWERLEVEL9K_OS_ICON_FOREGROUND='#cdd6f4'

  # prompt_char
  typeset -g POWERLEVEL9K_PROMPT_CHAR_BACKGROUND=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND='#eba0ac'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIINS_CONTENT_EXPANSION='❯'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VICMD_CONTENT_EXPANSION='❮'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIVIS_CONTENT_EXPANSION='V'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_{OK,ERROR}_VIOWR_CONTENT_EXPANSION='▶'
  typeset -g POWERLEVEL9K_PROMPT_CHAR_OVERWRITE_STATE=true
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_LAST_SEGMENT_END_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_PROMPT_FIRST_SEGMENT_START_SYMBOL=
  typeset -g POWERLEVEL9K_PROMPT_CHAR_LEFT_{LEFT,RIGHT}_WHITESPACE=

  # dir
  typeset -g POWERLEVEL9K_DIR_FOREGROUND='#b4befe'
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_SHORTEN_DELIMITER=
  typeset -g POWERLEVEL9K_DIR_SHORTENED_FOREGROUND='#bac2de'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_FOREGROUND='#b4befe'
  typeset -g POWERLEVEL9K_DIR_ANCHOR_BOLD=true
  local anchor_files=(
    .bzr
    .citc
    .git
    .hg
    .node-version
    .python-version
    .go-version
    .ruby-version
    .lua-version
    .java-version
    .perl-version
    .php-version
    .tool-versions
    .mise.toml
    .shorten_folder_marker
    .svn
    .terraform
    CVS
    Cargo.toml
    composer.json
    go.mod
    package.json
    stack.yaml
  )
  typeset -g POWERLEVEL9K_SHORTEN_FOLDER_MARKER="(${(j:|:)anchor_files})"
  typeset -g POWERLEVEL9K_DIR_TRUNCATE_BEFORE_MARKER=false
  typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
  typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=80
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS=40
  typeset -g POWERLEVEL9K_DIR_MIN_COMMAND_COLUMNS_PCT=50
  typeset -g POWERLEVEL9K_DIR_HYPERLINK=false

  typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=v3

  # vcs
  typeset -g POWERLEVEL9K_VCS_BRANCH_ICON='\uF126 '

  typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'

  function my_git_formatter() {
    emulate -L zsh

    if [[ -n $P9K_CONTENT ]]; then
      typeset -g my_git_format=$P9K_CONTENT
      return
    fi

    if (( $1 )); then
      local       meta='%F{#cba6f7}'
      local      clean='%F{#cba6f7}'
      local   modified='%F{#f9e2af}'
      local  untracked='%F{#89b4fa}'
      local conflicted='%F{#f38ba8}'
    else
      local       meta='%F{#9399b2}'
      local      clean='%F{#9399b2}'
      local   modified='%F{#9399b2}'
      local  untracked='%F{#9399b2}'
      local conflicted='%F{#9399b2}'
    fi

    local res

    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
      local branch=${(V)VCS_STATUS_LOCAL_BRANCH}
      (( $#branch > 32 )) && branch[13,-13]="…"
      res+="${clean}${(g::)POWERLEVEL9K_VCS_BRANCH_ICON}${branch//\%/%%}"
    fi

    if [[ -n $VCS_STATUS_TAG
          && -z $VCS_STATUS_LOCAL_BRANCH
        ]]; then
      local tag=${(V)VCS_STATUS_TAG}
      (( $#tag > 32 )) && tag[13,-13]="…"
      res+="${meta}#${clean}${tag//\%/%%}"
    fi

    [[ -z $VCS_STATUS_LOCAL_BRANCH && -z $VCS_STATUS_TAG ]] &&
      res+="${meta}@${clean}${VCS_STATUS_COMMIT[1,8]}"

    if [[ -n ${VCS_STATUS_REMOTE_BRANCH:#$VCS_STATUS_LOCAL_BRANCH} ]]; then
      res+="${meta}:${clean}${(V)VCS_STATUS_REMOTE_BRANCH//\%/%%}"
    fi

    if [[ $VCS_STATUS_COMMIT_SUMMARY == (|*[^[:alnum:]])(wip|WIP)(|[^[:alnum:]]*) ]]; then
      res+=" ${modified}wip"
    fi

    if (( VCS_STATUS_COMMITS_AHEAD || VCS_STATUS_COMMITS_BEHIND )); then
      (( VCS_STATUS_COMMITS_BEHIND )) && res+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
      (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
      (( VCS_STATUS_COMMITS_AHEAD  )) && res+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    elif [[ -n $VCS_STATUS_REMOTE_BRANCH ]]; then
    fi

    (( VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" ${clean}⇠${VCS_STATUS_PUSH_COMMITS_BEHIND}"
    (( VCS_STATUS_PUSH_COMMITS_AHEAD && !VCS_STATUS_PUSH_COMMITS_BEHIND )) && res+=" "
    (( VCS_STATUS_PUSH_COMMITS_AHEAD  )) && res+="${clean}⇢${VCS_STATUS_PUSH_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES        )) && res+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION     ]] && res+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && res+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED     )) && res+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED   )) && res+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED  )) && res+=" ${untracked}${(g::)POWERLEVEL9K_VCS_UNTRACKED_ICON}${VCS_STATUS_NUM_UNTRACKED}"
    (( VCS_STATUS_HAS_UNSTAGED == -1 )) && res+=" ${modified}─"

    typeset -g my_git_format=$res
  }
  functions -M my_git_formatter 2>/dev/null

  typeset -g POWERLEVEL9K_VCS_MAX_INDEX_SIZE_DIRTY=-1

  typeset -g POWERLEVEL9K_VCS_DISABLED_WORKDIR_PATTERN='~'

  typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
  typeset -g POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
  typeset -g POWERLEVEL9K_VCS_{STAGED,UNSTAGED,UNTRACKED,CONFLICTED,COMMITS_AHEAD,COMMITS_BEHIND}_MAX_NUM=-1

  typeset -g POWERLEVEL9K_VCS_VISUAL_IDENTIFIER_COLOR='#cba6f7'
  typeset -g POWERLEVEL9K_VCS_LOADING_VISUAL_IDENTIFIER_COLOR='#cba6f7'
  typeset -g POWERLEVEL9K_VCS_GIT_GITEA_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_GITLAB_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_CODEBERG_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_BITBUCKET_ICON=' '
  typeset -g POWERLEVEL9K_VCS_GIT_ICON=' '

  typeset -ga POWERLEVEL9K_VCS_GIT_REMOTE_ICONS=(
    '*github.com*'             VCS_GIT_GITHUB_ICON
    '*gitea.tcs.tifr.res.in*'   VCS_GIT_GITEA_ICON
    '*gitea.com*'              VCS_GIT_GITEA_ICON
    '*gitea.io*'               VCS_GIT_GITEA_ICON
    '*gitlab.com*'             VCS_GIT_GITLAB_ICON
    '*codeberg.org*'           VCS_GIT_CODEBERG_ICON
    '*bitbucket.org*'          VCS_GIT_BITBUCKET_ICON
    '*'                       VCS_GIT_ICON
  )

  typeset -g POWERLEVEL9K_VCS_BACKENDS=(git)

  typeset -g POWERLEVEL9K_VCS_CLEAN_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='#f5c2e7'
  typeset -g POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='#fab387'

  # status
  typeset -g POWERLEVEL9K_STATUS_EXTENDED_STATES=true
  typeset -g POWERLEVEL9K_STATUS_CONTENT_EXPANSION=''

  typeset -g POWERLEVEL9K_STATUS_OK=true
  typeset -g POWERLEVEL9K_STATUS_OK_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_STATUS_OK_VISUAL_IDENTIFIER_EXPANSION='✔'

  typeset -g POWERLEVEL9K_STATUS_OK_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_STATUS_OK_PIPE_VISUAL_IDENTIFIER_EXPANSION='✔'

  typeset -g POWERLEVEL9K_STATUS_ERROR=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_FOREGROUND='#eba0ac'
  typeset -g POWERLEVEL9K_STATUS_ERROR_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_FOREGROUND='#eba0ac'
  typeset -g POWERLEVEL9K_STATUS_VERBOSE_SIGNAME=false
  typeset -g POWERLEVEL9K_STATUS_ERROR_SIGNAL_VISUAL_IDENTIFIER_EXPANSION='✘'

  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE=true
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_FOREGROUND='#eba0ac'
  typeset -g POWERLEVEL9K_STATUS_ERROR_PIPE_VISUAL_IDENTIFIER_EXPANSION='✘'

  # command_execution_time
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_PRECISION=0
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FOREGROUND='#bac2de'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_FORMAT='d h m s'

  # background_jobs
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_VERBOSE=false
  typeset -g POWERLEVEL9K_BACKGROUND_JOBS_FOREGROUND='#f9e2af'

  # direnv
  typeset -g POWERLEVEL9K_DIRENV_FOREGROUND='#f9e2af'

  # asdf
  typeset -g POWERLEVEL9K_ASDF_FOREGROUND='#94e2d5'

  typeset -g POWERLEVEL9K_ASDF_SOURCES=(shell local global)

  typeset -g POWERLEVEL9K_ASDF_PROMPT_ALWAYS_SHOW=false

  typeset -g POWERLEVEL9K_ASDF_SHOW_SYSTEM=true

  typeset -g POWERLEVEL9K_ASDF_SHOW_ON_UPGLOB=

  typeset -g POWERLEVEL9K_ASDF_RUBY_FOREGROUND='#f5c2e7'

  typeset -g POWERLEVEL9K_ASDF_PYTHON_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_GOLANG_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_NODEJS_FOREGROUND='#a6e3a1'

  typeset -g POWERLEVEL9K_ASDF_RUST_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_DOTNET_CORE_FOREGROUND='#cba6f7'

  typeset -g POWERLEVEL9K_ASDF_FLUTTER_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_LUA_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_JAVA_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_PERL_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ASDF_ERLANG_FOREGROUND='#f38ba8'

  typeset -g POWERLEVEL9K_ASDF_ELIXIR_FOREGROUND='#cba6f7'

  typeset -g POWERLEVEL9K_ASDF_POSTGRES_FOREGROUND='#89b4fa'

  typeset -g POWERLEVEL9K_ASDF_PHP_FOREGROUND='#cba6f7'

  typeset -g POWERLEVEL9K_ASDF_HASKELL_FOREGROUND='#fab387'

  typeset -g POWERLEVEL9K_ASDF_JULIA_FOREGROUND='#a6e3a1'

  # nordvpn
  typeset -g POWERLEVEL9K_NORDVPN_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_NORDVPN_{DISCONNECTED,CONNECTING,DISCONNECTING}_VISUAL_IDENTIFIER_EXPANSION=

  # ranger
  typeset -g POWERLEVEL9K_RANGER_FOREGROUND='#f9e2af'

  # yazi
  typeset -g POWERLEVEL9K_YAZI_FOREGROUND='#f9e2af'

  # nnn
  typeset -g POWERLEVEL9K_NNN_FOREGROUND='#74c7ec'

  # lf
  typeset -g POWERLEVEL9K_LF_FOREGROUND='#74c7ec'

  # xplr
  typeset -g POWERLEVEL9K_XPLR_FOREGROUND='#74c7ec'

  # vim_shell
  typeset -g POWERLEVEL9K_VIM_SHELL_FOREGROUND='#a6e3a1'

  # midnight_commander
  typeset -g POWERLEVEL9K_MIDNIGHT_COMMANDER_FOREGROUND='#f9e2af'

  # nix_shell
  typeset -g POWERLEVEL9K_NIX_SHELL_FOREGROUND='#89dceb'

  # chezmoi_shell
  typeset -g POWERLEVEL9K_CHEZMOI_SHELL_FOREGROUND='#89b4fa'

  # disk_usage
  typeset -g POWERLEVEL9K_DISK_USAGE_NORMAL_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_DISK_USAGE_WARNING_LEVEL=90
  typeset -g POWERLEVEL9K_DISK_USAGE_CRITICAL_LEVEL=95
  typeset -g POWERLEVEL9K_DISK_USAGE_ONLY_WARNING=false

  # vi_mode
  typeset -g POWERLEVEL9K_VI_COMMAND_MODE_STRING=N
  typeset -g POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_VI_VISUAL_MODE_STRING=VISUAL
  typeset -g POWERLEVEL9K_VI_MODE_VISUAL_FOREGROUND='#89b4fa'
  typeset -g POWERLEVEL9K_VI_OVERWRITE_MODE_STRING=OVERTYPE
  typeset -g POWERLEVEL9K_VI_MODE_OVERWRITE_FOREGROUND='#fab387'
  typeset -g POWERLEVEL9K_VI_INSERT_MODE_STRING=
  typeset -g POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='#74c7ec'

  # ram
  typeset -g POWERLEVEL9K_RAM_FOREGROUND='#fab387'

  # swap
  typeset -g POWERLEVEL9K_SWAP_FOREGROUND='#f5c2e7'

  # load
  typeset -g POWERLEVEL9K_LOAD_WHICH=5
  typeset -g POWERLEVEL9K_LOAD_NORMAL_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_LOAD_WARNING_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_LOAD_CRITICAL_FOREGROUND='#f38ba8'

  # todo
  typeset -g POWERLEVEL9K_TODO_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_TOTAL=true
  typeset -g POWERLEVEL9K_TODO_HIDE_ZERO_FILTERED=false

  # timewarrior
  typeset -g POWERLEVEL9K_TIMEWARRIOR_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_TIMEWARRIOR_CONTENT_EXPANSION='${P9K_CONTENT:0:24}${${P9K_CONTENT:24}:+…}'

  # taskwarrior
  typeset -g POWERLEVEL9K_TASKWARRIOR_FOREGROUND='#89dceb'

  # per_directory_history
  typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_LOCAL_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_PER_DIRECTORY_HISTORY_GLOBAL_FOREGROUND='#fab387'

  # cpu_arch
  typeset -g POWERLEVEL9K_CPU_ARCH_FOREGROUND='#fab387'

  # context
  typeset -g POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='#fab387'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_CONTEXT_FOREGROUND='#f9e2af'

  typeset -g POWERLEVEL9K_CONTEXT_ROOT_TEMPLATE='%B%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_{REMOTE,REMOTE_SUDO}_TEMPLATE='%n@%m'
  typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE='%n@%m'

  typeset -g POWERLEVEL9K_CONTEXT_{DEFAULT,SUDO}_{CONTENT,VISUAL_IDENTIFIER}_EXPANSION=

  # virtualenv
  typeset -g POWERLEVEL9K_VIRTUALENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_PYTHON_VERSION=false
  typeset -g POWERLEVEL9K_VIRTUALENV_SHOW_WITH_PYENV=false
  typeset -g POWERLEVEL9K_VIRTUALENV_{LEFT,RIGHT}_DELIMITER=

  # anaconda
  typeset -g POWERLEVEL9K_ANACONDA_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_ANACONDA_CONTENT_EXPANSION='${${${${CONDA_PROMPT_MODIFIER#\(}% }%\)}:-${CONDA_PREFIX:t}}'

  # pyenv
  typeset -g POWERLEVEL9K_PYENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_PYENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PYENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PYENV_SHOW_SYSTEM=true

  typeset -g POWERLEVEL9K_PYENV_CONTENT_EXPANSION='${P9K_CONTENT}${${P9K_CONTENT:#$P9K_PYENV_PYTHON_VERSION(|/*)}:+ $P9K_PYENV_PYTHON_VERSION}'

  # goenv
  typeset -g POWERLEVEL9K_GOENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_GOENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_GOENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_GOENV_SHOW_SYSTEM=true

  # nodenv
  typeset -g POWERLEVEL9K_NODENV_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_NODENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_NODENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_NODENV_SHOW_SYSTEM=true

  # nvm
  typeset -g POWERLEVEL9K_NVM_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_NVM_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_NVM_SHOW_SYSTEM=true

  # nodeenv
  typeset -g POWERLEVEL9K_NODEENV_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_NODEENV_SHOW_NODE_VERSION=false
  typeset -g POWERLEVEL9K_NODEENV_{LEFT,RIGHT}_DELIMITER=

  # node_version
  typeset -g POWERLEVEL9K_NODE_VERSION_FOREGROUND='#94e2d5'
  typeset -g POWERLEVEL9K_NODE_VERSION_PROJECT_ONLY=true

  # go_version
  typeset -g POWERLEVEL9K_GO_VERSION_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_GO_VERSION_PROJECT_ONLY=true

  # rust_version
  typeset -g POWERLEVEL9K_RUST_VERSION_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_RUST_VERSION_PROJECT_ONLY=true

  # dotnet_version
  typeset -g POWERLEVEL9K_DOTNET_VERSION_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_DOTNET_VERSION_PROJECT_ONLY=true

  # php_version
  typeset -g POWERLEVEL9K_PHP_VERSION_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_PHP_VERSION_PROJECT_ONLY=true

  # laravel_version
  typeset -g POWERLEVEL9K_LARAVEL_VERSION_FOREGROUND='#f5c2e7'

  # java_version
  typeset -g POWERLEVEL9K_JAVA_VERSION_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_JAVA_VERSION_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_JAVA_VERSION_FULL=false

  # package
  typeset -g POWERLEVEL9K_PACKAGE_FOREGROUND='#89dceb'

  # rbenv
  typeset -g POWERLEVEL9K_RBENV_FOREGROUND='#f5c2e7'
  typeset -g POWERLEVEL9K_RBENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_RBENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_RBENV_SHOW_SYSTEM=true

  # rvm
  typeset -g POWERLEVEL9K_RVM_FOREGROUND='#f5c2e7'
  typeset -g POWERLEVEL9K_RVM_SHOW_GEMSET=false
  typeset -g POWERLEVEL9K_RVM_SHOW_PREFIX=false

  # fvm
  typeset -g POWERLEVEL9K_FVM_FOREGROUND='#89dceb'

  # luaenv
  typeset -g POWERLEVEL9K_LUAENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_LUAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_LUAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_LUAENV_SHOW_SYSTEM=true

  # jenv
  typeset -g POWERLEVEL9K_JENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_JENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_JENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_JENV_SHOW_SYSTEM=true

  # plenv
  typeset -g POWERLEVEL9K_PLENV_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_PLENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PLENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PLENV_SHOW_SYSTEM=true

  # perlbrew
  typeset -g POWERLEVEL9K_PERLBREW_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_PERLBREW_PROJECT_ONLY=true
  typeset -g POWERLEVEL9K_PERLBREW_SHOW_PREFIX=false

  # phpenv
  typeset -g POWERLEVEL9K_PHPENV_FOREGROUND='#cba6f7'
  typeset -g POWERLEVEL9K_PHPENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_PHPENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_PHPENV_SHOW_SYSTEM=true

  # scalaenv
  typeset -g POWERLEVEL9K_SCALAENV_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_SCALAENV_SOURCES=(shell local global)
  typeset -g POWERLEVEL9K_SCALAENV_PROMPT_ALWAYS_SHOW=false
  typeset -g POWERLEVEL9K_SCALAENV_SHOW_SYSTEM=true

  # haskell_stack
  typeset -g POWERLEVEL9K_HASKELL_STACK_FOREGROUND='#fab387'
  typeset -g POWERLEVEL9K_HASKELL_STACK_SOURCES=(shell local)
  typeset -g POWERLEVEL9K_HASKELL_STACK_ALWAYS_SHOW=true

  # terraform
  typeset -g POWERLEVEL9K_TERRAFORM_SHOW_DEFAULT=false
  typeset -g POWERLEVEL9K_TERRAFORM_CLASSES=(
      '*'         OTHER)
  typeset -g POWERLEVEL9K_TERRAFORM_OTHER_FOREGROUND='#89dceb'

  # terraform_version
  typeset -g POWERLEVEL9K_TERRAFORM_VERSION_FOREGROUND='#89dceb'

  # kubecontext
  typeset -g POWERLEVEL9K_KUBECONTEXT_SHOW_ON_COMMAND='kubectl|helm|kubens|kubectx|oc|istioctl|kogito|k9s|helmfile|flux|fluxctl|stern|kubeseal|skaffold|kubent|kubecolor|cmctl|sparkctl'

  typeset -g POWERLEVEL9K_KUBECONTEXT_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_FOREGROUND='#cba6f7'

  typeset -g POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION=
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${P9K_KUBECONTEXT_CLOUD_CLUSTER:-${P9K_KUBECONTEXT_NAME}}'
  POWERLEVEL9K_KUBECONTEXT_DEFAULT_CONTENT_EXPANSION+='${${:-/$P9K_KUBECONTEXT_NAMESPACE}:#/default}'

  # aws
  typeset -g POWERLEVEL9K_AWS_SHOW_ON_COMMAND='aws|awless|cdk|terraform|tofu|pulumi|terragrunt'

  typeset -g POWERLEVEL9K_AWS_CLASSES=(
      '*'       DEFAULT)
  typeset -g POWERLEVEL9K_AWS_DEFAULT_FOREGROUND='#fab387'

  typeset -g POWERLEVEL9K_AWS_CONTENT_EXPANSION='${P9K_AWS_PROFILE//\%/%%}${P9K_AWS_REGION:+ ${P9K_AWS_REGION//\%/%%}}'

  # aws_eb_env
  typeset -g POWERLEVEL9K_AWS_EB_ENV_FOREGROUND='#94e2d5'

  # azure
  typeset -g POWERLEVEL9K_AZURE_SHOW_ON_COMMAND='az|terraform|tofu|pulumi|terragrunt'

  typeset -g POWERLEVEL9K_AZURE_CLASSES=(
      '*'         OTHER)

  typeset -g POWERLEVEL9K_AZURE_OTHER_FOREGROUND='#89dceb'

  # gcloud
  typeset -g POWERLEVEL9K_GCLOUD_SHOW_ON_COMMAND='gcloud|gcs|gsutil'
  typeset -g POWERLEVEL9K_GCLOUD_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_GCLOUD_PARTIAL_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_ID//\%/%%}'
  typeset -g POWERLEVEL9K_GCLOUD_COMPLETE_CONTENT_EXPANSION='${P9K_GCLOUD_PROJECT_NAME//\%/%%}'

  typeset -g POWERLEVEL9K_GCLOUD_REFRESH_PROJECT_NAME_SECONDS=60

  # google_app_cred
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_SHOW_ON_COMMAND='terraform|tofu|pulumi|terragrunt'

  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_CLASSES=(
      '*'             DEFAULT)
  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_FOREGROUND='#89dceb'

  typeset -g POWERLEVEL9K_GOOGLE_APP_CRED_DEFAULT_CONTENT_EXPANSION='${P9K_GOOGLE_APP_CRED_PROJECT_ID//\%/%%}'

  # toolbox
  typeset -g POWERLEVEL9K_TOOLBOX_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_TOOLBOX_CONTENT_EXPANSION='${P9K_TOOLBOX_NAME:#fedora-toolbox-*}'

  # public_ip
  typeset -g POWERLEVEL9K_PUBLIC_IP_FOREGROUND='#fab387'

  # vpn_ip
  typeset -g POWERLEVEL9K_VPN_IP_FOREGROUND='#89b4fa'
  typeset -g POWERLEVEL9K_VPN_IP_CONTENT_EXPANSION=
  typeset -g POWERLEVEL9K_VPN_IP_INTERFACE='(gpd|wg|(.*tun)|tailscale)[0-9]*|(zt.*)'
  typeset -g POWERLEVEL9K_VPN_IP_SHOW_ALL=false

  # ip
  typeset -g POWERLEVEL9K_IP_FOREGROUND='#89dceb'
  typeset -g POWERLEVEL9K_IP_CONTENT_EXPANSION='${P9K_IP_RX_RATE:+%70F⇣$P9K_IP_RX_RATE }${P9K_IP_TX_RATE:+%215F⇡$P9K_IP_TX_RATE }%38F$P9K_IP_IP'
  typeset -g POWERLEVEL9K_IP_INTERFACE='[ew].*'

  # proxy
  typeset -g POWERLEVEL9K_PROXY_FOREGROUND='#89b4fa'

  # battery
  typeset -g POWERLEVEL9K_BATTERY_LOW_THRESHOLD=20
  typeset -g POWERLEVEL9K_BATTERY_LOW_FOREGROUND='#f38ba8'
  typeset -g POWERLEVEL9K_BATTERY_{CHARGING,CHARGED}_FOREGROUND='#a6e3a1'
  typeset -g POWERLEVEL9K_BATTERY_DISCONNECTED_FOREGROUND='#f9e2af'
  typeset -g POWERLEVEL9K_BATTERY_STAGES='\UF008E\UF007A\UF007B\UF007C\UF007D\UF007E\UF007F\UF0080\UF0081\UF0082\UF0079'
  typeset -g POWERLEVEL9K_BATTERY_VERBOSE=false

  # wifi
  typeset -g POWERLEVEL9K_WIFI_FOREGROUND='#89b4fa'

  # time
  typeset -g POWERLEVEL9K_TIME_FOREGROUND='#f5c2e7'
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
  typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false

  # Custom segment example
  function prompt_example() {
    p10k segment -f 208 -i '⭐' -t 'hello, %n'
  }

  function instant_prompt_example() {
    prompt_example
  }

  typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off

  typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose

  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true

  # Coding indicators and reload
  source "${${(%):-%x}:A:h}/prompt-code.zsh"

  (( ! $+functions[p10k] )) || p10k reload
}

typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'

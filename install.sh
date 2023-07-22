#!/usr/bin/env bash

# @file install.sh
# @brief install script for all configuration


# @description check if the user is root then execute the command
#
# @arg $1 a bash command
# @exitcode 0 If successfull.
# @exitcode 1 On failure
exec_root() {
    local command="$*"
    if [[ ! "$#" -eq 0 ]]; then
        if [[ "$UID" -gt 0 ]]; then
            echo "sudo $command"
            sudo $command
        else
            echo "$command"
            $command
        fi
        return 0
    fi
    return 1
}


# @description show aliases in the current shell
# Detect Operating System
# @noargs
# @exitcode 0 If successfull.
# @exitcode 1 On failure
dist_check() {
    DIST_CHECK="/etc/os-release"
    if [ -e $DIST_CHECK ]; then
        source $DIST_CHECK
        DISTRO=$ID
        VERSION=$VERSION_ID
        export DISTRO
        export VERSION
    else
        echo "Your distribution is not supported (yet)."
        exit
    fi
}


# @description install package
#
# @args $@ packages to install
# @exitcode 0 If successfull.
# @exitcode 1 On failure
install_package(){
    echo "apt install $@"
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        for var in "$@"; do
            exec_root "apt-get -qq install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        for var in "$@"; do
            exec_root "pacman -Syu --noconfirm $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        for var in "$@"; do
            exec_root "dnf install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        for var in "$@"; do
            exec_root "yum install -y $var" >/dev/null
        done
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        for var in "$@"; do
            exec_root "brew install -q -y $var" > /dev/null
        done
        return 0
    fi
    return 1
}



# @description Install The ultimate Vim configuration (vimrc) https://github.com/amix/vimrc
# @exitcode 0 If successfull and install vimrc
# @exitcode 1 On failure
install_vimrc() {
    echo "Install vimrc"

    install_package vim git
    if [ ! -d ~/.vim_runtime ]; then
        git clone -q --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime > /dev/null
    fi
    sh ~/.vim_runtime/install_awesome_vimrc.sh
    # check if the line exist then write it in .bashrc
    grep -qxF 'alias vi=vim' ~/.bashrc || echo 'alias vi=vim' >> ~/.bashrc
}

# @description Edit vimrc for my need
# @exitcode 0 If successfull and edit vimrc
# @exitcode 1 On failure
edit_vimrc(){
    echo "Modify vimrc"

    sed -i -e 's/let g:NERDTreeWinPos = "right"/let g:NERDTreeWinPos = "left"/g' ~/.vim_runtime/vimrcs/plugins_config.vim
    if [ ! -f ~/.vim_runtime/vimrcs/my_configs.vim ]; then
        touch ~/.vim_runtime/vimrcs/my_configs.vim
    fi
    echo 'set number' > ~/.vim_runtime/vimrcs/my_configs.vim
}

# @description Install Oh my zsh
# @exitcode 0 If successfull and install oh my zsh
# @exitcode 1 On failure
install_oh_my_zsh(){
    echo "Install Oh my zsh"

    install_package zsh curl wget > /dev/null
    wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -q -O oh-my-zsh-install.sh
    sed -i -e 's/exec zsh -l//g' oh-my-zsh-install.sh
    bash oh-my-zsh-install.sh
    rm -f oh-my-zsh-install.sh
}

# @description Edit config Oh my zsh
# @exitcode 0 If successfull and edit with my custom config oh my zsh
# @exitcode 1 On failure
edit_oh_my_zsh(){
    echo "Install themes for oh-my-zsh"

    sed -i -e 's#ZSH_THEME="robbyrussell"#ZSH_THEME="lukerandall"#g' ~/.zshrc
    zsh -i -c "source ~/.zshrc"
    if [ ! -d ~/.oh-my-zsh/themes/minimal-theme ]; then
        mkdir ~/.oh-my-zsh/themes/minimal-theme
    fi
    cat > ~/.oh-my-zsh/themes/minimal-theme/minimal-theme.zsh-theme << EOF
local return_code="%(?..%{$fg_bold[red]%}%? %{$reset_color%})"

PROMPT='%{$fg_bold[green]%}%n@%m%{$reset_color%} %{$fg_bold[blue]%}%2~%{$reset_color%} %{$reset_color%}%B%b '
RPS1="${return_code}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX=") %{$reset_color%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%%"
ZSH_THEME_GIT_PROMPT_ADDED="+"
ZSH_THEME_GIT_PROMPT_MODIFIED="*"
ZSH_THEME_GIT_PROMPT_RENAMED="~"
ZSH_THEME_GIT_PROMPT_DELETED="!"
ZSH_THEME_GIT_PROMPT_UNMERGED="?"
EOF

    zsh -i -c "source ~/.zshrc"
}

# @description Install tmux
# @exitcode 0 If successfull and install tmux
# @exitcode 1 On failure
install_tmux(){
    echo "Install tmux"

    install_package tmux > /dev/null
    cat > ~/.tmux.conf << EOF
### -- Windows & Pane creation -- ###

# New Window retains current path, possible values are:
#   - true
#   - false (default)

tmux_conf_new_window_retain_current_path=false

# New Pane retains current path, possible values are:
#   - true (default)
#   - false

tmux_conf_new_pane_retain_current_path=true

# New Pane tries to reconnect ssh sessions (experimental), possible values are:
#   - true
#   - false (default)

tmux_conf_new_pane_reconnect_ssh=false

# Prompt for session name when creating a new session, possible values are:
#   - true
#   - false (default)

tmux_conf_new_session_prompt=false


### -- Display -- ###

# RGB 24-bit colour support (tmux >= 2.2), possible values are:
#  - true
#  - false (default)
tmux_conf_24b_colour=ture

# Default theme
tmux_conf_theme_colour_1="#080808"    # dark gray
tmux_conf_theme_colour_2="#303030"    # gray
tmux_conf_theme_colour_3="#8a8a8a"    # light gray
tmux_conf_theme_colour_4="#00afff"    # light blue
tmux_conf_theme_colour_5="#ffff00"    # yellow
tmux_conf_theme_colour_6="#080808"    # dark gray
tmux_conf_theme_colour_7="#e4e4e4"    # white
tmux_conf_theme_colour_8="#080808"    # dark gray
tmux_conf_theme_colour_9="#ffff00"    # yellow
tmux_conf_theme_colour_10="#ff00af"   # pink
tmux_conf_theme_colour_11="#5fff00"   # green
tmux_conf_theme_colour_12="#8a8a8a"   # light gray
tmux_conf_theme_colour_13="#e4e4e4"   # white
tmux_conf_theme_colour_14="#080808"   # dark gray
tmux_conf_theme_colour_15="#080808"   # dark gray
tmux_conf_theme_colour_16="#d70000"   # red
tmux_conf_theme_colour_17="#e4e4e4"   # white

# Default theme (ansi)
#tmux_conf_theme_colour_1="colour0"
#tmux_conf_theme_colour_2="colour8"
#tmux_conf_theme_colour_3="colour8"
#tmux_conf_theme_colour_4="colour14"
#tmux_conf_theme_colour_5="colour11"
#tmux_conf_theme_colour_6="colour0"
#tmux_conf_theme_colour_7="colour15"
#tmux_conf_theme_colour_8="colour0"
#tmux_conf_theme_colour_9="colour11"
#tmux_conf_theme_colour_10="colour13"
#tmux_conf_theme_colour_11="colour10"
#tmux_conf_theme_colour_12="colour8"
#tmux_conf_theme_colour_13="colour15"
#tmux_conf_theme_colour_14="colour0"
#tmux_conf_theme_colour_15="colour0"
#tmux_conf_theme_colour_16="colour1"
#tmux_conf_theme_colour_17="colour15"

# Window style
tmux_conf_theme_window_fg="default"
tmux_conf_theme_window_bg="default"

# Highlight focused pane (tmux >= 2.1), possible values are:
#   - true
#   - false (default)

tmux_conf_theme_highlight_focused_pane=false

# Focused pane colours:
tmux_conf_theme_focused_pane_bg="$tmux_conf_theme_colour_2"

# Pane border style, possible values are:
#   - thin (default)
#   - fat

tmux_conf_theme_pane_border_style=thin

# Pane borders colours:
tmux_conf_theme_pane_border="$tmux_conf_theme_colour_2"
tmux_conf_theme_pane_active_border="$tmux_conf_theme_colour_4"

# Pane indicator colours (when you hit <prefix> + q)
tmux_conf_theme_pane_indicator="$tmux_conf_theme_colour_4"
tmux_conf_theme_pane_active_indicator="$tmux_conf_theme_colour_4"

# Status line style
tmux_conf_theme_message_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_attr="bold"

# Status line command style (<prefix> : Escape)
tmux_conf_theme_message_command_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_message_command_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_message_command_attr="bold"

# Window modes style
tmux_conf_theme_mode_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_mode_bg="$tmux_conf_theme_colour_5"
tmux_conf_theme_mode_attr="bold"

# Status line style
tmux_conf_theme_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_status_attr="none"

# Terminal title
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}

tmux_conf_theme_terminal_title="#h  #S  #I #W"

# Window status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}

tmux_conf_theme_window_status_fg="$tmux_conf_theme_colour_3"
tmux_conf_theme_window_status_bg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_attr="none"
tmux_conf_theme_window_status_format="#I #W"
#tmux_conf_theme_window_status_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_format="#I #W#{?window_bell_flag,,}#{?window_zoomed_flag,,}"

# window current status style
#   - built-in variables are:
#     - #{circled_window_index}
#     - #{circled_session_name}
#     - #{hostname}
#     - #{hostname_ssh}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_window_status_current_fg="$tmux_conf_theme_colour_1"
tmux_conf_theme_window_status_current_bg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_current_attr="bold"
tmux_conf_theme_window_status_current_format="#I #W"
#tmux_conf_theme_window_status_current_format="#{circled_window_index} #W"
#tmux_conf_theme_window_status_current_format="#I #W#{?window_zoomed_flag,,}"

# window activity status style
tmux_conf_theme_window_status_activity_fg="default"
tmux_conf_theme_window_status_activity_bg="default"
tmux_conf_theme_window_status_activity_attr="underscore"

# window bell status style
tmux_conf_theme_window_status_bell_fg="$tmux_conf_theme_colour_5"
tmux_conf_theme_window_status_bell_bg="default"
tmux_conf_theme_window_status_bell_attr="blink,bold"

# window last status style
tmux_conf_theme_window_status_last_fg="$tmux_conf_theme_colour_4"
tmux_conf_theme_window_status_last_bg="$tmux_conf_theme_colour_2"
tmux_conf_theme_window_status_last_attr="none"

# status left/right sections separators
tmux_conf_theme_left_separator_main=""
tmux_conf_theme_left_separator_sub="|"
tmux_conf_theme_right_separator_main=""
tmux_conf_theme_right_separator_sub="|"
#tmux_conf_theme_left_separator_main="\uE0B0"  # /!\ you don't need to install Powerline
#tmux_conf_theme_left_separator_sub="\uE0B1"   #   you only need fonts patched with
#tmux_conf_theme_right_separator_main="\uE0B2" #   Powerline symbols or the standalone
#tmux_conf_theme_right_separator_sub="\uE0B3"  #   PowerlineSymbols.otf font, see README.md

# status left/right content:
#   - separate main sections with "|"
#   - separate subsections with ","
#   - built-in variables are:
#     - #{battery_bar}
#     - #{battery_hbar}
#     - #{battery_percentage}
#     - #{battery_status}
#     - #{battery_vbar}
#     - #{circled_session_name}
#     - #{hostname_ssh}
#     - #{hostname}
#     - #{hostname_full}
#     - #{hostname_full_ssh}
#     - #{loadavg}
#     - #{mouse}
#     - #{pairing}
#     - #{prefix}
#     - #{root}
#     - #{synchronized}
#     - #{uptime_y}
#     - #{uptime_d} (modulo 365 when #{uptime_y} is used)
#     - #{uptime_h}
#     - #{uptime_m}
#     - #{uptime_s}
#     - #{username}
#     - #{username_ssh}
tmux_conf_theme_status_left="  #S | #{?uptime_y, #{uptime_y}y,}#{?uptime_d, #{uptime_d}d,}#{?uptime_h, #{uptime_h}h,}#{?uptime_m, #{uptime_m}m,} "
tmux_conf_theme_status_right=" #{prefix}#{mouse}#{pairing}#{synchronized}#, %R , %d %b | #{username}#{root} | #{hostname} "

# status left style
tmux_conf_theme_status_left_fg="$tmux_conf_theme_colour_6,$tmux_conf_theme_colour_7,$tmux_conf_theme_colour_8"
tmux_conf_theme_status_left_bg="$tmux_conf_theme_colour_9,$tmux_conf_theme_colour_10,$tmux_conf_theme_colour_11"
tmux_conf_theme_status_left_attr="bold,none,none"

# status right style
tmux_conf_theme_status_right_fg="$tmux_conf_theme_colour_12,$tmux_conf_theme_colour_13,$tmux_conf_theme_colour_14"
tmux_conf_theme_status_right_bg="$tmux_conf_theme_colour_15,$tmux_conf_theme_colour_16,$tmux_conf_theme_colour_17"
tmux_conf_theme_status_right_attr="none,none,bold"

# pairing indicator
tmux_conf_theme_pairing=""                 # U+2687
tmux_conf_theme_pairing_fg="none"
tmux_conf_theme_pairing_bg="none"
tmux_conf_theme_pairing_attr="none"

# prefix indicator
tmux_conf_theme_prefix=""                  # U+2328
tmux_conf_theme_prefix_fg="none"
tmux_conf_theme_prefix_bg="none"
tmux_conf_theme_prefix_attr="none"

# mouse indicator
tmux_conf_theme_mouse=""                   # U+2197
tmux_conf_theme_mouse_fg="none"
tmux_conf_theme_mouse_bg="none"
tmux_conf_theme_mouse_attr="none"

# root indicator
tmux_conf_theme_root="!"
tmux_conf_theme_root_fg="none"
tmux_conf_theme_root_bg="none"
tmux_conf_theme_root_attr="bold,blink"

# synchronized indicator
tmux_conf_theme_synchronized=""            # U+268F
tmux_conf_theme_synchronized_fg="none"
tmux_conf_theme_synchronized_bg="none"
tmux_conf_theme_synchronized_attr="none"

# clock style (when you hit <prefix> + t)
# you may want to use %I:%M %p in place of %R in tmux_conf_theme_status_right
tmux_conf_theme_clock_colour="$tmux_conf_theme_colour_4"
tmux_conf_theme_clock_style="24"

### -- Clipboard -- ###

# in copy mode, copying selection also copies to the OS clipboard
#   - true
#   - false (default)
# on macOS, this requires installing reattach-to-user-namespace, see README.md
# on Linux, this requires xsel or xclip

tmux_conf_copy_to_os_clipboard=true

### -- User Customizations -- ###
# this is the place to override or undo settings

# increase history size
set -g history-limit 10000

# start with mouse mode enabled
set -g mouse on

# force Vi mode
#   really you should export VISUAL or EDITOR environment variable, see manual
#set -g status-keys vi
#set -g mode-keys vi

# move status line to top
#set -g status-position top

### -- TPM -- ###

# by default, launching tmux will update tpm and all plugins
#   - true (default)
#   - false

tmux_conf_update_plugins_on_launch=true

# by default, reloading the configuration will update tpm and all plugins
#   - true (default)
#   - false

tmux_conf_update_plugins_on_reload=true

# to enable a plugin, use the 'set -g @plugin' syntax:
# visit https://github.com/tmux-plugins for available plugins
set -g @plugin 'tmux-plugins/tmux-copycat'
#set -g @plugin 'tmux-plugins/tmux-cpu'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'
EOF
}

# @description Install fish shell
# @exitcode 0 If successfull and install fish shell
# @exitcode 1 On failure
install_fish() {
    echo "Installing fish shell..."

    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -y fish" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syu --noconfirm fish" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf install -y fish" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum install -y fish" >/dev/null
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        exec_root "brew install -q -y fish" > /dev/null
        return 0
    fi
    return 1
}

# @description Install build-essential package
# @exitcode 0 If successfull and install build-essential package
# @exitcode 1 On failure
install_build_essential() {
    echo "Installing build-essential package..."

    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -y build-essential" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syu --noconfirm base-devel" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf groupinstall -y 'Development Tools'" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum groupinstall -y 'Development Tools'" >/dev/null
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        echo "The build-essential package is not available for macOS. Please install the required tools manually."
        return 1
    fi
    return 1
}

# @description Install JDK
# @exitcode 0 If successfull and install JDK
# @exitcode 1 On failure
install_jdk() {
    echo "Installing JDK..."

    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -y default-jdk" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syu --noconfirm jdk-openjdk" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf install -y java-11-openjdk-devel" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum install -y java-11-openjdk-devel" >/dev/null
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        exec_root "brew install --cask adoptopenjdk" >/dev/null
        return 0
    fi
    return 1
}

# @description Install Python
# @exitcode 0 If successfull and install Python
# @exitcode 1 On failure
install_python() {
    echo "Installing Python..."

    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -y python3 python3-pip" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syu --noconfirm python python-pip" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf install -y python3 python3-pip" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum install -y python3 python3-pip" >/dev/null
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        exec_root "brew install python3" >/dev/null
        return 0
    fi
    return 1
}

# @description Install Node Version Manager (nvm)
# @exitcode 0 If successful and install nvm
# @exitcode 1 On failure
install_nvm() {
    echo "Installing nvm..."

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    source ~/.bashrc
    nvm install node
}

# @description Install .NET Core
# @exitcode 0 If successful and install .NET Core
# @exitcode 1 On failure
install_dotnet() {
    echo "Installing .NET Core..."

    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
        sudo dpkg -i packages-microsoft-prod.deb
        sudo apt-get update
        sudo apt-get install -y apt-transport-https
        sudo apt-get update
        sudo apt-get install -y dotnet-sdk-3.1
    fi
    # Add other distributions here...
}

# @description Install Go
# @exitcode 0 If successful and install Go
# @exitcode 1 On failure
install_go() {
    echo "Installing Go..."

    wget https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go1.16.5.linux-amd64.tar.gz
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
}

# @description Install Rust
# @exitcode 0 If successful and install Rust
# @exitcode 1 On failure
install_rust() {
    echo "Installing Rust..."

    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}


# @description Install Azure CLI
# @exitcode 0 If successfull and install Azure CLI
# @exitcode 1 On failure
install_azure_cli() {
    echo "Installing Azure CLI..."

    # Install Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    return 0
}

# @description Install AWS CLI
# @exitcode 0 If successfull and install AWS CLI
# @exitcode 1 On failure
install_aws_cli() {
    echo "Installing AWS CLI..."

    # Install AWS CLI
    curl "https://d1vvhvl2y92vvt.cloudfront.net/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install

    return 0
}

# @description Install Docker and Docker Compose
# @exitcode 0 If successfull and install Docker and Docker Compose
# @exitcode 1 On failure
install_docker() {
    echo "Installing Docker and Docker Compose..."

    # Install Docker
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh

    # Install Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose

    return 0
}

# @description Install kubectl
# @exitcode 0 If successfull and install kubectl
# @exitcode 1 On failure
install_kubectl() {
    echo "Installing kubectl..."

    # Install kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/

    return 0
}

# @description Install JupyterLab
# @exitcode 0 If successfull and install JupyterLab
# @exitcode 1 On failure
install_jupyterlab() {
    echo "Installing JupyterLab..."

    # Check if Python is installed
    if ! command -v python3 &> /dev/null
    then
        echo "Python could not be found. Please install Python first."
        return 1
    fi

    # Install JupyterLab
    pip3 install jupyterlab

    return 0
}


# @description Add aliases to bashrc, zshrc, and fishrc
# @exitcode 0 If successful
# @exitcode 1 On failure
add_aliases() {
    echo "Adding aliases..."

    # Define your aliases here
    local aliases=(
        "alias ll='ls -l'"
        "alias la='ls -A'"
        "alias l='ls -CF'"
        "alias dotnet='~/.dotnet/dotnet'"
        "alias jupyterlab='~/.local/bin/jupyter-lab'"
    )

    # Add aliases to bashrc
    if [ -f ~/.bashrc ]; then
        for alias in "${aliases[@]}"; do
            echo "$alias" >> ~/.bashrc
        done
    fi

    # Add aliases to zshrc
    if [ -f ~/.zshrc ]; then
        for alias in "${aliases[@]}"; do
            echo "$alias" >> ~/.zshrc
        done
    fi

    # Add aliases to fishrc (fish shell uses a different syntax for aliases)
    if [ -f ~/.config/fish/config.fish ]; then
        for alias in "${aliases[@]}"; do
            # Convert bash-style alias to fish-style
            fish_alias=$(echo "$alias" | sed 's/alias /alias /' | sed 's/=/ /')
            echo "$fish_alias" >> ~/.config/fish/config.fish
        done
    fi

    return 0
}

# @description Install network and performance tools
# @exitcode 0 If successful
# @exitcode 1 On failure
install_network_performance_tools() {
    echo "Installing network and performance tools..."
    dist_check
    if [ "$DISTRO" == "ubuntu" ] || [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ]; then
        exec_root "apt-get -qq install -y nmap traceroute htop net-tools iperf3" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "arch" ]; then
        exec_root "pacman -Syu --noconfirm nmap traceroute htop net-tools iperf3" >/dev/null
        return 0
    fi
    if [ "$DISTRO" = 'fedora' ]; then
        exec_root "dnf install -y nmap traceroute htop net-tools iperf3" >/dev/null
        return 0
    fi
    if [ "$DISTRO" == "centos" ] || [ "$DISTRO" == "redhat" ]; then
        exec_root "yum install -y nmap traceroute htop net-tools iperf3" >/dev/null
        return 0
    fi
    if [ "$OSTYPE" == "Darwin" ]; then
        exec_root "brew install -q -y nmap traceroute htop net-tools iperf3" > /dev/null
        return 0
    fi
    return 1
}


usage() {
    echo "Usage: $0 [option]"
    echo "Options:"
    echo "  install_python        Install Python"
    echo "  install_jdk           Install JDK"
    echo "  install_build_essential Install build-essential"
    echo "  install_vimrc         Install vimrc"
    echo "  install_oh_my_zsh     Install Oh My Zsh"
    echo "  install_tmux          Install tmux"
    echo "  install_nvm           Install Node Version Manager (nvm)"
    echo "  install_dotnet        Install .NET Core"
    echo "  install_go            Install Go"
    echo "  install_rust          Install Rust"
    echo " install_azure_cli Install Azure CLI"
    echo " install_aws_cli Install AWS CLI"
    echo " install_docker Install Docker and Docker Compose"
    echo " install_kubectl Install kubectl"
    echo " install_jupyterlab Install JupyterLab"
    echo "install_network_performance_tools Install Network Performance Tools"
    echo "  help                  Display this help message"
    exit 1
}

# Function to handle command-line arguments
handle_option() {
    case $1 in
        install_python)
            install_python
            ;;
        install_jdk)
            install_jdk
            ;;
        install_build_essential)
            install_build_essential
            ;;
        install_vimrc)
            install_vimrc
            ;;
        install_oh_my_zsh)
            install_oh_my_zsh
            ;;
        install_tmux)
            install_tmux
            ;;
        install_nvm)
            install_nvm
            ;;
        install_dotnet)
            install_dotnet
            ;;
        install_go)
            install_go
            ;;
        install_rust)
        install_rust
            ;;
        install_azure_cli)
        install_azure_cli
        ;;
        install_aws_cli)
        install_aws_cli
        ;;
        install_docker)
        install_docker
        ;;
        install_kubectl)
        install_kubectl
        ;;
        install_jupyterlab)
        install_jupyterlab
        add_aliases
        ;;
        install_network_performance_tools)
        install_network_performance_tools
        ;;
        help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
}

# Check if any command-line arguments were provided
if [ $# -eq 0 ]; then
    usage
else
    handle_option $1
fi

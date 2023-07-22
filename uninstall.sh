#!/usr/bin/env bash

# @file uninstall.sh
# @bried uninstall script for all changes

# @description uninstall all the vimrc configuration but save backup
uninstall_vimrc(){
    rm -rf ~/.vim_runtime
    cp ~/.vimrc ~/.vimrc.backup
    rm -rf ~/.vimrc
}

# @description uninstall all the tmux configuration but save backup
uninstall_tmux(){
    cp ~/.tmux.conf ~/.tmux.conf.backup
    rm -rf .tmux.conf
}

# @description uninstall oh-my-zsh
uninstall_oh-my-zsh(){
    zsh -c -i "uninstall_oh-my-zsh"
}

# @description Uninstall JDK
uninstall_jdk() {
    echo "Uninstalling JDK..."

    # Check if JDK is installed
    if type -p java > /dev/null; then
        echo "JDK is installed. Proceeding with uninstallation..."

        # Uninstall JDK
        sudo apt-get purge openjdk-\* icedtea-\* icedtea6-\*
        sudo apt-get autoremove

        echo "JDK has been uninstalled."
    else
        echo "JDK is not installed."
    fi
}

# @description Uninstall Python
uninstall_python() {
    echo "Uninstalling Python..."

    # Check if Python is installed
    if type -p python > /dev/null; then
        echo "Python is installed. Proceeding with uninstallation..."

        # Uninstall Python
        sudo apt-get purge python3.\*
        sudo apt-get autoremove

        echo "Python has been uninstalled."
    else
        echo "Python is not installed."
    fi
}

# @description Uninstall Rust
uninstall_rust() {
    echo "Uninstalling Rust..."

    # Check if Rust is installed
    if type -p rustc > /dev/null; then
        echo "Rust is installed. Proceeding with uninstallation..."

        # Uninstall Rust
        rustup self uninstall -y

        echo "Rust has been uninstalled."
    else
        echo "Rust is not installed."
    fi
}

# @description Uninstall Go
uninstall_go() {
    echo "Uninstalling Go..."

    # Check if Go is installed
    if type -p go > /dev/null; then
        echo "Go is installed. Proceeding with uninstallation..."

        # Uninstall Go
        sudo rm -rf /usr/local/go

        echo "Go has been uninstalled."
    else
        echo "Go is not installed."
    fi
}

# @description Uninstall Jupyter
uninstall_jupyter() {
    echo "Uninstalling Jupyter..."

    # Check if Jupyter is installed
    if type -p jupyter > /dev/null; then
        echo "Jupyter is installed. Proceeding with uninstallation..."

        # Uninstall Jupyter
        pip uninstall jupyter

        echo "Jupyter has been uninstalled."
    else
        echo "Jupyter is not installed."
    fi
}

# @description Uninstall AWS CLI
uninstall_aws_cli() {
    echo "Uninstalling AWS CLI..."

    # Check if AWS CLI is installed
    if type -p aws > /dev/null; then
        echo "AWS CLI is installed. Proceeding with uninstallation..."

        # Uninstall AWS CLI
        pip uninstall awscli

        echo "AWS CLI has been uninstalled."
    else
        echo "AWS CLI is not installed."
    fi
}

# @description Uninstall Azure CLI
uninstall_azure_cli() {
    echo "Uninstalling Azure CLI..."

    # Check if Azure CLI is installed
    if type -p az > /dev/null; then
        echo "Azure CLI is installed. Proceeding with uninstallation..."

        # Uninstall Azure CLI
        sudo apt-get remove azure-cli
        sudo apt-get autoremove

        echo "Azure CLI has been uninstalled."
    else
        echo "Azure CLI is not installed."
    fi
}

# @description Uninstall NVM
uninstall_nvm() {
    echo "Uninstalling NVM..."

    # Check if NVM is installed
    if type -p nvm > /dev/null; then
        echo "NVM is installed. Proceeding with uninstallation..."

        # Uninstall NVM
        rm -rf "$HOME/.nvm"
        sed -i '/nvm/d' "$HOME/.bashrc"
        sed -i '/nvm/d' "$HOME/.bash_profile"
        sed -i '/nvm/d' "$HOME/.zshrc"

        echo "NVM has been uninstalled."
    else
        echo "NVM is not installed."
    fi
}

uninstall_vimrc
uninstall_tmux
uninstall_oh_my_zsh
uninstall_jdk
uninstall_rust
uninstall_go
uninstall_jupyter
uninstall_aws_cli
uninstall_azure_cli
uninstall_nvm

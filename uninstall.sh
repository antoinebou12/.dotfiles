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


uninstall_vimrc
uninstall_tmux
uninstall_oh_my_zsh
uninstall_jdk
uninstall_rust
uninstall_go

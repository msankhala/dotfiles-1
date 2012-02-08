#! /usr/bin/env bash

#
# Configuration
#

TARGET="$HOME"
DOTFILES_LINK=".dotfiles"
SYMLINK_PATH="$DOTFILES_LINK"
PRIVATE_PATH="private"
SYMLINKS=(bundle emacs.d erlang gemrc gitconfig gitignore hgrc irbrc \
    powconfig rspec tmux.conf)
LOAD_FILES=(profile zprofile)

#
# Main Functions
#

install_symlinks () {
    # Symlink dotfiles root
    symlink "$ROOT_PATH" "$TARGET/$DOTFILES_LINK"

    # Setup private dotfiles
    local private_rakefile="$ROOT_PATH/$PRIVATE_PATH/Rakefile"
    if [ -f "$private_rakefile" ]; then
        rake --rakefile="$private_rakefile" symlink
    fi

    # Symlink each path
    for i in ${SYMLINKS[@]}; do
        symlink "$SYMLINK_PATH/$i" "$TARGET/.$i"
    done

    # Symlink shell init file for bash and zsh
    for i in ${LOAD_FILES[@]}; do
        symlink "$DOTFILES_LINK/load_shellrc.sh" "$TARGET/.$i"
    done
}

install_homebrew () {
    /usr/bin/ruby -e "$(curl -fsSL https://raw.github.com/gist/323731)"
}

install_rbenv () {
    git_clone 'git://github.com/sstephenson/rbenv.git' "$TARGET/.rbenv"
}

isntall_nvm () {
    git_clone 'https://github.com/creationix/nvm.git' "$TARGET/.nvm"
}

install_virtualenv () {
    curl -s https://raw.github.com/brainsik/virtualenv-burrito/master/virtualenv-burrito.sh | bash
}


#
# Initial Setup
#

if [ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ] ; then
    ROOT_PATH=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
elif [ -n "$0" ] && [ -f "$0" ]; then
    ROOT_PATH=$(cd "$(dirname "$0")" && pwd)
else
    echo "[ERROR] Can't determine dotfiles' root path."
    exit 1
fi


#
# Helper functions
#

symlink() {
    if [ ! -e "$2" ]; then
        echo "   symlink: $2 --> $1"
        ln -s "$1" "$2"
    else
        echo "    exists: $2"
    fi
}

git_clone () {
    if [ ! -e "$2" ]; then
        git clone "$1" "$2"
    else
        echo "[ERROR] $2 already exists"
    fi
}


#
# Argument Handling
#

case "$1" in
    symlinks|links)
        install_symlinks
        ;;
    homebrew|brew)
        install_homebrew
        ;;
    rbenv)
        install_rbenv
        ;;
    nvm)
        install_nvm
        ;;
    virtualenv|venv)
        install_virtualenv
        ;;
    info)
        echo "Target directory: $TARGET"
        echo "Detected dotfiles root: $ROOT_PATH"
        ;;
    *)
        echo 'usage: ./install.sh [command]'
        echo ''
        echo 'Available commands:'
        echo '       info: Target and source directory info.'
        echo '   symlinks: Install symlinks for various dotfiles into' \
             'target directory.'
        echo '   homebrew: Install Homebrew (Mac OS X only).'
        echo '      rbenv: Install rbenv, a Ruby version manager.'
        echo '        nvm: Install nvm, a Node.js version manager.'
        echo ' virtualenv: Install virtualenv-burrito, a Python version and' \
             'environment manager.'
        ;;
esac

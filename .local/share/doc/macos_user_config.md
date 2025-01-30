# macOS user environment setup

## Setup process

1. Install and activate Homebrew.
    ```sh
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval $(/opt/homebrew/bin/brew shellenv)
    ```
1. Clone the configuration setup repository and change the directory to it.
    ```sh
    git clone https://github.com/andis-sprinkis/nix-user-config $HOME/nix-user-config
    cd $HOME/nix-user-config/.local/share/pkg_list/macos
    ```
1. Install Homebrew packages.
    ```sh
    [ -s ./brew_tap ] && brew tap $(cat ./brew_tap | paste -s -d ' ' -)
    [ -s ./brew ] && brew install $(cat ./brew | paste -s -d ' ' -)
    [ -s ./brew_cask ] && brew install --cask $(cat ./brew_cask | paste -s -d ' ' -)
    ```
1. Install user general configuration.
    ```sh
    mkdir -p "$HOME/.local/state"
    git_url_cfg="https://github.com/andis-sprinkis/nix-user-config"
    dir_cfg_git="$HOME/.local/state/dotfiles_git"
    temp_path=$(mktemp -d)
    git clone --separate-git-dir=$dir_cfg_git $git_url_cfg $temp_path
    rsync --recursive --verbose --exclude '.git/' $temp_path/ $HOME
    git --git-dir=$dir_cfg_git --work-tree=$HOME config --local status.showUntrackedFiles no
    git --git-dir=$dir_cfg_git --work-tree=$HOME submodule update --init
    ```
1. Install npm packages.
    ```sh
    export VOLTA_HOME="$HOME/.local/share/volta"
    PATH="$VOLTA_HOME/bin:$PATH"
    cd $HOME/nix-user-config/.local/share/pkg_list/macos
    [ -s ./npm ] && volta install $(cat ./npm | paste -s -d ' ' -)
    ```
1. Install PyPi packages.
    ```sh
    [ -s ./pypi ] && for p in $(cat ./pypi | paste -s -d ' ' -); do pipx install $p; done
    ```
1. Install user Neovim configuration.
    ```sh
    cd $HOME/.config
    git clone https://github.com/andis-sprinkis/nvim-user-config nvim
    ```

1. Close any Sytem Preferences windows.
    ```sh
    osascript -e 'tell application "System Preferences" to quit'
    ```

1. Enable the keyboard navigation.

    ```sh
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
    ```

1. Disable displaying the accents menu on keyboard key hold.

    ```sh
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    ```

1. Increase the keyboard key repetition rate.
    1. ```sh
       defaults write -g ApplePressAndHoldEnabled -bool false
       defaults write -g InitialKeyRepeat -int 9
       defaults write -g KeyRepeat -int 1
       ```
    1. Log out and log in.

1. Configure Finder.

    ```sh
    # Enable displaying the hidden files
    defaults write com.apple.Finder AppleShowAllFiles true

    # Enable displaying all file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Enable the path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Enable long path in the title bar
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Set the column view as the default
    defaults write com.apple.finder FXPreferredViewStyle -string clmv

    # Keep the directories on top
    defaults write com.apple.finder _FXSortFoldersFirst -bool true

    # Disable the file extenion change warning
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Allow text selection in Quick Look
    defaults write com.apple.finder QLEnableTextSelection -bool true

    # Set the sidebar icon size to the largest
    defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 3

    # Show the $HOME/Library directory
    chflags nohidden ~/Library

    # Expand the File Info window panes
    defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true
    # Reload Finder
    killall Finder
    ```

1. Configure Dock.

    ```sh
    # Don't show the recent applications
    defaults write com.apple.dock show-recents -bool false

    ```

1. Configure TextEdit.

    ```sh
    # Use the plain-text mode by default
    defaults write com.apple.TextEdit RichText -int 0

    # Use UTF-8 encoding
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

    # Set the text indentation width to 2 spaces
    defaults write com.apple.TextEdit TabWidth 2
    ```

1. Disable the animations.
    ```sh
    # The Finder windows animations and the 'Get Info' animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Showing and hiding Dock
    defaults write com.apple.dock autohide-time-modifier -float 0
    defaults write com.apple.dock autohide-delay -float 0

    # Showing and hiding Mission Control
    defaults write com.apple.dock expose-animation-duration -float 0

    # Showing and hiding LaunchPad
    defaults write com.apple.dock springboard-show-duration -float 0
    defaults write com.apple.dock springboard-hide-duration -float 0

    # Changing the pages in LaunchPad
    defaults write com.apple.dock springboard-page-duration -float 0

    # Scrolling column views
    defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0

    # Showing a toolbar or menu in full-screen
    defaults write -g NSToolbarFullScreenAnimationDuration -float 0

    # Reload Dock
    killall Dock

    # Reload Finder
    killall Finder
    ```

## Addition of newly listed packages to an existing setup

Steps for adding any newly listed packages from the user package lists to an already existing setup.

1. Change directory to the one with the user package lists.
    ```sh
    cd $HOME/.local/share/pkg_list/macos
    ```
1. Add the packages from the respective source lists.

    - Homebrew:

        - Upgrade existing packages.
            ```sh
            brew update
            brew upgrade
            ```
        - Sync with the package lists.
            ```sh
            brew tap $(cat "./brew_tap" | paste -s -d ' ' -)
            brew install $(cat "./brew" | paste -s -d ' ' -)
            brew install --cask $(cat "./brew_cask" | paste -s -d ' ' -)
            ```

    - PyPI:

        - Upgrade existing packages.
            ```sh
            pipx upgrade-all
            ```
        - Sync with the package list.
            ```sh
            for p in $(cat "./pypi" | paste -s -d ' ' -); do pipx install "$p"; done
            ```

    - npm:

        ```sh
        volta install $(cat "./npm" | paste -s -d ' ' -)
        ```

## Resources

- [macOS defaults list](https://macos-defaults.com/)
- [Prefs Editor](https://apps.tempel.org/PrefsEditor/)

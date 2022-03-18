#!/bin/sh

# Not Ready
echo "Not ready"
exit 0
#########################################################################################################################################
# Credits:
# Portions of this script will have snippets from scripts created by different MacAdmins Honchos such as:
#             
#             1. @rtrouton -  https://github.com/rtrouton/rtrouton_scripts/tree/main/rtrouton_scripts/install_rosetta_on_apple_silicon
#             2. @GrahamRPugh - https://github.com/grahampugh/erase-install for the depnotify workflows and macadmins python3 frameworks.
#             4. @argon - https://github.com/argon - For creating the mac app store CLI
# 
# If you see something written by someone i havent given credit, just open an issue and ill add you promptly.
# Special Thanks to @MasterKale - https://github.com/MasterKale Someone had to teach the kid macOS tricks and being a true friend.
########################################################################################################################################

# variables - this is a mess later to get it pretty or whatever
echo [Setting up Variables]

currentUser=$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )
model=$(ioreg -l | grep "product-name" | cut -d ""="" -f 2 | sed -e 's/[^[:alnum:]]//g' | sed 's/[0-9]//g' | sed 's/inch//g')
tag="b2-"
serial=$(ioreg -l | grep "IOPlatformSerialNumber" | cut -d ""="" -f 2 | sed -e 's/[^[:alnum:]]//g') 
tld="bytesandbeans.dev"
log_path="~/.logs"
log_file="com.$currentUser.macos.mac_setup.log"

########################################################################################################################################
# Establish standardized local logging logic - Patent Pending

logMessage () {

  mkdir -p $log_path

  date_set="$( (date +%Y-%m-%d..%H:%M:%S-%z) 2>&1)"
  user="$( (who -m | awk '{print $1;}') 2>&1)"
  if [ "$log_file" = "" ]; then
    # write to stdout (capture by Jamf script logging)
    echo "$date_set    $user    ${0##*/}    $1"
  else
    # write local logs
    echo "$date_set    $user    ${0##*/}    $1" >> $log_path/$log_file
    # write to stdout (capture by Jamf script logging)
    echo "$date_set    $user    ${0##*/}    $1"
  fi
}

########################################################################################################################################

logMessage "Requesting sudo elevation before proceeding"
sudo -v
# Keep-alive: update existing sudo time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
echo ✅ Done

logMessage "Giving this mac a name!"
/usr/sbin/scutil --set LocalHostName "${tag}${serial}" && /usr/sbin/scutil --set ComputerName "${tag}${serial}" && /usr/sbin/scutil --set HostName "${tag}${serial}.${tld}"
echo "$model"
echo "$tag$serial"
echo "${tag}${serial}.${tld}"
echo ✅ Done

# Apple Silicon/Rosetta 2 Check & Install
logMessage "Check for Apple Silicon and Rosetta 2 to be present, install if it's missing"
cat > /Library/$currentUser/Scripts/rosetta2_checkinstall.sh << 'EOF'
#!/bin/sh

# is this an ARM Mac?
arch=$(/usr/bin/arch)
if [ "$arch" == "arm64" ]; then
# is rosetta 2 installed?
if /usr/bin/pgrep oahd >/dev/null 2>&1; then
result="installed"
else
result="missing"
softwareupdate --install-rosetta --agree-to-license
fi
else
result="ineligible"
fi
echo "<result>$result</result>"
EOF

########
#
# Setting up macOS
#
########

#Setting menubar and dock to dark mode
logMessage "Setting menubar and dock to dark mode"
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

# Placing Hardrive Icon on Desktop
logMessage "Placing Hardrive Icon on Desktop"
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true

# Set fast key repeat rate
logMessage "Set fask key repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 0

# Require password as soon as screensaver or sleep mode starts
logMessage "Require password as soon as screensaver or sleep mode starts"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
logMessage "Show filename extensions by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Enable tap-to-click
logMessage "Enable tap-to-click"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Setting screenshots to save to ~/Screenshots
logMessage "Setting screenshots to save to ~/Screenshots"
mkdir ~/Screenshots
defaults write com.apple.screencapture location ~/Screenshots

# Creating ~/Repos folder
logMessage "Creating ~/Repos folder"
mkdir ~/Repos

# Disabling shadows on full-screen screenshots
logMessage "Disabling shadows on full-screen screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

# Showing status bar in Finder
logMessage "Showing status bar in Finder"
defaults write com.apple.finder ShowStatusBar -bool true

# Setting hidden files to always appear in Finder
logMessage "Setting hidden files to always appear in Finder"
defaults write com.apple.finder AppleShowAllFiles -bool true

# Showing all file extensions
logMessage "Showing all file extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Setting new Finder windows to start in '$Home'
logMessage "Setting new Finder windows to start in '$Home'"
defaults write com.apple.finder NewWindowTarget -string "PfLo"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Keep folders on top when sorting by name
logMessage "Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# Show full path in Finder window title
logMessage "Show full path in Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Restarting Finder
logMessage "Restarting Finder"
killall Finder

# Setting up top-left hot corner to activate Mission Control
logMessage "Setting up top-left hot corner to activate Mission Control"
defaults write com.apple.dock wvous-tl-corner -int 2
defaults write com.apple.dock wvous-tl-modifier -int 0
killall Dock

# Setting Terminal to default to Homebrew
logMessage "Setting Terminal to default to Homebrew"
defaults write com.apple.Terminal "Default Window Settings" -string Homebrew
defaults write com.apple.Terminal "Startup Window Settings" -string Homebrew

# Enabling indicator lights for open applications in the Dock
logMessage "Enabling indicator lights for open applications in the Dock"
defaults write com.apple.dock show-process-indicators -bool true

# Enabling indicator lights for open applications in the Dock
logMessage "Grouping windows by application in Mission Control"
defaults write com.apple.dock expose-group-by-app -bool true

# Disabling the Mission Control Dashboard
logMessage Disabling the Mission Control Dashboard
defaults write com.apple.dashboard mcx-disabled -bool true

# Disabling rearranging Mission Control Spaces based on most recent use
logMessage "Disabling rearranging Mission Control Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

########
#
# Bringing the Pandaren Brew Master
#
########

# Requesting sudo elevation before proceeding
logMessage "Requesting sudo elevation before proceeding"
sudo -v

# install xcode CLI
xcode-select —-install
logMessage "Xcode CLI Installation - Done"

# Installing Brew.sh - Check for Homebrew to be present, install if it's missing
# if test ! $(which brew); then
#    echo "Installing homebrew..."
#    logMessage "Brew.sh not found, installing"
#    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# fi

# Autobots Rollout... I mean Autobrew... Automating brew.sh install
logMessage "Running Autobrew so we can automate brew.sh install"
cat > /Library/$currentUser/Scripts/autobrew.sh << 'EOF'
#!/bin/sh
# AutoBrew - Install Homebrew with root
# Source: https://github.com/kennyb-222/AutoBrew/
# Author: Kenny Botelho
# Version: 1.2

# Set environment variables
HOME="$(mktemp -d)"
export HOME
export USER=root
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
BREW_INSTALL_LOG=$(mktemp)

# Get current logged in user
TargetUser=$(echo "show State:/Users/ConsoleUser" | \
    scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }')

# Check if parameter passed to use pre-defined user
if [ -n "$3" ]; then
    # Supporting running the script in Jamf with no specialization via Self Service
    TargetUser=$3
elif [ -n "$1" ]; then
    # Fallback case for the command line initiated method
    TargetUser=$1
fi

# Ensure TargetUser isn't empty
if [ -z "${TargetUser}" ]; then
    /bin/echo "'TargetUser' is empty. You must specify a user!"
    exit 1
fi

# Verify the TargetUser is valid
if /usr/bin/dscl . -read "/Users/${TargetUser}" 2>&1 >/dev/null; then
    /bin/echo "Validated ${TargetUser}"
else
    /bin/echo "Specified user \"${TargetUser}\" is invalid"
    exit 1
fi

# Install Homebrew | strip out all interactive prompts
/bin/bash -c "$(curl -fsSL \
    https://raw.githubusercontent.com/Homebrew/install/master/install.sh | \
    sed "s/abort \"Don't run this as root\!\"/\
    echo \"WARNING: Running as root...\"/" | \
    sed 's/  wait_for_user/  :/')" 2>&1 | tee "${BREW_INSTALL_LOG}"

# Reset Homebrew permissions for target user
brew_file_paths=$(sed '1,/==> This script will install:/d;/==> /,$d' \
    "${BREW_INSTALL_LOG}")
brew_dir_paths=$(sed '1,/==> The following new directories/d;/==> /,$d' \
    "${BREW_INSTALL_LOG}")
# Get the paths for the installed brew binary
brew_bin=$(echo "${brew_file_paths}" | grep "/bin/brew")
brew_bin_path=${brew_bin%/brew}
# shellcheck disable=SC2086
chown -R "${TargetUser}":admin ${brew_file_paths} ${brew_dir_paths}
chgrp admin ${brew_bin_path}/
chmod g+w ${brew_bin_path}

# Unset home/user environment variables
unset HOME
unset USER

# Finish up Homebrew install as target user
su - "${TargetUser}" -c "${brew_bin} update --force"

# Run cleanup before checking in with the doctor
su - "${TargetUser}" -c "${brew_bin} cleanup"

# Check for post-installation issues with "brew doctor"
doctor_cmds=$(su - "${TargetUser}" -i -c "${brew_bin} doctor 2>&1 | grep 'mkdir\|chown\|chmod\|echo\|&&'")

# Run "brew doctor" remediation commands
if [ -n "${doctor_cmds}" ]; then
    echo "\"brew doctor\" failed. Attempting to repair..."
    while IFS= read -r line; do
        echo "RUNNING: ${line}"
        if [[ "${line}" == *sudo* ]]; then
            # run command with variable substitution
            cmd_modified=$(su - "${TargetUser}" -c "echo ${line}")
            ${cmd_modified}
        else
            # Run cmd as TargetUser
            su - "${TargetUser}" -c "${line}"
        fi
    done <<< "${doctor_cmds}"
fi

# Check Homebrew install status, check with the doctor status to see if everything looks good
if su - "${TargetUser}" -i -c "${brew_bin} doctor"; then
    echo 'Homebrew Installation Complete! Your system is ready to brew.'
    exit 0
else
    echo 'AutoBrew Installation Failed'
    exit 1
fi
EOF


# Update brew.sh recipes
logMessage "Updating brew.sh recipes"
brew update
brew tap homebrew/cask
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

PACKAGES=(
    bat
    ctags
    discord
    docker
    eqmac
    figlet
    firefox
    font-cascadia-code-pl
    font-fira-code
    fzf
    git
    github
    google-chrome
    homebrew/cask-fonts
    istat-menus
    kdiff3
    lolcat
    mackup
    macvim
    mas
    microsoft-edge
    notable
    nvm
    piezo
    pipenv
    pyenv
    python3
    qlimagesize
    qlvideo
    quicklook-csv
    quicklook-json
    readline
    setapp
    slack
    soundsource
    teamviewer
    visual-studio-code
    webpquicklook
    zotero

)
echo "Installing packages..."
brew install ${PACKAGES[@]}
# any additional steps you want to add here
# link readline
brew link --force readline

###
#
# Mac App Store Applications (requires mas: https://github.com/mas-cli/mas)
#
###

logMessage "Installing Affinity Designer"
mas install 824171161

logMessage "Installing Affinity Photo"
mas install 824183456

logMessage "Installing Affinity Publisher"
mas install 881418622

logMessage "Installing JumpDesktop"
mas install 524141863

logMessage "Installing Magnet"
mas install 441258766

logMessage "Installing Pixelmator Pro"
mas install 1289583905

logMessage "Installing Termius"
mas install 1176074088

logMessage " Microsoft 365"
mas install 462054704 # Word
mas install 462058435 # Excel
mas install 462062816 # PowerPoint
mas install 985367838 # Outlook
mas install 784801555 # OneNote
mas install 823766827 # OneDrive
mas install 1274495053 # To Do

logMessage "Installing Bandwidth+"
mas install 490461369

logMessage "Installing MindNode - Mind Map & Outline"
mas install 1289197285

logMessage "Installing Xcode"
mas install 497799835

###
#
# Config Files
#
###

# TODO: Figure out if we can eliminate the password prompt here
echo /usr/local/bin/zsh | sudo tee -a /etc/shells

# Installing Oh My Zsh and setting ZSH as default shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Installing powerlevel10k ZSH theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.oh-my-zsh/custom/themes/powerlevel10k

# Add symbolic links to the dotfiles in this directory
source $(pwd)/add_symlinks.sh

###
#
# Post-Setup Steps
#
###

# Setting up Mackup and backing up your preferences to iCloud
logMessage "Creating ~/.mackup.cfg"
cat > ~/.mackup.cfg << 'EOF'
[storage]
engine = icloud
EOF

logMessage "Backing your preferences"
mackup backup

# This will create a Brewfile of everything Bundle recognizes on your existing system.
# It will be in /Users/$currentUser
brew bundle dump

echo "SETUP COMPLETE!"
logMessage "SETUP COMPLETE!"
echo REBOOTING YOUR MAC!
logMessage "REBOOTING YOUR MAC!"
echo ✅ Done

echo "Taking a short 5s break before restart"
sleep 5
shutdown -r now

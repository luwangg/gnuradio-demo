#!/bin/sh

# Based on the Nix install script
# This script installs Nix, Cachix and Dapptools

{ # Prevent execution if this script was only partially downloaded

  set -e
  
  oops() {
    echo >&2 "${0##*/}: error:" "$@"
    exit 1
  }

  if [ "$(id -u)" -eq 0 ]; then
    oops 'please run this script as a regular user'
  fi

  if [ -z "$HOME" ]; then
    oops "\$HOME is not set"
  fi

  have() { command -v "$1" >/dev/null; }

  { have nixos-version; } && {
    os="NixOS"
    echo "We love that you are running NixOS! <3"
    echo "We're working on having this script work on NixOS, but for the moment"
    echo "go to https://dapphub.chat/channel/dev for instructions."
    exit 1
  }

  { have git; } || oops 'you need to install Git before running this script'

  os=$(uname -s)

  { have nix; } || {
    echo "Dapptools uses the Nix package manager to install programs behind the scenes."
    echo "Installing Nix now, this will take a few minutes."
    echo "You may be asked for your sudo password."
    # echo "Press any key to install Nix (you may be asked for sudo password)"

    curl -sS https://nixos.org/nix/install | sh >/dev/null 2>/dev/null

    if [ "$os" = Darwin ]; then
      { grep "trusted-users = root $USER" /etc/nix/nix.conf; } || {
        echo "Adding $USER as a trusted Nix user..."
        echo "You may need to provide your sudo password"
        echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
      }
      p="/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
    else
      p="$HOME/.nix-profile/etc/profile.d/nix.sh"
    fi
    # shellcheck source=/dev/null
    . "$p"
    echo "Nix installation succeded!"
  }

  # Add Cachix caches to nix.conf


  
  echo "Adding Cachix binary cache to Nix"


  if [ "$os" = Darwin ];  then
    echo "# added by Dapptools installer" | sudo tee -a /etc/nix/nix.conf
    echo "substituters = https://cache.nixos.org https://dapp.cachix.org" | sudo tee -a /etc/nix/nix.conf
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= dapp.cachix.org-1:9GJt9Ja8IQwR7YW/aF0QvCa6OmjGmsKoZIist0dG+Rs=" | sudo tee -a /etc/nix/nix.conf
    echo "Relaunching nix-daemon"
    sudo launchctl kickstart -k system/org.nixos.nix-daemon
  else
    mkdir -p "$HOME/.config/nix"
    dest="$HOME/.config/nix/nix.conf"
    echo "# added by Dapptools installer" | tee -a "$dest"
    echo "substituters = https://cache.nixos.org https://dapp.cachix.org" | tee -a "$dest"
    echo "trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= dapp.cachix.org-1:9GJt9Ja8IQwR7YW/aF0QvCa6OmjGmsKoZIist0dG+Rs=" | tee -a "$dest"
  fi

  dest="$HOME/.dapp/"

  if [ ! -d "$dest/dapptools" ]; then
    echo "Downloading dapptools..."
    mkdir -p "$dest"
    cd "$dest"
    git clone https://github.com/dapphub/dapptools --recursive --quiet
  fi

  cd "$dest/dapptools" || {
    oops "could not download dapptools!"
  }

  git submodule update --init --remote --quiet
  git pull --quiet

  echo "Installing dapptools..."
  nix-env -Q -f . -iA dapp seth solc hevm ethsign >/dev/null 2>/dev/null

  # Finished!
  if [ "$os" = Darwin ];  then
    cat >&2 <<EOF

Installation finished!

You now have access to dapp, seth, solc, hevm and ethsign.

Please open a new terminal to start using dapptools!
EOF
  else
    cat >&2 <<EOF

Installation finished!

You now have access to dapp, seth, solc, hevm and ethsign.

Please logout and log back in to start using dapptools, or run

    . "$HOME/.nix-profile/etc/profile.d/nix.sh"

in this terminal.
EOF
  fi

} # End of wrapping

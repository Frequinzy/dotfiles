# My Dotfiles

Welcome to my dotfiles!

I've created them for personal use but feel free to browse while you're here!

## How to use

First of all git (`git`) is required to clone the repo

```git clone git@github.com:Frequinzy/dotfiles.git```

Navigate to the newly created directory

```cd dotfiles```

Secondly GNU Stow (`stow`) is used to symlink the config to the appropriate location.

The dotfiles are modular, to get the config for a certain program e.g. `nvim` execute the following command in the directory

```stow nvim -t ~```

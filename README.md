# macos_setup

You nuked your Mac and reinstalled the Monterey and now you have to spend some time installing all the apps you use in order to get back to your whatever state of prodution you need to be.

Not to worry, I got you covered.  **macos_setup** is a complete and modifiable set of config files to maintain UX accross your device, and setup process using `brew` and `mas` simplifying the  initial setup of a new mac.

## Instructions

1. Clone this repo into **~**:

```sh
$> cd ~
$> git clone https://github.com/TempusThales/macos_setup
```
2. Navigate to the **~/macos_setup/** folder:

```sh
$> cd ~/macos_setup
```

3. Add permissions to execute the script
```sh
$> chmod a+x macos_setup.sh
```

4. Run macos_setup.sh
```sh
$> ./macos_setup.sh
```

## Manually linking individual dotfiles

If it's preferable to manually move a dotfile into place, opt for a **symbolic link** instead of a copy->paste.

For example, to move the **.zshrc** file into its rightful place in **~**, run the following:

```sh
$> ln -sv "$HOME/dotfiles/.zshrc" $HOME
```

Alternatively, you can run **add_symlinks.sh** to automate things:

```sh
$> source add_symlinks.sh
```

## Miscellaneous Notes

### Benchmarking ZSH/Bash/etc... startup times

@MasterKale: I was troubleshooting some slowness in ZSH startup when I came across this handy command:

```sh
$> for i in $(seq 1 10); do /usr/bin/time $SHELL -i -c exit; done
```

This command will log the amount of time it takes to initialize the shell 10 times:

```
0.29 real         0.16 user         0.11 sys
0.28 real         0.16 user         0.10 sys
0.28 real         0.16 user         0.10 sys
0.28 real         0.16 user         0.10 sys
0.32 real         0.17 user         0.11 sys
0.30 real         0.17 user         0.11 sys
0.28 real         0.16 user         0.10 sys
0.28 real         0.16 user         0.10 sys
0.28 real         0.16 user         0.10 sys
0.29 real         0.16 user         0.10 sys
```

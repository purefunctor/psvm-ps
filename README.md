# psvm-ps
PureScript version management in PureScript, expanding upon [psvm-js](https://github.com/ThomasCrevoisier/psvm-js).

Installs files under `$HOME/.psvm`, and as such, this tool currently only supports Linux given that I don't have access to Windows/MacOS environments. Pull requests to add compatibility for these two operating systems is welcome.

```sh
$ psvm
psvm-ps
    PureScript version management in PureScript.

    --help,-h        Show this help message.
    --version,-v     Show the installed psvm-ps version.

    clean            Clean downloaded artifacts.
    install          Install a PureScript version.
    ls               List PureScript versions.
    uninstall        Uninstall a PureScript version.
    use              Use a PureScript version.
```

## Installation
```sh
$ npm install -g psvm-ps
```

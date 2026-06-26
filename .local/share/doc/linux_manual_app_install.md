# Applications that require manual installation on Arch Linux

## `adwaita-qt`

- [FedoraQt/adwaita-qt: A style to bend Qt applications to look like they belong into GNOME Shell](https://github.com/FedoraQt/adwaita-qt)
- [Releases · FedoraQt/adwaita-qt](https://github.com/FedoraQt/adwaita-qt/releases)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=adwaita-qt)

Requires:

- Build:

    ```
    cmake qt5-x11extras qt6-base
    ```

Installation:

```sh
mkdir "/tmp/adwaita-qt-install"
cd "/tmp/adwaita-qt-install"

curl -L "https://github.com/FedoraQt/adwaita-qt/archive/refs/tags/1.4.2.tar.gz" -o "./archive.tar.gz"
echo "cd5fd71c46271d70c08ad44562e57c34e787d6a8650071db115910999a335ba8  archive.tar.gz" | sha256sum -c

tar -xvzf "./archive.tar.gz"

cmake -B "build-qt5" -S"adwaita-qt-1.4.2" -DCMAKE_INSTALL_PREFIX="/usr" -DUSE_QT6="OFF"
cmake --build "build-qt5"
sudo cmake --install "build-qt5"

cmake -B "build-qt6" -S"adwaita-qt-1.4.2" -DCMAKE_INSTALL_PREFIX="/usr" -DUSE_QT6="ON"
cmake --build "build-qt6"
sudo cmake --install "build-qt6"

cd "$HOME"
rm -rf "/tmp/adwaita-qt-install"
```

Removal:

```sh
#!/usr/bin/env sh
set -euf

# build-qt5
sudo rm "/usr/lib/libadwaitaqtpriv.so.1.4.2"
sudo rm "/usr/lib/libadwaitaqtpriv.so.1"
sudo rm "/usr/lib/libadwaitaqtpriv.so"
sudo rm "/usr/lib/libadwaitaqt.so.1.4.2"
sudo rm "/usr/lib/libadwaitaqt.so.1"
sudo rm "/usr/lib/libadwaitaqt.so"
sudo rm "/usr/include/AdwaitaQt/adwaita.h"
sudo rm "/usr/include/AdwaitaQt/adwaitacolors.h"
sudo rm "/usr/include/AdwaitaQt/adwaitarenderer.h"
sudo rm "/usr/include/AdwaitaQt/adwaitaqt_export.h"
sudo rm "/usr/lib/pkgconfig/adwaita-qt.pc"
sudo rm "/usr/lib/cmake/AdwaitaQt/AdwaitaQtConfig.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt/AdwaitaQtConfigVersion.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt/AdwaitaQtTargets.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt/AdwaitaQtTargets-noconfig.cmake"
sudo rm "/usr/lib/qt/plugins/styles/adwaita.so"
# build-qt6
sudo rm "/usr/lib/libadwaitaqt6priv.so.1.4.2"
sudo rm "/usr/lib/libadwaitaqt6priv.so.1"
sudo rm "/usr/lib/libadwaitaqt6priv.so"
sudo rm "/usr/lib/libadwaitaqt6.so.1.4.2"
sudo rm "/usr/lib/libadwaitaqt6.so.1"
sudo rm "/usr/lib/libadwaitaqt6.so"
sudo rm "/usr/include/AdwaitaQt6/adwaita.h"
sudo rm "/usr/include/AdwaitaQt6/adwaitacolors.h"
sudo rm "/usr/include/AdwaitaQt6/adwaitarenderer.h"
sudo rm "/usr/include/AdwaitaQt6/adwaitaqt_export.h"
sudo rm "/usr/lib/pkgconfig/adwaita-qt6.pc"
sudo rm "/usr/lib/cmake/AdwaitaQt6/AdwaitaQt6Config.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt6/AdwaitaQt6ConfigVersion.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt6/AdwaitaQt6Targets.cmake"
sudo rm "/usr/lib/cmake/AdwaitaQt6/AdwaitaQt6Targets-noconfig.cmake"
sudo rm "/usr/lib/qt6/plugins/styles/adwaita.so"
```

or

```sh
# ...
cd "/tmp/adwaita-qt-install/build-qt5"
sudo xargs -a "install_manifest.txt" "rm"

cd "/tmp/adwaita-qt-install/build-qt6"
sudo xargs -a "install_manifest.txt" "rm"

cd "$HOME"
rm -rf "/tmp/adwaita-qt-install"
```

## `ansifilter`

- [André Simon / ansifilter · GitLab](https://gitlab.com/saalen/ansifilter/)
- [Releases · André Simon / ansifilter · GitLab](https://gitlab.com/saalen/ansifilter/-/releases)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ansifilter)

Requires:

```
glibc gcc-libs
```

Installation:

```sh
mkdir "/tmp/ansifilter-install"
cd "/tmp/ansifilter-install"

curl -L "https://gitlab.com/saalen/ansifilter/-/archive/2.22/ansifilter-2.22.tar.gz" -o "./archive.tar.gz"
echo "cf5b95564d95d398e78071f147ee3cbf850e6dc8226a86ecff2de4356f19ff66  archive.tar.gz" | sha256sum -c

tar -xvzf "./archive.tar.gz"

cd "./ansifilter-2.22"
make "all"
sudo "make" "install"

cd "$HOME"
rm -rf "/tmp/ansifilter-install"
```

Removal:

```sh
sudo rm -r "/usr/share/doc/ansifilter"
sudo rm "/usr/share/man/man1/ansifilter.1.gz"
sudo rm "/usr/bin/ansifilter"
sudo rm "/usr/share/bash-completion/completions/ansifilter"
sudo rm "/usr/share/fish/vendor_completions.d/ansifilter.fish"
sudo rm "/usr/share/zsh/site-functions/_ansifilter"
```

or

```sh
# ...
sudo "make" "uninstall"

cd "$HOME"
rm -rf "/tmp/ansifilter-install"
```

## `dulcepan`

- [vyivel/dulcepan: A Wayland screenshot tool - Codeberg.org](https://codeberg.org/vyivel/dulcepan)
- [Releases - vyivel/dulcepan - Codeberg.org](https://codeberg.org/vyivel/dulcepan/releases)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=dulcepan-git)

Requires:

- Build:

    ```
    meson wayland-protocols
    ```

- Runtime:

    ```
    cairo glibc libsfdo libspng libxkbcommon pixman wayland
    ```

Installation:

```sh
mkdir "/tmp/dulcepan-install"
cd "/tmp/dulcepan-install"

curl -L "https://codeberg.org/vyivel/dulcepan/archive/v1.0.3.tar.gz" -o "./archive.tar.gz"
echo "022a57335326b89b9ccc1efb98f043c7ad50fc3dcc14e1d0a220fae8d5efdf6d  archive.tar.gz" | sha256sum -c

tar -xvzf "./archive.tar.gz"

cd "./dulcepan"
meson "setup" "./build"
ninja -C "./build"
sudo "meson" "install" -C "./build"

cd "$HOME"
rm -rf "/tmp/dulcepan-install"
```

Removal:

```sh
sudo rm "/usr/local/bin/dulcepan"
```

## `JDownloader` (user)

- [JDownloader.org - Official Homepage](https://jdownloader.org/home/index?s=lng_en)
- [JDownloader.org - Official Homepage](https://jdownloader.org/jdownloader2#selection=linux)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=jdownloader2)
- [JDownloader Support - How to verify integrity of our own (alternative) installer setups.](https://support.jdownloader.org/en/knowledgebase/article/how-to-verify-integrity-of-our-own-alternative-installer-setups)

Requires:

- Runtime:

    ```
    hicolor-icon-theme java-runtime libarchive libxi libxtst ttf-font
    ```

Installation:

```sh
mkdir "/tmp/jdownloader-install"
cd "/tmp/jdownloader-install"

curl -L "https://installer.jdownloader.org/JDownloader.jar" -o "./JDownloader.jar"
curl -L "https://keys.openpgp.org/vks/v1/by-fingerprint/2B805711032D5A5CB50074C510C6265CEFB6457E" -o "./key.asc"
gpg --verify "./key.asc" "./JDownloader.jar"

mkdir -p "${HOME}/.local/share/jdownloader"
cp "./JDownloader.jar" "${HOME}/.local/share/jdownloader"

cd "$HOME"
rm -rf "/tmp/jdownloader-install"
```

Removal:

```sh
rm "${HOME}/.local/share/jdownloader/JDownloader.jar"
```

## `FreeFileSync`

- [Download the Latest Version - FreeFileSync](https://freefilesync.org/download.php)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=freefilesync-bin)

```sh
mkdir "/tmp/FreeFileSync-install"
cd "/tmp/FreeFileSync-install"

curl -L "https://freefilesync.org/download/FreeFileSync_14.9_Linux_x86_64.tar.gz" -o "./archive.tar.gz"
echo "0b571d85c6a672464b3d73fcde829725240c7121adb7e66f83919bc5f5c3b417  archive.tar.gz" | sha256sum -c

tar -xvzf "./archive.tar.gz"

./FreeFileSync_14.9_Linux_x86_64.run

cd "$HOME"
rm -rf "/tmp/FreeFileSync-install"
```

Removal:

```sh
sudo rm -r "/opt/FreeFileSync/"
sudo rm "/usr/share/applications/FreeFileSync.desktop"
sudo rm "/usr/share/applications/RealTimeSync.desktop"
sudo rm "/usr/local/bin/freefilesync"
sudo rm "/usr/local/bin/Freefilesync"
```

## `qrcp`

- [claudiodangelis/qrcp: :zap: Transfer files over wifi from your computer to your mobile device by scanning a QR code without leaving the terminal.](https://github.com/claudiodangelis/qrcp)
- [Releases · claudiodangelis/qrcp](https://github.com/claudiodangelis/qrcp/releases)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=qrcp)

Requires

- Runtime:

    ```
    glibc
    ```

- Build:

    ```
    go
    ```

Installation:

```sh
mkdir "/tmp/qrcp-install"
cd "/tmp/qrcp-install"

curl -L "https://github.com/claudiodangelis/qrcp/releases/download/v0.11.6/qrcp_0.11.6_linux_amd64.tar.gz" -o "./archive.tar.gz"
echo "1bcd1e23460cb2c98eeb1a9df6e4f4f7cb1e889acdb53094a7c6805808790d13  archive.tar.gz" | sha256sum -c

tar -xvzf "./archive.tar.gz"

./qrcp "completion" "bash" > "./qrcp.completion.bash"
./qrcp "completion" "zsh" > "./qrcp.completion.zsh"

sudo cp "./qrcp.completion.bash" "/usr/share/bash-completion/completions/qrcp"
sudo cp "./qrcp.completion.zsh" "/usr/share/zsh/site-functions/_qrcp"
sudo cp "./qrcp" "/usr/local/bin/qrcp"

cd "$HOME"
rm -rf "/tmp/qrcp-install"
```

Removal:

```sh
sudo rm "/usr/share/bash-completion/completions/qrcp"
sudo rm "/usr/share/zsh/site-functions/_qrcp"
sudo rm "/usr/local/bin/qrcp"
```

## `ddd` 🚧

- [DDD - Data Display Debugger - GNU Project - Free Software Foundation (FSF)](https://www.gnu.org/software/ddd/)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=ddd)

## `sasm` 🚧

- [SASM - Simple crossplatform IDE for NASM, MASM, GAS, FASM assembly languages](https://dman95.github.io/SASM/english.html)
- [PKGBUILD - aur.git - AUR Package Repositories](https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=sasm)

<!-- ## `eparakstitajs3` `latvia-eid-middleware` `eparaksts-token-signing` 🚧 -->
<!---->
<!-- - [Instalēt Latvijas digitālo parakstu uz Ubuntu linux 20.10](https://gist.github.com/aabele/762bfd965df92b6d8d95a5a7c7195780) -->

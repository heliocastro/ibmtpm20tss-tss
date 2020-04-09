# Building TPM20TSS with cmake
( for original instructions, look README.makefile  )

Written by Helio Chissini de Castro ```<helio@kde.org>```

## Dependencies
* For all platforms
* * cmake - http://cmake.org
* * openssl ( See conan instructions for Mac and Windows easy deps )
* Mac ( XCode and brew clang/gcc ) and Windows ( MSVC )
* * conan - http://conan.io


## Easy dependencies for Mac and Windows with Conan
* After install conan do:
```
mkdir build
cd build
conan profile new default --detect
conan install ..
```
On Windows Conan has preset binary dependencies for openssl 64 bits and MSVC 16 and up
If you get an error of non availability of openssl for your old MSVC build, you can execute
```
conan install .. --build *
```
This will rebuild the dependencies for your compiler

## Simple build instructions for Linux and Mac
Building is straightforward, as long you installed all dependencies:
```
mkdir build
cd build
cmake ..
make VERBOSE=1
```

## Simple build instructions for Windows Visual Studio
Build for Windows Visual Studio must be "almost" straightforward.
Builds are tested with MSVC
```
mkdir build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build .
```

## Enabling/Disabling Features
To enable or disable features, add ```-D<FEATURE>=ON/OFF``` on cmake line

Ex. ```cmake -DCMAKE_BUILD_TYPE=Release -DCONFIG_TPM20=OFF ..```

For all options and details, see the documentation in ibmtss.doc or
ibmtss.html.

* **CONFIG_TPM20** - Enable TPM 2.0 Features ( Default: ON )
* **CONFIG_TPM12** - Enable TPM 1.2 Features ( Default: ON )
* **CONFIG_TSS_NOPRINT** - Build a TSS library without tracing or prints ( Default OFF )
* **CONFIG_TSS_NOFILE** - Build a TSS library that does not use files to preserve state ( Default OFF )
* **CONFIG_TSS_NOCRYPTO** - Build a TSS library that does not require a crypto library ( Default OFF )
* **CONFIG_TSS_NOECC** - Build a TSS library that does not require OpenSSL elliptic curve support ( Default OFF )
* **CONFIG_HWTPM** - Use a software TPM instead of the hardware one ( Default ON )
* **CONFIG_RMTPM** - Do not use the resource manage ( Default OFF )

## Build time options
* Hardware default location for HW TPM is dev, to change:
  * Add ```-DTPM_INTERFACE_TYPE_DEFAULT="\"dev\""``` on cmake line

* Default device is /dev/tpmrm0 (rather than /dev/tpm0), to change:
  * Add ```-DTPM_DEVICE_DEFAULT="\"/dev/tpm0\""``` on cmake line

* Different directory for TSS state files (rather than cwd)
  * Add ```-DTPM_DATA_DIR_DEFAULT="\"directory\""``` on cmake line


## Install
* Linux
On Linux, binary is installed in default sbin dir and an extra systemd service file is installed to start and stop the service.
No firewall exclusion files are included, so remember to open the required ports

* Mac and Windows
Install works, but only mac is guaranteed to end up in proper path

# Troubleshoot

## Windows has symbols / 32/64 bits mismatch
Only 64 bits compilations are tested with conan deps. If you installed openssl by your own, some possible issues:
* Your compiler is 64 bits and you have 32 bits deps, configure this way:
```
cmake -DCMAKE_BUILD_TYPE=Release -A win32 ..
```

## Mac You are using gcc or clang from Homebrew,ad Connan detected XCode Clang as default compiler
* Read profile section of Conan - https://docs.conan.io/en/latest/reference/profiles.html
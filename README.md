# Raddiu
this is a radio program made for GNU/Linux (especially elementary os).

# Development
clone the repo and install the dependencies (You can find the list of dependencies in the meson.build file).
You also need to install the elementary os sdk "elementary-sdk"

# Build
````
meson build
cd build
ninja install
````

To do subsequent builds you can just run ```ninja``` and then run the program by doing ```./com.github.ranfdev.raddiu```

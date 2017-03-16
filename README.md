# autoconf-kconfig
Kbuild autoconf integration

This is a tool that can be used with autoconf to provide the configure script with the Kconfig scripting as an additional configuration input other than the standard configure arguments. The Kconfig scripting language and tools are the official configuration system that linux kernel uses to select all parameters, you may be familiar with the kernel confguration procedure "make config" or "make menuconfig". Here the kconfig is shifted to the configure step profiting of all the autoconf configuration macro. The trick is done using this repository as a submodule connected with a m4 macro (i.e. ax_enable_kconfig.m4) that activates the Kconfig capability within your autoconf project. The example directory ais an instance of a possile project with some simple variables that exploit this technique.






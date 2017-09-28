# autoconf-kconfig
## Kconfig autoconf integration
This is a tool that can be used with autoconf to provide the configure script with the Kconfig scripting as an additional configuration input other than the standard configure arguments. The Kconfig scripting language and tools are the official configuration system that linux kernel uses to select all parameters, you may be familiar with the kernel configuration procedure "make config" or "make menuconfig". Here the kconfig is shifted to the configure step profiting of all the autoconf configuration macro. The trick is done using this repository as a submodule connected with a m4 macro (i.e. ax_enable_kconfig.m4) that activates the Kconfig capability within your autoconf project. The example directory is an instance of a possible project with some simple variables that exploit this technique.

The kconfig system relies to a Kconfig file that must exist on the top of the project, for how to write this file please refer the Kconfig scripting syntax manual here: https://www.kernel.org/doc/Documentation/kbuild/kconfig-language.txt

All Variable defined by Kconfig input will be stored as CONFIG_xxx in a *.config* file written in the build directory. Than the execution of this file is prepared in a AX_KCONFIG macro (form file ax_enable_kconfig.m4), so that the configure script will load all CONFIG_xxx variable as a new possible further input for the xxx variable defined.

Take a look at a simple google slides presentation: [slides](https://docs.google.com/presentation/d/e/2PACX-1vRhVh9ZfhzI6ZJE_jVOJcGrp-Ff1CuXifx0G5dKmzkgVJToFYwmsCEqmKwGUnX3KKpdMSn8bAQlbg1M/pub?start=false&loop=false&delayms=3000)

## Enable autoconf-kconfig in a project
The easiest way to use autoconf-kconfig is to start from an existing project that already embed it, this is already available to be cloned and tested with this procedure:

>  git clone https://github.com/andrearigoni/autoconf-bootstrap.git <br>
>  ./bootstrap <br>
>  mkdir build <br>
>  cd build <br>
>  ../configure --enable-kconfig

Another way to add autoconf-kconfig to an existing autoconf/automake project is to add it as a submodule

> git submodule add https://github.com/andrearigoni/autoconf-kconfig.git conf/kconfig

The project comes as in maintainer mode so remember to run the ./bootstrap script inside the conf/kconfig directory to prepare the submodule for configuration or add a recursive call in your bootstrap phase. Then you have only to make a link in your m4 directory to the ax_enable_kconfig.m4 macro

> ln -s conf/kconfig/m4/ax_enable_kconfig.m4 m4/

In this way your project will be provided with the AX_KCONFIG macro you must add to configure.ac like the following lines:

> dnl /// AX_KCONFIG ///////////////////////////////////////////////////////////////// <br>
> dnl     see: m4/ax_enable_kconfig.m4 <br>
> <br>
> AS_VAR_SET([srcdir],[${srcdir}]) <br>
> AS_VAR_SET([builddir],[$(pwd)]) <br>
> AX_KCONFIG([conf/kconfig]) <br>

Here the srcdir and builddir variable has been set before calling the macro to make those variables available to the Kconfig script. The argument of the AX_KCONFIG macro is the directory where the submodule is located.



## Add Kconfig variables by examples

### Simple variable
*configure.ac* <br>
<pre>
AX_KCONFIG_VAR(EXAMPLE_VAR)
</pre>

*Kconfig* <br>
<pre>
config EXAMPLE_STRING_VAR 
  string "get value for EXAMPLE_STRING_VAR"
   ---help---
    This is an example string variable defined within the kconfig
    autoconf addon.
</pre>

### Automake conditional variable
*configure.ac* <br>
<pre>
AX_KCONFIG_CONDITIONAL(EXAMPLE_CONDITION)
</pre>

*Kconfig* <br>
<pre>
config EXAMPLE_CONDITION
  bool "toggle for EXAMPLE_CONDITION"
</pre>

### Autoconf enable variable
*configure.ac* <br>
<pre>
AX_KCONFIG_VAR_ENABLE(FEATURE, HELP)
AC_SUBST([FEATURE])
</pre>

*Kconfig* <br>
<pre>
config FEATURE
  bool "toggle for FEATURE"
</pre>

### Autoconf with variable
*configure.ac* <br>
<pre>
AX_KCONFIG_VAR_WITH(WITH_FEATURE, HELP)
AC_SUBST([WITH_FEATURE])
</pre>

*Kconfig* <br>
<pre>
config WITH_FEATURE
  string "toggle for FEATURE"
</pre>

### Choice
*configure.ac* <br>
<pre>
AX_KCONFIG_CHOICE([RETRIEVE],
		  [RETRIEVE_TAR],["tar"],
		  [RETRIEVE_DIR],["dir"])
AC_SUBST([RETRIEVE])
</pre>

*Kconfig* <br>
<pre>
  choice RETRIEVE
	 prompt "Select the retrieve method"
	 config RETRIEVE_TAR
	 bool "tar binaries from web"
	 config RETRIEVE_DIR
	 bool "from existing directory"
  endchoice
</pre>


### Autoconf with choice
*configure.ac* <br>
<pre>
AX_KCONFIG_WITH_CHOICE([RETRIEVE],
		  [RETRIEVE_TAR],["tar"],
		  [RETRIEVE_DIR],["dir"])
AC_SUBST([RETRIEVE])
</pre>

*Kconfig* <br>
<pre>
  choice RETRIEVE
	 prompt "Select the retrieve method"
	 config RETRIEVE_TAR
	 bool "tar binaries from web"
	 config RETRIEVE_DIR
	 bool "from existing directory"
  endchoice
</pre>


### Autoconf enable modules
*configure.ac* <br>
<pre>
AX_KCONFIG_MODULES([MDS],[java],[])
AX_KCONFIG_MODULES([MDS],[lv],[labview],
			 [ni],[national instruments components])
AC_SUBST(MDS_JAVA)
AC_SUBST(MDS_LV)
AC_SUBST(MDS_NI)
AC_SUBST(MDS_MODULES)
</pre>

*Kconfig* <br>
<pre>
menu MDS_MODULES
	config MDS_JAVA
	bool "Enable java module"
	default y

	config MDS_LV
	bool "Enable labview module"
	default n

	config MDS_NI
	bool "Enable National Instruments module"
	default n
endmenu
</pre>





# hamlinux
Automatically exported from code.google.com/p/hamlinux

Debian-based Live-cd based on Voyage Linux, tailored to Amateur Radio

This project is to track modifications to the Voyage Linux distribution (Squeeze) to streamline it further, remove un-necessary packages, and install an AX.25 subsystem.

This projected started by modifying Voyage Linux 0.7.0 (resulting in the Hamlinux-0.1 release).

Now we have moved to using Voyage Linux 0.7.5 as the base, and we have upgraded the kernel to Linux 3 to pick up some AX.25 kernel patches, resulting in the release of Hamlinux-0.2.

You can download either the .img or .iso files of the current release. They are around 65MB each. The .img can be used with dd or physdiskwrite to write directly to a compact flash card or USB stick to install from (I like to burn it to a USB stick to use for installing on devices). Use the .iso to create a CD or install it in a virtual machine for testing.

If you want to build the SDK, you will need to check out the current source tree with subversion and run ./build.sh sdk to build the SDK .iso (it is too big to upload here).

Hamlinux gives you a stripped down version of Voyage Linux, removing a bunch of packages (802.11 stuff, PXE, and others) and adds in the Linux AX.25 base packages (libax25, ax25apps, and ax25tools) from the related http://linuxax25.googlecode.com project.

This provides you with a nice and compact base OS to use for Amateur Radio packet related projects (FPAC, RMS Linux, etc.)


Finally words from us Archivers and Developers.. 

##### Donate

People from time to time wish to donate a little money. Donating won't get you anything special, other than a warm feeling inside, and possibly urge me to produce more freely available material for interesting projects. You can donate via [PayPal](https://www.paypal.com), just click [donate](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3PXVSLXFBS45E) button available below - it will redirect you to the secured PayPal page where you can provide donation amount (there is no minimal value). Any donations are apreciated greatly, and we thank you all in advance for your support along the ways..

[![Donate via PayPal](https://www.paypalobjects.com/en_US/GB/i/btn/btn_donateCC_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=3PXVSLXFBS45E)


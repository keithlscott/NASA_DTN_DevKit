#!/bin/bash

#
# This script will attempt to build core on an Ubuntu system.
# It is just a compilation of the instructions in section 2.3 of
#		http://downloads.pf.itd.nrl.navy.mil/docs/core/core-html/install.html
#
DO_PREREQS=1

MAKE_CORE=1
CORE_VERSION=4.8
CORE_URL=http://downloads.pf.itd.nrl.navy.mil/core/source/core-$CORE_VERSION.tar.gz

MAKE_QUAGGA=1
QUAGGA_VERSION=0.99.21mr2.2
QUAGGA_URL=http://downloads.pf.itd.nrl.navy.mil/ospf-manet/quagga-0.99.21mr2.2/$QUAGGA_VERSION.tar.gz

MAKE_ION=1
ION_VERSION=3.5.0
ION_URL=http://downloads.sourceforge.net/project/ion-dtn/ion-$ION_VERSION.tar.gz

INSTALL_SCENARIOS=1

export http_proxy=http://gatekeeper-w.mitre.org:80
export https_proxy=http://gatekeeper-w.mitre.org:80
WGET_OPTS=--no-check-certificate

#
# Prerequisites
#
if [ $DO_PREREQS == 1 ]; then
	sudo -E apt-get update
	sudo -E apt-get -y dist-upgrade
	sudo -E apt-get -y install bash bridge-utils ebtables gawk iproute libev-dev python \
		tcl8.5 tk8.5 libtk-img \
		autoconf automake gcc libev-dev make python-dev libreadline-dev pkg-config \
		imagemagick help2man
fi


mkdir DTNDevKit_Install
cd DTNDevKit_Install

#
# CORE
#
# Get CORE and uncompress
#
if [ $MAKE_CORE == 1 ]; then

	wget $CORE_URL
	tar -xzf core-$CORE_VERSION.tar.gz

	# Build CORE and documentation
	cd core-$CORE_VERSION
	./bootstrap.sh
	./configure
	make -j8
	sudo make install

	cd doc
	make html
	# The latex / pdf version takes more configuration than it's worth at the moment.
	# If you're interested, the first step is: sudo -E apt-get install texlive-latex-base
	# followed by figuring out how to install the latex cmap.sty file (that's where I gave
	# up for now).
	# sudo -E apt-get -y install python-sphinx texlive-latex-base
	# make latexpdf
	
	cd ..
fi


#
# Quagga with NRL Manet OSPF
# Needed for wireless MANET networks to work
#
if [ $MAKE_QUAGGA == 1 ]; then

	wget $QUAGGA_URL

	tar xzf quagga-$QUAGGA_VERSION.tar.gz
	cd quagga-$QUAGGA_VERSION
	./configure --enable-user=root --enable-group=root --with-cflags=-ggdb \
		--sysconfdir=/usr/local/etc/quagga --enable-vtysh \
		--localstatedir=/var/run/quagga
	make
	sudo make install

	sudo ldconfig

	cd ..
fi


#
# ION
#
if [ $MAKE_ION == 1 ]; then
	
	wget $ION_URL
	tar -zxf ion-$ION_VERSION.tar.gz
	
	cd ion-$ION_VERSION
	./configure
	make
	sudo make install
	
	sudo ldconfig

	cd ..
fi

# CD back into the NASA_DTN_CORE directory with all our stuff in it.
cd ..

#
# DevKit Scenarios
#
if [ $INSTALL_SCENARIOS == 1 ]; then
	#
	# Run core-gui to generate the .core directory and populate it
	# with the default configs
	#
	core-gui &
	GUI_PID=$!
	sleep 5
	kill -9 $GUI_PID

	cp -r ./CORE_configs ~/.core/configs/NASADTNDevKit

	#
	# Replace hard-coded pathnames of mobility scripts with path to
	# current instantiation.  This is ugly, but I think the mobility
	# scripts have to have full path names.
	#
	find ~/.core/configs/NASADTNDevKit -name "*.imn" -exec sed -i "s?file=/home/core/?file=$HOME/?" {} \;

	#
	# Pull the SDL graphics library in order to build the image-transfer demo
	# app.  We use the older version 1.2 (there's a version 2.x with migration
	# instructions at https://wiki.libsdl.org/MigrationGuide)
	#
	cd DTNDevKit_Install
	SDL_VERSION=1.2.15

	# wget $WGET_OPTS https://www.libsdl.org/release/SDL-$SDL_VERSION.tar.gz

	tar -xzf SDL-$SDL_VERSION.tar.gz
	cd SDL-$SDL_VERSION

	# Apply patch needed to compile SDL 1.2
	patch -p1 < ../../XData32.patch
	sh autogen.sh

	# Make SDL
	./configure
	make
	sudo make install

	# Back up to our directory and make bpi
	cd ../../bpi
	make

	sudo make install	

fi

# Good luck.




# BPI Makefile 1.3

### CHANGE THIS FOR YOUR LOCAL VERSION OF ION
srcdir= ~/ion/ion-open-source
###

CC=gcc
bpcflags= -I$(srcdir)/bp/library -I$(srcdir)/bp/library/acs -I$(srcdir)/bp/library/ext -I$(srcdir)/bp/library/ext/meb -I$(srcdir)/bp/library/ext/bae -I$(srcdir)/bp/library/ext/cteb -I$(srcdir)/bp/include -I$(srcdir)/bp/ipn -I$(srcdir)/bp/dtn2 -I$(srcdir)/bp/library/crypto -I$(srcdir)/bp/library/ext/ecos -I$(srcdir)/bp/library/ext/bsp -I$(srcdir)/bp/library/ext/bsp/ciphersuites -I$(srcdir)/bp/library/ext/phn -I$(srcdir)/bp/imc -I$(srcdir)/ici/include/ -I$(srcdir)/bp/library/ext/ecos -I$(srcdir)/bp/library/ext/bsp -I$(srcdir)/bp/imc -DBP_EXTENDED -g

bpisend_SOURCES = bp/test/bpisend.c bp/test/lodepng.c
bpisend_LDADD = $(srcdir)/.libs/libbp.so $(srcdir)/.libs/libici.so
bpisend_CFLAGS = $(bpcflags)

bpirecv_SOURCES = bp/test/bpirecv.c
bpirecv_LDADD = $(srcdir)/.libs/libbp.so $(srcdir)/.libs/libici.so `sdl-config --libs`
bpirecv_CFLAGS = `sdl-config --cflags` $(bpcflags)

all: bpisend bpirecv
	
bpisend: bpisend.o lodepng.o
	$(CC) $(bpisend_CFLAGS) -o bpisend bpisend.o lodepng.o $(bpisend_LDADD)
	
bpirecv: bpirecv.o
	$(CC) $(bpcflags) `sdl-config --libs` -o bpirecv bpirecv.o $(bpirecv_LDADD)
		
bpisend.o: bpisend.c lodepng.h
	$(CC) -c bpisend.c $(bpisend_CFLAGS)

bpirecv.o: bpirecv.c
	$(CC) -c bpirecv.c `sdl-config --cflags` $(bpcflags)

lodepng.o: lodepng.c lodepng.h
	$(CC) -c lodepng.c

install:
	cp bpisend /usr/local/bin/
	cp bpirecv /usr/local/bin/

uninstall:
	rm /usr/local/bin/bpisend
	rm /usr/local/bin/bpirecv
	
clean:
	rm bpisend bpirecv bpisend.o bpirecv.o lodepng.o

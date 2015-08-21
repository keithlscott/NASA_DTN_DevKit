/*
 *	bpisend.c	v1.3
 *	BP Image streaming program
 *	Author: Alex Handley <ahandley@mitre.org>
 *	This is a modified version of bpsource by Scott Burleigh
 *	This software uses LodePNG < http://lodev.org/lodepng/ >
 *	Usage:
 *	   bpsource <src EID> <dest EID> <filename> [-flags]
 *		-c 		Disable custody
 *		-v 		Verbose mode, will print line numbers
 *		-t <ttl>	Sets TTL for bundles
 */

#include <bp.h>
#include <time.h>
#include "lodepng.h"
#include <unistd.h>

static ReqAttendant	*_attendant(ReqAttendant *newAttendant){
	static ReqAttendant	*attendant = NULL;
	if (newAttendant){ attendant = newAttendant; }
	return attendant;
}

//parses the command flags from arg 5
int chkflags(char *args, char *c, char *v){
	//check if valid flags, check for c, check for v
	if (args[0] != '-') { return 1; }
	//check for c
	if (args[1] == 'c') { *c = 1; }
	else if (args[2] == 'c') { *c = 1; }
	else { *c = 0; }
	//check for v
	if (args[1] == 'v') { *v = 1; }
	else if (args[2] == 'v') { *v = 1; }
	else { *v = 0; }
	return 0;
}

int	main(int argc, char **argv)
{
	//vars
	char		*srcEid = NULL;
	char		*destEid = NULL;
	char		*filename = NULL;
	BpCustodySwitch	custodySwitch = SourceCustodyRequired;
	BpSAP		sap;
	Sdr		sdr;
	Object		extent;
	Object		bundleZco;
	ReqAttendant	attendant;
	Object		newBundle;
	int 		ttl = 300;
	char 		custody = 1;
	char 		verbose = 0;
	int 		opt = 0;

	//command line io - check for proper args
	if (argc >= 4) {   //probably valid
		filename = argv[3];
		destEid = argv[2];
		srcEid = argv[1];
	} else {    //improper args
		PUTS("Usage: bpsource <src EID> <dest EID> <filename> [-flags]");
		return 0;
	}

	// parse command flags
	while ((opt = getopt(argc, argv, "cvt:")) != -1) {
		switch(opt) {
		case 'c':
			custody = 0; break;
		case 'v':
			verbose = 1; break;
		case 't':
			ttl = atoi(optarg); break;
		default:
			PUTS("Invalid Flags:\n-c\tDisable Custody\n-v\tVerbose mode\n-t <ttl>\tSets TTL for bundles");
			return 0;
		}
	}


	//lodepng vars
	unsigned error;
	unsigned char* image;
	unsigned char** buffer;
	typedef struct head{
		unsigned int height;
		unsigned int width;
		unsigned int i;
		unsigned int uid;
	} header;
	header h;

	//generate a random UID
	time_t t;
	srand((unsigned) time(&t));
	h.uid = rand();

	//open the file here and check if it's valid, using lodepng.h
	error = lodepng_decode32_file(&image, &(h.width), &(h.height), filename);
	if(error) {
		putErrmsg("Could not load the image to send", NULL);
		return 0;
	} else {
		//malloc the array
		buffer = malloc(h.height*sizeof(char*));
		//for each i in height, malloc a line
		for (h.i = 0; h.i < (h.height); h.i++){
			buffer[h.i] = (unsigned char*) malloc(16+(h.width*4*sizeof(char)));
			//copy the header onto each line
			memmove(buffer[h.i], ((char *)&h), sizeof(h));
			//copy the bits over from that row (ptr, ptr++)
			memmove((buffer[h.i]+sizeof(h)), (image+(h.i*h.width*4)), h.width*4);
		}
	}
	//free the genie! (file)
	free(image);

	//attach to BP and start the attendant
	if (bp_attach() < 0){
		putErrmsg("Can't attach to BP.", NULL);
		return 0;
	}

	if (bp_open(srcEid, &sap) < 0){
		putErrmsg("Can't open own endpoint.", srcEid);
		return 0;
	}

	if (ionStartAttendant(&attendant)){
		putErrmsg("Can't initialize blocking transmission.", NULL);
		return 0;
	}

	//if no -c, turn off custody
	if (!custody) { custodySwitch = NoCustodyRequested; }

	_attendant(&attendant);
	sdr = bp_get_sdr();

	// make bundles and send them
	for (h.i = 0; h.i < h.height; h.i++){
		CHKZERO(sdr_begin_xn(sdr));
		extent = sdr_malloc(sdr, ((h.width*4)+sizeof(h)));
		if (extent){
			sdr_write(sdr, extent, (char *) buffer[h.i], ((h.width*4)+sizeof(h)));
		}

		if (sdr_end_xn(sdr) < 0){
			putErrmsg("No space for ZCO extent.", NULL);
			break;
		}

		bundleZco = ionCreateZco(ZcoSdrSource, extent,
				0, ((h.width*4)+sizeof(h)), BP_STD_PRIORITY, 0,
				ZcoOutbound, &attendant);
		if (bundleZco == 0 || bundleZco == (Object) ERROR){
			putErrmsg("Can't create ZCO extent.", NULL);
			break;
		}

		if (bp_send(sap, destEid, NULL, ttl, BP_STD_PRIORITY,
				custodySwitch, 0, 0, NULL,
				bundleZco, &newBundle) < 1)
		{
			putErrmsg("bpisend can't send ADU.", NULL);
			break;
		} else {
			if (verbose) { printf("%d \n", h.i); }
		}
	}

	//done now, close stuff and return
	bp_close(sap);
	ionStopAttendant(_attendant(NULL));
	bp_detach();
	return 0;
}

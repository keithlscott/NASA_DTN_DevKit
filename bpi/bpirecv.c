/*
 *	bpirecv.c	v1.3
 *	BP Image stream display program
 *	Author: Alex Handley <ahandley@mitre.org>
 *	This is a modified version of bpsink.c by Scott Burleigh
 *	Usage:
 *	bpirecv <own endpoint ID>
 *
 *	Dependencies: SDL v1.2.0
 */

#include <bp.h>
#include <stdio.h>
#include <SDL.h>
#include <string.h>
#define DEPTH 32

typedef struct
{
	BpSAP	sap;
	int	running;
} BptestState;

static BptestState	*_bptestState(BptestState *newState)
{
	void		*value;
	BptestState	*state;

	if (newState)			/*	Add task variable.	*/
	{
		value = (void *) (newState);
		state = (BptestState *) sm_TaskVar(&value);
	}
	else				/*	Retrieve task variable.	*/
	{
		state = (BptestState *) sm_TaskVar(NULL);
	}

	return state;
}

static void	handleQuit()
{
	BptestState	*state;

	isignal(SIGINT, handleQuit);
	PUTS("BP reception interrupted.");
	state = _bptestState(NULL);
	bp_interrupt(state->sap);
	state->running = 0;
}

int	main(int argc, char **argv)
{
	char		*ownEid = (argc > 1 ? argv[1] : NULL);
	static char	*deliveryTypes[] =	{
				"Payload delivered.",
				"Reception timed out.",
				"Reception interrupted.",
				"Endpoint stopped." };
	BptestState	state = { NULL, 1 };
	Sdr sdr;
	BpDelivery dlv;
	int	contentLength;
	ZcoReader reader;
	int	len;
	char content[10000];

	//gui stuff
	int firstBundle = 1;
	int bundlesLeft = 1;
	int width = 0; int height = 0; int position = 0; int uid = 0;
	unsigned char *screenbuffer = 0;
	SDL_Surface *screen;
	SDL_Surface *video = 0;
	SDL_Event event;
	
	//Init SDL
	printf("About to call SDL_Init())\n");
	if (SDL_Init(SDL_INIT_VIDEO) < 0 ) {
		printf("SDL_INIT_VIDEO failed.\n");
		fprintf(stderr, "Unable to initialize SDL: %s\n",
			SDL_GetError());
		return 1;
	}

	if (ownEid == NULL)
	{
		PUTS("Usage: bpirecv <own endpoint ID>");
		return 0;
	}

	if (bp_attach() < 0)
	{
		putErrmsg("Can't attach to BP.", NULL);
		return 0;
	}

	if (bp_open(ownEid, &state.sap) < 0)
	{
		putErrmsg("Can't open own endpoint.", ownEid);
		return 0;
	}

	oK(_bptestState(&state));
	sdr = bp_get_sdr();
	isignal(SIGINT, handleQuit);
	
	//figure out the endian-ness and set the bitmasks accordingly
	int rmask, gmask, bmask, amask;
	if (SDL_BYTEORDER == SDL_BIG_ENDIAN) {
		rmask = 0xff000000; gmask = 0x00ff0000;
		bmask = 0x0000ff00; amask = 0x000000ff;
	} else {
		rmask = 0x000000ff; gmask = 0x0000ff00;
		bmask = 0x00ff0000; amask = 0xff000000;
	}

	//run until bundlesLeft == 0 or state.running = 0
	do {
		if (bp_receive(state.sap, &dlv, BP_BLOCKING) < 0)
		{
			putErrmsg("bpirecv bundle reception failed.", NULL);
			state.running = 0;
			continue;
		}

		PUTMEMO("ION event", deliveryTypes[dlv.result - 1]);
		if (dlv.result == BpReceptionInterrupted)
		{
			continue;
		}

		if (dlv.result == BpEndpointStopped)
		{
			state.running = 0;
			continue;
		}

		if (dlv.result == BpPayloadPresent)
		{
			CHKZERO(sdr_begin_xn(sdr));
			contentLength = zco_source_data_length(sdr, dlv.adu);
			sdr_exit_xn(sdr);
			PUTS("Received a bundle!");
			if (contentLength < sizeof content)
			{
				zco_start_receiving(dlv.adu, &reader);
				CHKZERO(sdr_begin_xn(sdr));
				len = zco_receive_source(sdr, &reader,
						contentLength, content);
				if (sdr_end_xn(sdr) < 0 || len < 0)
				{
					putErrmsg("Can't handle delivery.", NULL);
					state.running = 0;
					continue;
				}
				///content[contentLength] = '\0';
				
				// parse the bundle
				if (firstBundle){
					//extract the width, height, position, and UID
					height = *(((int *)content)+0);
					width = *(((int *)content)+1);
					position = *(((int *)content)+2);
					uid = *(((int *)content)+3);
					//set bundlesLeft to height-1
					bundlesLeft = (height-1);
					//set up the window
					if (!(video = SDL_SetVideoMode(width, height, DEPTH, SDL_DOUBLEBUF))){
						SDL_Quit(); 
						PUTS("Could not properly load SDL");
						return 1;
					}
					//make a screenbuffer that's all black pixels
					screenbuffer = malloc(width*height*4);
					firstBundle = 0; //toggle this off
				} else {
					//extract pos and UID
					int curUid;
					position = *(((int *)content)+2);
					curUid = *(((int *)content)+3);
					printf("pos: %d\n", position);
					//check if the UID is right
					if (curUid != uid){
						PUTS("Bundle from another image found!");
						continue;
					}
					//subtract 1 from bundlesLeft
					bundlesLeft--;
				}

				//add this row to the screenbuffer
				memmove(screenbuffer+(position*width*4), content+16, width*4);

				//set screen to the contents of screenbuffer
				screen = SDL_CreateRGBSurfaceFrom(screenbuffer,
					 width, height, DEPTH, 4*width,
					 rmask, gmask, bmask, amask);

				// blit that surface to the screen
				SDL_BlitSurface(screen, NULL, video, NULL);
				SDL_FreeSurface(screen);

				// flip the display
				SDL_Flip(video);

				// deal with events
				while(SDL_PollEvent(&event)) {
					switch (event.type) {
						case SDL_QUIT:
						state.running = 0;
						continue;
					}
				}
			}
		}
		bp_release_delivery(&dlv, 1);
	} while ((state.running) && (bundlesLeft));

	sleep(10);
	SDL_Quit();
	bp_close(state.sap);
	writeErrmsgMemos();
	PUTS("Stopping bpirecv.");
	bp_detach();
	return 0;
}

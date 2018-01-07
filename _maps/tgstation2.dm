/*
The yogstation codebase currently requires you to have 10 z-levels of the same size dimensions.
z-level order is important, the order you put them in inside this file will determine what z level number they are assigned ingame.
Names of z-level do not matter, but order does greatly, for instances such as checking alive status of revheads on z1

current as of 2017/12/15
z1 = station
z2 = centcomm
z3 = derelict telecomms satellite
z4 = derelict station
z5 = lavaland
z6 = empty space
z7 = empty space
z8 = empty space
z9 = empty space
z10 = abandoned asteroid
*/

#if !defined(MAP_FILE)

		#define TITLESCREEN "title" //Add an image in misc/fullscreen.dmi, and set this define to the icon_state, to set a custom titlescreen for your map
		#define TITLESCREEN_ALT null

		#define MINETYPE "lavaland"

        #include "map_files\YogStation\yogstation.2.1.3.dmm"
        #include "map_files\generic\z2.dmm"
        #include "map_files\generic\z3.dmm"
        #include "map_files\generic\z4.dmm"
        #include "map_files\generic\lavaland.dmm"
        #include "map_files\generic\z6.dmm"
        #include "map_files\generic\z7.dmm"
        #include "map_files\generic\z8.dmm"
		#include "map_files\generic\z9.dmm"
		#include "map_files\generic\z10.dmm"

		#define MAP_PATH "map_files/YogStation"
        #define MAP_FILE "yogstation.2.1.3.dmm"
        #define MAP_NAME "Box Station"

        #define MAP_TRANSITION_CONFIG	list(MAIN_STATION = CROSSLINKED, CENTCOMM = SELFLOOPING, ABANDONED_SATELLITE = CROSSLINKED, DERELICT = CROSSLINKED, MINING = SELFLOOPING, EMPTY_AREA_1 = CROSSLINKED, EMPTY_AREA_2 = CROSSLINKED, EMPTY_AREA_3 = CROSSLINKED, EMPTY_AREA_4 = CROSSLINKED, ASTEROID = CROSSLINKED)

#elif !defined(MAP_OVERRIDE)

	#warn a map has already been included, ignoring /tg/station 2.

#endif

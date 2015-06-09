#include "main.h"
#include <math.h>
//#include <stdio.h>
//#include <windows.h>

/*==========================================================================
	**	Bitmap Structs
----------------------------------------------------------------------------
	The address to a Bitmap object points to a RGSSBITMAP instance. You must
	then access the BITMAPSTRUCT and RGSSBMINFO structs to get the
	BITMAPINFOHEADER (width and height for example--documentation on
	Microsoft) and a pointer to RGSSCOLOR struct. RGBQUAD is useless.

	RGSSCOLOR holds an array of bytes that represent RGBA values. It is a
	double pointer mainly for color calculations (i.e. no need to typecast
	double everytime you're using some recoloring algorithm or something).
	firstrow will be pointing to the pixel at the top left of the bitmap.
	Note that firstrow[0] will return the alpha value of the pixel. RGB
	values can be found at firstrow[1], [2], and [3] respectively. [4] will
	return the alpha value of the next pixel to the right. It is also
	important to note that the array follows memory stack logic; that is,
	after evaluating the top right pixel of the bitmap and adding 4 to
	firstrow, you will no longer be looking at a pixel--you have jumped to
	an entirely unrelated memory space.

	Thus, when looping, you will need to add firstrow by 4 to get the next
	pixel and subtract it by bitmap.width * 4 to get the next row of pixels
	below. A black and white example is shown below.
==========================================================================*/

typedef struct {
    DWORD flags;
    DWORD klass;
    void (*dmark) (void*);
    void (*dfree) (void*);
    BYTE *data; //B = 0, G = 1, R = 2, A = 3
} RGSSCOLOR;

typedef struct{
    DWORD unk1;
    DWORD unk2;
    BITMAPINFOHEADER *infoheader;
    RGSSCOLOR *firstRow;
    RGBQUAD *lastRow;
} RGSSBMINFO;

typedef struct{
    DWORD unk1;
    DWORD unk2;
    RGSSBMINFO *bminfo;
} BITMAPSTRUCT;

typedef struct{
    DWORD flags;
    DWORD klass;
    void (*dmark) (void*);
    void (*dfree) (void*);
    BITMAPSTRUCT *bm;
} RGSSBITMAP;


/*==========================================================================
	**	Table Structs
----------------------------------------------------------------------------
	The address to a Table object points to a TABLEDATA instance. To access
	the table's values, you must access the TABLESTRUCT--this is the bulk
	of the Table object that means the most to us.
==========================================================================*/

typedef struct{
	DWORD unka; //0
	DWORD unkb; //0
	DWORD dimensions; // # of parameters
	DWORD xsize; // xsize
	DWORD ysize; // ysize (returns 1 if not specified)
	DWORD zsize; // zsize (returns 1 if not specified)
	DWORD total_elements; // xsize * ysize * zsize
	INT16 * data; // 1-D Array, where [x,y,z] can be found at index [x+(y*xsize)+(z*xsize*ysize)]
}TABLESTRUCT;

typedef struct{
	DWORD unk1;
	DWORD classname; // I think?
	DWORD unk3;
	DWORD unk4;
	TABLESTRUCT * tablevars;
}TABLEDATA;



LPBYTE emptytile;
/*==========================================================================
	**	InitEmptyTile
----------------------------------------------------------------------------
	Saves the bitmap data of a 32x32 empty tile graphic. Referenced to clear
	out single tiles.
==========================================================================*/
extern "C" __declspec (dllexport) void InitEmptyTile(long bitmap)
{
	emptytile = (LPBYTE)(((RGSSBITMAP*)(bitmap<<1)) ->bm->bminfo->firstRow);

}


extern "C" __declspec (dllexport) int DrawMapsBitmap(long * layers, long * bitmaps, long * autotiledata, long * data, long * range_data)
{
	// Load map data and priority tables
	TABLESTRUCT * mapdata = ((TABLEDATA*)(data[2]<<1))->tablevars;
	TABLESTRUCT * prioritydata = ((TABLEDATA*)(data[3]<<1))->tablevars;
	// Gets the screen resolution from the ground layer bitmap
	int screen_w = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biWidth - 32;
	int screen_h = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biHeight - 32;
	// Store width of screen elsewhere
	DWORD width = screen_w + 32;
	// If the resolution width/height is not divisible by 32, increase it by 32 to "trick" code
	// Might be a problem...
	if (screen_w % 32 != 0)
		screen_w += 32;
	if (screen_h % 32 != 0)
		screen_h += 32;
	// Changes pixel dimensions into RMXP tile dimensions (i.e. number of 32x32 pixel squares)
	screen_w /= 32;
	screen_h /= 32;
	// Get map OX and OY
	int ox = data[0];
	if (ox < 0 && ox % 32 != 0)
		ox -= 32;
	int oy = data[1];
	// Starting x and y coordinates for drawing
	int sx = 0;
	int sy = 0;

	// Based on ox and oy, figure out what tile_ids we need to look at in table
	for (int z = 0; z < 3; z++){
	for (int y = oy / 32; y < oy / 32 + screen_h + 1; y++){
		if (y >= (int)(mapdata->ysize))
			break;
		else if (y < 0)
		{
			sy += 1;
			continue;
		}
	for (int x = ox / 32; x < ox / 32 + screen_w + 1; x++){
		if (x >= (int)(mapdata->xsize))
			break;
		else if (x < 0)
		{
			sx+=1;
			continue;
		}
		LPBYTE tilegraphic;
		LPBYTE row;
		//printf("%ld, %ld, %ld\n", x, y, z);
		int nextrow_shift;
		// Get tile id and its priority
		int tile_id = mapdata->data[x + (y * mapdata->xsize) + (z * mapdata->xsize * mapdata->ysize)];
		int priority = prioritydata->data[tile_id];
		// If user wants to limit highest level of priority in their game
		if (priority > data[5])
			priority = data[5];

		// If tile id comes from tileset (not an autotile)
		if (tile_id >= 384)
		{
			tile_id -= 384;
			if ((z == 0 && range_data[y + x * mapdata->ysize] != 1) || (z == 1 && range_data[(y+1) + x * mapdata->ysize] != 1))
                tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[0]<<1)) ->bm->bminfo->firstRow);
            else
                tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[8]<<1)) ->bm->bminfo->firstRow);
			// Based on tile id, set pointer to corrisponding tile graphic
			tilegraphic += (tile_id % 8 * 128) - (tile_id / 8 * 32768);
			nextrow_shift = 1024;
		}
		else if (tile_id >= 48) // Autotile
		{
			int autotile_id = tile_id / 48;
			RGSSBITMAP* autotile_bm = (RGSSBITMAP*)(bitmaps[autotile_id]<<1);
			tilegraphic = (LPBYTE)(autotile_bm->bm->bminfo->firstRow);
			tile_id %= 48;
			tilegraphic += (tile_id % 8 * 128 + 1024 * autotiledata[(autotile_id - 1) * 2]) -
				((tile_id / 8) * autotile_bm->bm->bminfo->infoheader->biWidth * 4 * 32);
			nextrow_shift = autotile_bm->bm->bminfo->infoheader->biWidth * 4;
		}
		else
        {
            sx+=1;
			continue;
			//tilegraphic = emptytile;
        }

		// If tile has priority
		if (priority > 0)
		{
			// Get the bitmap corrisponding to this layer
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[priority + sy]<<1)) -> bm -> bminfo;
			row = (LPBYTE)(layer->firstRow) - ((data[5]-priority) * width * 128);
			row += sx * 128;

		}
		else
		{
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
			row = (LPBYTE)(layer->firstRow);
			row -= ((sy * 32) * width * 4);
			row += sx * 128;
		}

		// Make many blt/pixel transfers
		for (int i = 0; i < 32; i++)
		{
			// If bottom layer, just straight copy-paste pixel color data
			if (z == 0)
				memcpy(row, tilegraphic, 32 * 4);
			else // Need to use alpha blending and eval pixel by pixel now
			{

			// Temp values for row and tilegraphic (we want to keep row and tilegraphic pointing to the far left pixel of their draw area
			// while these variables increment)
			LPBYTE r = row;
			LPBYTE tg = tilegraphic;
			// Evaluate each pixel
			for (int pix = 0; pix < 32; pix++)
			{
				// If pixel has no transparency, straight copy it
				if (tg[3] == 255)
					memcpy(r, tg, 4);
				// If pixel is not fully transparent, apply alpha blending
				else if (tg[3] > 0)
				{
					float dst_opac = r[3]; // Save layer's pixel opacity
					// Keep a float version of the new opacity--assigning it to r[3] now would turn result into a BYTE
					float new_opac = ((255.0 * (float)tg[3] + (float)r[3] * (255 - (float)tg[3])) / 255);
					r[2] =  ((255.0 * (float)tg[2] * (float)tg[3] + (float)r[2] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[1] =  ((255.0 * (float)tg[1] * (float)tg[3] + (float)r[1] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[0] =  ((255.0 * (float)tg[0] * (float)tg[3] + (float)r[0] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[3] = new_opac;
				}
				// Evaluate to next pixel
				r += 4;
				tg += 4;
			}}
			row -= width * 4;
			tilegraphic -= nextrow_shift;
		}
	sx += 1;
	}
	sx = 0; sy += 1;
	}
	sx = 0; sy = 0;
	}

	return 0;
}

/*
Method 2: 1 ground layer and MAP_HEIGHT_TILES + 5 layer bitmaps with a height of 160
          Uses memmove to shift the pixels according to the scrolling distance. Redraws
          the small portion created by the shift. Untested performance.

Input:
    layers => array of Bitmap objects representing the ground and 1-5 priority layers
    bitmaps => array of Bitmap objects of the tileset and 7 autotiles
    data => array of ox, oy, map data, map priorities, and shift flags (in that order)

*/

extern "C" __declspec (dllexport) int DrawMapsBitmap2(long * layers, long * bitmaps, long * autotiledata, long * data, long * range_data)
{
	// Load map data and priority tables
	TABLESTRUCT * mapdata = ((TABLEDATA*)(data[2]<<1))->tablevars;
	TABLESTRUCT * prioritydata = ((TABLEDATA*)(data[3]<<1))->tablevars;
	// Gets the screen resolution from the ground layer bitmap
	int screen_w = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biWidth - 32;
	int screen_h = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biHeight - 32;
	// Store width of screen elsewhere
	DWORD width = screen_w + 32;
	DWORD height = screen_h + 32;
	// If the resolution width/height is not divisible by 32, increase it by 32 to "trick" code
	// Might be a problem...
	if (screen_w % 32 != 0)
		screen_w += 32;
	if (screen_h % 32 != 0)
		screen_h += 32;
	// Changes pixel dimensions into RMXP tile dimensions (i.e. number of 32x32 pixel squares)
	screen_w /= 32;
	screen_h /= 32;
	// Get map OX and OY
	int ox = data[0];
	if (ox < 0 && ox % 32 != 0)
		ox -= 32;
	int oy = data[1];
	// Check if the screen's current position requires drawing 1 more tile than usual
	int mod_x = 0;//ox % 32;
	int mod_y = 0;//oy % 32;
	int offset_x = 0, offset_y = 0;
	//if (mod_x != 0) offset_x = 1;
	//if (mod_y != 0) offset_y = 1;

    // Starting x and y coordinates for drawing
	int sx = 0;
	int sy = 0;

    // If right or left column needs redraw
    if ((data[4] & 2) > 0 || (data[4] & 1) > 0)
    {
        int x;
		//printf("%ld, %ld\n", data[4] & 1, data[4] & 2);
        // Right column needs redraw, shift left
        if ((data[4] & 1) > 0)
        {
            x = ox / 32 + screen_w + offset_x;
            sx = screen_w;
            for (int l = 1; l < layers[0]; l++)
            {
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[l]<<1)) -> bm -> bminfo;
                LPBYTE row = (LPBYTE)(layer->lastRow);
                memmove(row, row + 128, width * data[5] * 32 * 4 - 128);
				// Remove 32 pesky pixels at the top right of bitmap
				memmove(row + width * data[5] * 32 * 4 - 128, emptytile, 128);
            }
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
            LPBYTE row = (LPBYTE)(layer->lastRow);
            memmove(row, row + 128, width * height * 4 - 128);
			// Remove 32 pesky pixels at the top right of bitmap
			memmove(row + width * height * 4 - 128, emptytile, 128);
        }
        else
        {
            x = ox / 32;
            for (int l = 1; l < layers[0]; l++)
            {
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[l]<<1)) -> bm -> bminfo;
                LPBYTE row = (LPBYTE)(layer->lastRow);
                memmove(row + 128, row, width * data[5] * 32 * 4 - 128);
				// Remove 32 pesky pixels at the bottom left of bitmap
				memcpy(row, emptytile, 128);
            }
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
            LPBYTE row = (LPBYTE)(layer->lastRow);
            memmove(row + 128, row, width * height * 4 - 128);
			// Remove 32 pesky pixels at the bottom left of bitmap
			memcpy(row, emptytile, 128);
        }
		// If diagonal shift, do not factor in oy change yet
		if ((data[4] & 4) > 0)
			oy -= 32;
		else if ((data[4] & 8) > 0)
			oy += 32;


		//printf("Horz shift: x = %ld, oy = %ld, starty = %ld, endy = %ld\n", x, oy, oy / 32, oy / 32 + screen_h);
        // Redrawing process
        for (int z = 0; z < 3; z++){
			if (x >= (int)(mapdata->xsize) || x < 0)
				break;
        for (int y = oy / 32; y < oy / 32 + screen_h + 1; y++)
        {
			if (y >= (int)(mapdata->ysize))
				break;
			else if (y < 0)
			{
				sy+=1;
				continue;
			}
            LPBYTE tilegraphic;
            LPBYTE row;
			int nextrow_shift;
            // Get tile id and its priority
            int tile_id = mapdata->data[x + (y * mapdata->xsize) + (z * mapdata->xsize * mapdata->ysize)];
            int priority = prioritydata->data[tile_id];
			// If user wants to limit highest level of priority in their game
			if (priority > data[5])
				priority = data[5];
            // If tile id comes from tileset (not an autotile)
            if (tile_id >= 384)
            {
                tile_id -= 384;
                if ((z == 0 && range_data[y + x * mapdata->ysize] != 1) || (z == 1 && range_data[(y+1) + x * mapdata->ysize] != 1))
                    tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[0]<<1)) ->bm->bminfo->firstRow);
                else
                    tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[8]<<1)) ->bm->bminfo->firstRow);
                // Based on tile id, set pointer to corrisponding tile graphic
                tilegraphic += (tile_id % 8 * 128) - (tile_id / 8 * 32768);
				nextrow_shift = 1024;
            }
            else if (tile_id >= 48) // Autotiles
            {

                int autotile_id = tile_id / 48;
				RGSSBITMAP* autotile_bm = (RGSSBITMAP*)(bitmaps[autotile_id]<<1);
				tilegraphic = (LPBYTE)(autotile_bm->bm->bminfo->firstRow);
				tile_id %= 48;
				tilegraphic += (tile_id % 8 * 128 + 1024 * autotiledata[(autotile_id - 1) * 2]) -
					((tile_id / 8) * autotile_bm->bm->bminfo->infoheader->biWidth * 4 * 32);
				nextrow_shift = autotile_bm->bm->bminfo->infoheader->biWidth * 4;
            }
            else
            {
                // Because there is no tile to be drawn and this is on higher layers, no need to clear or draw anything
                if (z != 0)
                {
                    sy +=1;
                    continue;
                }
                tilegraphic = emptytile;
				nextrow_shift = 128;
            }

            // If tile has priority
            if (priority > 0 && tilegraphic != emptytile)
            {
				// Get element index to extract priority layer bitmap
				int p = priority + (y - oy/32);
				// If vertical shift is happening, draw to correct layer
				if ((data[4] & 4) > 0)
				{
					if (p == 1)
						p = layers[0]-1;
					else
						p -= 1;
				}
				else if ((data[4] & 8) > 0)
				{
					if (p == layers[0]-1)
						p = 0;
					else
						p += 1;
				}
                // Get the bitmap corrisponding to this layer
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[p]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow) - ((data[5]-priority) * width * 128);
                row += sx * 128 - (mod_x * 4);
            }
            else
            {
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow);
                row -= ((sy * 32 - mod_y) * width * 4);
                row += sx * 128 - (mod_x * 4);
            }

            int height_to_evaluate;
            height_to_evaluate = 32;

            // Make many blt/pixel transfers
            for (int i = 0; i < height_to_evaluate; i++)
            {
                // If bottom layer, just straight copy-paste pixel color data
                if (z == 0)
                    memcpy(row, tilegraphic, 32 * 4);
                else // Need to use alpha blending and eval pixel by pixel now
                {

                // Temp values for row and tilegraphic (we want to keep row and tilegraphic pointing to the far left pixel of their draw area
                // while these variables increment)
                LPBYTE r = row;
                LPBYTE tg = tilegraphic;
                // Evaluate each pixel
                int width_to_evaluate;
                width_to_evaluate = 32;

                for (int pix = 0; pix < width_to_evaluate; pix++)
                {
                    // If pixel has no transparency, straight copy it
                    if (tg[3] == 255)
                        memcpy(r, tg, 4);
                    // If pixel is not fully transparent, apply alpha blending
                    else if (tg[3] > 0)
                    {
                        float dst_opac = r[3]; // Save layer's pixel opacity
						// Keep a float version of the new opacity--assigning it to r[3] now would turn result into a BYTE
						float new_opac = ((255.0 * (float)tg[3] + (float)r[3] * (255 - (float)tg[3])) / 255);
						r[2] =  ((255.0 * (float)tg[2] * (float)tg[3] + (float)r[2] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[1] =  ((255.0 * (float)tg[1] * (float)tg[3] + (float)r[1] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[0] =  ((255.0 * (float)tg[0] * (float)tg[3] + (float)r[0] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[3] = new_opac;
                    }


                    // Evaluate to next pixel
                    r += 4;
                    tg += 4;
                }}
                row -= width * 4;
                tilegraphic -= nextrow_shift;
            }
            sy += 1;
        }
            sy = 0;
        }
    }
    // Reset sx and oy values
    sx = 0;
	oy = data[1];
    // If top or bottom row needs redraw (only applies to ground layer)
    if ((data[4] & 4) > 0 || (data[4] & 8) > 0)
    {
        int y;

        RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
        LPBYTE row = (LPBYTE)(layer->lastRow);
        // Bottom row needs redraw, shift up
        if ((data[4] & 4) > 0)
        {
            y = oy / 32 + screen_h + offset_y;
            sy = screen_h;
            memmove(row + (width * 128), row, width * height * 4 - (width * 128));
			for (int i = 0; i < screen_w; i++)
				memcpy(row + (i * 4096), emptytile - 3968, 4096);
        }
        else
        {
            y = oy / 32;
            memmove(row, row + (width * 128), width * height * 4 - (width * 128));
			row += width * height * 4 - (width * 128);
			for (int i = 0; i <= screen_w; i++)
				memcpy(row + (i * 4096), emptytile - 3968, 4096);
        }

		//printf("Vert shift: y = %ld, ox = %ld, startx = %ld, endx = %ld\n", y, ox, ox / 32, ox / 32 + screen_w);

		// Redrawing process
        for (int z = 0; z < 3; z++){
			if (y < 0 || y >= (int)(mapdata->ysize))
				break;
        for (int x = ox / 32; x < ox / 32 + screen_w + 1; x++)
        {
			if (x >= (int)(mapdata->xsize))
				break;
			else if (x < 0)
			{
				sx+=1;
				continue;
			}

            LPBYTE tilegraphic;
            LPBYTE row;
			int nextrow_shift;
            // Get tile id and its priority
            int tile_id = mapdata->data[x + (y * mapdata->xsize) + (z * mapdata->xsize * mapdata->ysize)];
            int priority = prioritydata->data[tile_id];
			// If user wants to limit highest level of priority in their game
			if (priority > data[5])
				priority = data[5];
            // If tile id comes from tileset (not an autotile)
            if (tile_id >= 384)
            {
                tile_id -= 384;
                if ((z == 0 && range_data[y + x * mapdata->ysize] != 1) || (z == 1 && range_data[(y+1) + x * mapdata->ysize] != 1))
                    tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[0]<<1)) ->bm->bminfo->firstRow);
                else
                    tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[8]<<1)) ->bm->bminfo->firstRow);
                // Based on tile id, set pointer to corrisponding tile graphic
                tilegraphic += (tile_id % 8 * 128) - (tile_id / 8 * 32768);
				nextrow_shift = 1024;
            }
            else if (tile_id >= 48) // Autotile
            {
				int autotile_id = tile_id / 48;
				RGSSBITMAP* autotile_bm = (RGSSBITMAP*)(bitmaps[autotile_id]<<1);
				tilegraphic = (LPBYTE)(autotile_bm->bm->bminfo->firstRow);
				tile_id %= 48;
				tilegraphic += (tile_id % 8 * 128 + 1024 * autotiledata[(autotile_id - 1) * 2]) -
					((tile_id / 8) * autotile_bm->bm->bminfo->infoheader->biWidth * 4 * 32);
				nextrow_shift = autotile_bm->bm->bminfo->infoheader->biWidth * 4;
            }
            else
            {
                // Because there is no tile to be drawn and this is on higher layers, no need to clear or draw anything
                if (z != 0)
                {
                    sx += 1;
                    continue;
                }
                tilegraphic = emptytile;
				nextrow_shift = 128;
            }

            // If tile has priority
            if (priority > 0 && tilegraphic != emptytile)
            {
                // Get the bitmap corrisponding to this layer
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[priority + (y - oy/32)]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow) - ((data[5]-priority) * width * 128);
                row += sx * 128 - (mod_x * 4);
            }
            else
            {
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow);
                row -= ((sy * 32 - mod_y) * width * 4);
                row += sx * 128 - (mod_x * 4);
            }
            int height_to_evaluate;
            height_to_evaluate = 32;

			//printf("tileid = %ld, priority = %ld, row = %ld", tile_id, priority, row);

			// Make many blt/pixel transfers
            for (int i = 0; i < height_to_evaluate; i++)
            {
                // If bottom layer, just straight copy-paste pixel color data
                if (z == 0)
                    memcpy(row, tilegraphic, 32 * 4);
				else // Need to use alpha blending and eval pixel by pixel now
                {

                // Temp values for row and tilegraphic (we want to keep row and tilegraphic pointing to the far left pixel of their draw area
                // while these variables increment)
                LPBYTE r = row;
                LPBYTE tg = tilegraphic;
                // Evaluate each pixel
                int width_to_evaluate;
                width_to_evaluate = 32;

                for (int pix = 0; pix < width_to_evaluate; pix++)
                {
                    // If pixel has no transparency, straight copy it
                    if (tg[3] == 255)
                        memcpy(r, tg, 4);
                    // If pixel is not fully transparent, apply alpha blending
                    else if (tg[3] > 0)
                    {
                        float dst_opac = r[3]; // Save layer's pixel opacity
						// Keep a float version of the new opacity--assigning it to r[3] now would turn result into a BYTE
						float new_opac = ((255.0 * (float)tg[3] + (float)r[3] * (255 - (float)tg[3])) / 255);
						r[2] =  ((255.0 * (float)tg[2] * (float)tg[3] + (float)r[2] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[1] =  ((255.0 * (float)tg[1] * (float)tg[3] + (float)r[1] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[0] =  ((255.0 * (float)tg[0] * (float)tg[3] + (float)r[0] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
						r[3] = new_opac;
                    }
                    // Evaluate to next pixel
                    r += 4;
                    tg += 4;
                }}
                row -= width * 4;
                tilegraphic -= nextrow_shift;
            }
            sx += 1;
        }
            sx = 0;
        }
    }

	return 0;
}



int DrawAutotileUpdate(int x, int y, int sx, int sy, bool* redraw, long * layers, long * bitmaps, long * autotiledata, long * data, long * range_data)
{
	//printf("sx = %ld, sy = %ld\n", sx,sy);
	// Load map data and priority tables
	TABLESTRUCT * mapdata = ((TABLEDATA*)(data[2]<<1))->tablevars;
	TABLESTRUCT * prioritydata = ((TABLEDATA*)(data[3]<<1))->tablevars;
	// Gets the screen resolution from the ground layer bitmap
	int screen_w = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biWidth - 32;
	//int screen_h = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biHeight - 32;

	int ox = data[0];
	int oy = data[1];

	// Store width of screen elsewhere
	DWORD width = screen_w + 32;

	LPBYTE row;

	// Clear out priority layers
	for (int i = 0; i < 6; i++)
	{
		// If this priority layer needs redrawing
		if (redraw[i])
		{
			// If not ground layer
			if (i > 0)
            {
                // Get the bitmap corrisponding to this layer
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[i + (y - oy/32)]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow) - ((data[5]-i) * width * 128);
                row += sx * 128;
            }
            else
            {
                RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
                row = (LPBYTE)(layer->firstRow);
                row -= ((sy * 32) * width * 4);
                row += sx * 128;
            }
			// Clear out 32x32 area on this layer
			for (int i = 0; i < 32; i++)
            {
				memcpy(row, emptytile, 32 * 4);
				row -= width * 4;
			}
		}
	}
	// Based on ox and oy, figure out what tile_ids we need to look at in table
	for (int z = 0; z < 3; z++){
		LPBYTE tilegraphic;
		LPBYTE row;
		int nextrow_shift;
		// Get tile id and its priority
		int tile_id = mapdata->data[x + (y * mapdata->xsize) + (z * mapdata->xsize * mapdata->ysize)];
		int priority = prioritydata->data[tile_id];
		// If user wants to limit highest level of priority in their game
		if (priority > data[5])
			priority = data[5];
		// This tile exists on priority level that doesn't require updating/redrawing; skip it
		if (!redraw[priority]) continue;

		// If tile id comes from tileset (not an autotile)
		if (tile_id >= 384)
		{
			tile_id -= 384;
			tilegraphic = (LPBYTE)(((RGSSBITMAP*)(bitmaps[0]<<1)) ->bm->bminfo->firstRow);
			// Based on tile id, set pointer to corrisponding tile graphic
			tilegraphic += (tile_id % 8 * 128) - (tile_id / 8 * 32768);
			nextrow_shift = 1024;
		}
		else if (tile_id >= 48) // Autotile
		{
			int autotile_id = tile_id / 48;
			RGSSBITMAP* autotile_bm = (RGSSBITMAP*)(bitmaps[autotile_id]<<1);
			tilegraphic = (LPBYTE)(autotile_bm->bm->bminfo->firstRow);
			tile_id %= 48;
			tilegraphic += (tile_id % 8 * 128 + 1024 * autotiledata[(autotile_id - 1) * 2]) -
				((tile_id / 8) * autotile_bm->bm->bminfo->infoheader->biWidth * 4 * 32);
			nextrow_shift = autotile_bm->bm->bminfo->infoheader->biWidth * 4;

		}
		else
        {
			continue;
        }

		// If tile has priority
		if (priority > 0)
		{
			// Get the bitmap corrisponding to this layer
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[priority + sy]<<1)) -> bm -> bminfo;
			row = (LPBYTE)(layer->firstRow) - ((data[5]-priority) * width * 128);
			row += sx * 128;

		}
		else
		{
			RGSSBMINFO *layer = ((RGSSBITMAP*) (layers[layers[0]]<<1)) -> bm -> bminfo;
			row = (LPBYTE)(layer->firstRow);
			row -= ((sy * 32) * width * 4);
			row += sx * 128;
		}

		// Make many blt/pixel transfers
		for (int i = 0; i < 32; i++)
		{
			// If bottom layer, just straight copy-paste pixel color data
			if (z == 0)
				memcpy(row, tilegraphic, 32 * 4);
			else // Need to use alpha blending and eval pixel by pixel now
			{

			// Temp values for row and tilegraphic (we want to keep row and tilegraphic pointing to the far left pixel of their draw area
			// while these variables increment)
			LPBYTE r = row;
			LPBYTE tg = tilegraphic;
			// Evaluate each pixel
			for (int pix = 0; pix < 32; pix++)
			{
				// If pixel has no transparency, straight copy it
				if (tg[3] == 255)
					memcpy(r, tg, 4);
				// If pixel is not fully transparent, apply alpha blending
				else if (tg[3] > 0)
				{
					float dst_opac = r[3]; // Save layer's pixel opacity
					// Keep a float version of the new opacity--assigning it to r[3] now would turn result into a BYTE
					float new_opac = ((255.0 * (float)tg[3] + (float)r[3] * (255 - (float)tg[3])) / 255);
					r[2] =  ((255.0 * (float)tg[2] * (float)tg[3] + (float)r[2] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[1] =  ((255.0 * (float)tg[1] * (float)tg[3] + (float)r[1] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[0] =  ((255.0 * (float)tg[0] * (float)tg[3] + (float)r[0] * dst_opac * (255.0 - (float)tg[3])) / new_opac / 255.0);
					r[3] = new_opac;
				}
				// Evaluate to next pixel
				r += 4;
				tg += 4;
			}}
			row -= width * 4;
			tilegraphic -= nextrow_shift;
		}
	}

	return 0;
}



extern "C" __declspec (dllexport) int UpdateAutotiles(long * layers, long * bitmaps, long * autotiledata, long * data, long * range_data)
{
	// Load map data and priority tables
	TABLESTRUCT * mapdata = ((TABLEDATA*)(data[2]<<1))->tablevars;
	TABLESTRUCT * prioritydata = ((TABLEDATA*)(data[3]<<1))->tablevars;
	// Gets the screen resolution from the ground layer bitmap
	int screen_w = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biWidth - 32;
	int screen_h = ((RGSSBITMAP*)(layers[layers[0]]<<1))->bm->bminfo->infoheader->biHeight - 32;
	// Store width of screen elsewhere
	DWORD width = screen_w + 32;
	// If the resolution width/height is not divisible by 32, increase it by 32 to "trick" code
	// Might be a problem...
	if (screen_w % 32 != 0)
		screen_w += 32;
	if (screen_h % 32 != 0)
		screen_h += 32;
	// Changes pixel dimensions into RMXP tile dimensions (i.e. number of 32x32 pixel squares)
	screen_w /= 32;
	screen_h /= 32;
	// Get map OX and OY
	int ox = data[0];
	int oy = data[1];

	if (ox < 0 && ox % 32 != 0)
		ox -= 32;
	int sx = 0;
	int sy = 0;

	//printf("%ld, %ld\n", ox / 32, ox / 32 + screen_w + 1);
	// Based on ox and oy, figure out what tile_ids we need to look at in table
	for (int y = oy / 32; y < oy / 32 + screen_h + 1; y++){
		if (y >= (int)(mapdata->ysize))
			break;
		else if (y < 0)
		{
			sy+=1;
			continue;
		}
	for (int x = ox / 32; x < ox / 32 + screen_w + 1; x++){
		if (x >= (int)(mapdata->xsize))
			break;
		else if (x < 0)
		{
			sx+=1;
			continue;
		}
	bool redraw_layer[6] = {false, false, false, false, false, false};
	bool need_update = false;
	for (int z = 0; z < 3; z++){

		LPBYTE tilegraphic;
		LPBYTE row;
		int nextrow_shift;
		// Get tile id and its priority
		int tile_id = mapdata->data[x + (y * mapdata->xsize) + (z * mapdata->xsize * mapdata->ysize)];
		int priority = prioritydata->data[tile_id];
		// If user wants to limit highest level of priority in their game
		if (priority > data[5])
			priority = data[5];
		// If tile id comes from tileset (not an autotile)
		if (tile_id >= 384)
		{
			continue;
		}
		else if (tile_id >= 48) // Autotile
		{
			int autotile_id = tile_id / 48;
			// If this autotile doesn't need updating (flag equals zero), ignore and move on
			if (autotiledata[(autotile_id - 1) * 2 + 1] == 0)
			{
				continue;
			}
			//printf("Autotile %ld, %ld, %ld\n",x,ox,oy);
			redraw_layer[priority] = true;
			need_update = true;
		}
		else
        {
			continue;
        }
	}
	if (need_update)
		DrawAutotileUpdate(x, y, sx, sy, redraw_layer, layers, bitmaps, autotiledata, data, range_data);
	sx += 1;
	}
	sy += 1; sx = 0;
	}

	return 0;
}


// a sample exported function
bool DLL_EXPORT RadialGlow(long * bitmaps, long * tiledata)
{

    for (int index = 0; index < 16; index++)
    {
        RGSSBMINFO *bitmap = ((RGSSBITMAP*) (bitmaps[index]<<1)) -> bm -> bminfo;
        DWORD rowsize;
        DWORD width, height;
        LPBYTE row;
        long x, y;
        int shade;
        if(!bitmap) return false;

        width = 32;
        height = bitmap -> infoheader -> biHeight;

        int color1[4] = {255,255,255,160};
        int color2[4] = {181,225,0,140};
        int colordiff[4];
        for (int i = 0; i < 4; i++)
           colordiff[i] = color1[i] - color2[i];

        int x_coord;
        int y_coord;


        rowsize = 256 * 4;

        // For each 32x32 tile
        for (int tile_id = 0; tile_id < height * 8 / 32; tile_id++)
        {
            // Check if connected to another tile (not just a 32x32 tile)
            if (tiledata[tile_id] == 1) continue;
            // Check if this tile needs tile above it for radial
            int bonus_height = 0;
            if (tiledata[tile_id] == 2)
                bonus_height = 32;

            // Get pixel of top-left corner for this tile
            row = (LPBYTE) (bitmap -> firstRow) - ((tile_id - (bonus_height / 32 * 8)) / 8 * rowsize * 32) + (tile_id % 8 * 128);

            switch(index)
            {
            case 0:
                x_coord = 0;
                y_coord = 0;
                break;
            case 1:
                x_coord = 0;
                y_coord = (32 + bonus_height) / 4;
                break;
            case 2:
                x_coord = 0;
                y_coord = (32 + bonus_height) / 2;
                break;
            case 3:
                x_coord = 0;
                y_coord = (32 + bonus_height) * 3 / 4;
                break;
            case 4:
                x_coord = 0;
                y_coord = (32 + bonus_height) - 1;
                break;
            case 5:
                x_coord = width / 4;
                y_coord = (32 + bonus_height) - 1;
                break;
            case 6:
                x_coord = width / 2;
                y_coord = (32 + bonus_height) - 1;
                break;
            case 7:
                x_coord = width * 3 / 4;
                y_coord = (32 + bonus_height) - 1;
                break;
            case 8:
                x_coord = width - 1;
                y_coord = (32 + bonus_height) - 1;
                break;
            case 9:
                x_coord = width - 1;
                y_coord = (32 + bonus_height) * 3 / 4;
                break;
            case 10:
                x_coord = width - 1;
                y_coord = (32 + bonus_height) / 2;
                break;
            case 11:
                x_coord = width - 1;
                y_coord = (32 + bonus_height) / 4;
                break;
            case 12:
                x_coord = width - 1;
                y_coord = 0;
                break;
            case 13:
                x_coord = width * 3 / 4;
                y_coord = 0;
                break;
            case 14:
                x_coord = width / 2;
                y_coord = 0;
                break;
            case 15:
                x_coord = width / 4;
                y_coord = 0;
                break;
            }
            int threshold = pow(32, 2.0) + pow(32 + bonus_height, 2.0);

            for ( y = 0; y < 32 + bonus_height; y++) {
                LPBYTE r = row;
                for ( x = 0; x < 32; x++) {
                    if (r[3] == 0)
                    {
                        r += 4;
                        continue;
                    }

                    int distance = pow((x - x_coord), 2.0) + pow((y - y_coord), 2.0);
                    float percentage = (float)sqrt(distance * threshold) / (float)(threshold * 1.25);
                    //(float) pow(distance, 2.0) / pow(threshold, 2.0); // favors color1
                    //(float)distance / (float)threshold;               // normal
                    //(float)distance / (threshold * 2);                // favors color1
                    //(float)(distance + threshold) / (threshold * 2);  // favors color2

                    int final_color[4];
                    final_color[3] = color1[3] - colordiff[3] * percentage;
                    final_color[2] = color1[2] - colordiff[2] * percentage;
                    final_color[1] = color1[1] - colordiff[1] * percentage;
                    final_color[0] = color1[0] - colordiff[0] * percentage;

                    float dst_opac = r[3]; // Save layer's pixel opacity


                    // Keep a float version of the new opacity--assigning it to r[3] now would turn result into a BYTE
                    float new_opac = ((255.0 * (float)final_color[3] + (float)r[3] * (255 - (float)final_color[3])) / 255);
                    r[2] =  ((255.0 * (float)final_color[2] * (float)final_color[3] + (float)r[2] * dst_opac * (255.0 - (float)final_color[3])) / new_opac / 255.0);
                    r[1] =  ((255.0 * (float)final_color[1] * (float)final_color[3] + (float)r[1] * dst_opac * (255.0 - (float)final_color[3])) / new_opac / 255.0);
                    r[0] =  ((255.0 * (float)final_color[0] * (float)final_color[3] + (float)r[0] * dst_opac * (255.0 - (float)final_color[3])) / new_opac / 255.0);
                    r[3] = new_opac;


                    r += 4;
                }
                row -= rowsize;
            }
        }
    }

    return true;
}




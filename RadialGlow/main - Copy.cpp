#include "main.h"
#include <math.h>
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





// a sample exported function
bool DLL_EXPORT RadialGlow(long object, int direction)
{

    RGSSBMINFO *bitmap = ((RGSSBITMAP*) (object<<1)) -> bm -> bminfo;
    DWORD rowsize;
    DWORD width, height;
    LPBYTE row;
    long x, y;
    int shade;
    if(!bitmap) return false;

    width = bitmap -> infoheader -> biWidth;
    height = bitmap -> infoheader -> biHeight;

    int color1[4] = {255,255,255,160};
    int color2[4] = {181,225,0,140};
    int colordiff[4];
    for (int i = 0; i < 4; i++)
       colordiff[i] = color1[i] - color2[i];
    int x_coord;
    int y_coord;

    switch(direction)
    {
    case 0:
        x_coord = 0;
        y_coord = 0;
        break;
    case 1:
        x_coord = 0;
        y_coord = height / 4;
        break;
    case 2:
        x_coord = 0;
        y_coord = height / 2;
        break;
    case 3:
        x_coord = 0;
        y_coord = height * 3 / 4;
        break;
    case 4:
        x_coord = 0;
        y_coord = height - 1;
        break;
    case 5:
        x_coord = width / 4;
        y_coord = height - 1;
        break;
    case 6:
        x_coord = width / 2;
        y_coord = height - 1;
        break;
    case 7:
        x_coord = width * 3 / 4;
        y_coord = height - 1;
        break;
    case 8:
        x_coord = width - 1;
        y_coord = height - 1;
        break;
    case 9:
        x_coord = width - 1;
        y_coord = height * 3 / 4;
        break;
    case 10:
        x_coord = width - 1;
        y_coord = height / 2;
        break;
    case 11:
        x_coord = width - 1;
        y_coord = height / 4;
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

    int threshold = pow(width, 2.0) + pow(height, 2.0);
    rowsize = width * 4;
    row = (LPBYTE) (bitmap -> firstRow);
    for ( y = 0; y < (int) height; y++) {
        LPBYTE r = row;
        for ( x = 0; x < (int) width; x++) {
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
    return true;
}



unsigned int blendPreMulAlpha(unsigned int colora, unsigned int colorb, unsigned int alpha)
{
    unsigned int rb = (colora & 0xFF00FF) + (alpha * (colorb & 0xFF00FF)) >> 8;
    unsigned int g = (colora & 0x00FF00) + (alpha * (colorb & 0x00FF00)) >> 8;
    return (rb & 0xFF00FF) + (g & 0x00FF00);
}


unsigned int blendAlpha(unsigned int colora, unsigned int colorb, unsigned int alpha)
{
    unsigned int rb1 = ((0x100 - alpha) * (colora & 0xFF00FF)) >> 8;
    unsigned int rb2 = (alpha * (colorb & 0xFF00FF)) >> 8;
    unsigned int g1  = ((0x100 - alpha) * (colora & 0x00FF00)) >> 8;
    unsigned int g2  = (alpha * (colorb & 0x00FF00)) >> 8;
    return ((rb1 | rb2) & 0xFF00FF) + ((g1 | g2) & 0x00FF00);
}


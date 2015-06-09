#ifndef __MAIN_H__
#define __MAIN_H__

#include <windows.h>

/*  To use this exported function of dll, include this header
 *  in your project.
 */

#ifdef BUILD_DLL
    #define DLL_EXPORT __declspec(dllexport)
#else
    #define DLL_EXPORT __declspec(dllimport)
#endif


#ifdef __cplusplus
extern "C"
{
#endif

void DLL_EXPORT InitEmptyTile(long);
int DLL_EXPORT DrawMapsBitmap(long*, long*, long*, long*, long*);
int DLL_EXPORT DrawMapsBitmap2(long*, long*, long*, long*, long*);
int DLL_EXPORT UpdateAutotiles(long*, long*, long*, long*, long*);

bool DLL_EXPORT RadialGlow(long*, long*);

#ifdef __cplusplus
}
#endif

#endif // __MAIN_H__

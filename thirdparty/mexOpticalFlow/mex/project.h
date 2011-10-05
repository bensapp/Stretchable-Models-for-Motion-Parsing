// this is the project file that defines the purpose environment of the project to be compiled
#define _MATLAB

// #define _Windows

#ifndef _Windows
    #define __min(x,y) ((x)<(y)?(x):(y))
    #define __max(x,y) ((x)>(y)?(x):(y))
#endif
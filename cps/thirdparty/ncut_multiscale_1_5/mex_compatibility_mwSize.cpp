/*================================================================
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

mex_compatibility_mwSize
conversions for compatibility with mwSize
*=================================================================*/
#pragma once
//#include <assert.h>

#if MX_API_VER < 0x07030000
typedef int mwSize;//unsigned int? size_t?
typedef int mwIndex;
#endif 

// #ifdef IS_NO_MWSIZE
// typedef int mwSize;//unsigned int? size_t?
// typedef int mwIndex;
// #endif


inline int mwSize2int(mwSize m){
    int m2=(int)m;
    assert((mwSize)m2==m);//m<=pow(2,32)-1 ???
    return m2;
}
inline int mwIndex2int(mwIndex m){
    int m2=(int)m;
    assert((mwIndex)m2==m);//m<=pow(2,32)-1 ???
    return m2;
}
int mxGetM2(const mxArray *A){
    return mwSize2int(mxGetM(A));
}
int mxGetN2(const mxArray *A){
    return mwSize2int(mxGetN(A));
}
// const int*mxGetDimensions2(const mxArray *A){
//     const int *dims0 = mxGetDimensions(A);
//     int n=mxGetNumberOfDimensions(A);    
// }



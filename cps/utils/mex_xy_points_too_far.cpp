#include <math.h>
#include "mex.h"


// matlab entry point
// mex mex_xy_points_too_far.cpp
// (x1,y1) and (x2,y2) represent points, which are marked "too far" if either |x1-x2| > thresh || |y1-y2| > thresh
// too_far = mex_xy_points_too_far(x1,y1,x2,y2,thresh);
void mexFunction(int nlhs, mxArray *mxout[], int nrhs, const mxArray *in[]) {
    const int nargs = 5;
    if (nrhs != nargs)
        mexErrMsgTxt("Wrong number of inputs");
    
    
    const double* x1  = mxGetPr(in[0]);
    const double* y1  = mxGetPr(in[1]);
    const double* x2  = mxGetPr(in[2]);
    const double* y2  = mxGetPr(in[3]);
    const double thresh  = mxGetPr(in[4])[0];
    
    
    
    int n1 = mxGetN(in[0]);
    int n2 = mxGetN(in[2]);
    mxout[0] = mxCreateNumericMatrix(n1, n2, mxUINT8_CLASS, mxREAL);
    unsigned char* out = (unsigned char*)mxGetPr(mxout[0]);
    int outind = 0;
    for(int j=0; j<n2; j++){
        
        for(int i=0; i<n1; i++){
            out[outind++] = (fabs(x1[i]-x2[j])>thresh) || (fabs(y1[i]-y2[j])>thresh);
        }
    }
}

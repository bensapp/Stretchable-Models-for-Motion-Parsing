//You can include any C libraries that you normally use
#include <algorithm>
#include "mex.h"

/* 
 * mex_integer_histogram(values, weights, maxnum)
 * computes weighted histogram, like so:
 * h[values(i)] += weights[i];
 */

// mex utils/mex_integer_histogram.cpp


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    
    //run original code, as is, saving it to output.pgm
    //test_fun();
    
    if(nrhs != 3) {
        mexPrintf("function needs 3 arguments!\n");
        return;
    }
    
    int* x = (int*)mxGetPr(prhs[0]);
    double* w = mxGetPr(prhs[1]);
    int maxnum = ((int*)mxGetPr(prhs[2]))[0];
    const int* dims = mxGetDimensions(prhs[0]);
    int ndims = mxGetNumberOfDimensions(prhs[0]);
    
    int n = dims[0] > dims[1] ? dims[0] : dims[1];
    if(dims[0] == 0 || dims[1] == 0){
        n = 0;
    }
    
    int outdims[] = {maxnum,1};
    plhs[0] = mxCreateNumericArray(2,outdims,mxDOUBLE_CLASS,mxREAL);
    
    // important check to ensure integers > 0
    for(int i=0; i<n; i++){
        if(x[i] < 1) {
            mexPrintf("values must be > 0! x[%d] = %d\n",i,x[i]); return;
        }
        if(x[i] >= maxnum+1){
           mexPrintf("values must be < maxnum+1=%d, but x[%d] = %d!!\n",maxnum,i,x[i]); return;
        }
    }
   
    double* H = mxGetPr(plhs[0]);
    for(int i=0; i<n; i++){
//        if(x[i]>1){
//            mexPrintf("H[%d] += %f\n",x[i]-1,w[i]);
//        }
        H[x[i] - 1]+=w[i];
    }
    
    
    return;
    
}

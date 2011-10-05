/*
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

Computes efficiently the following:
classes = mex_extractMaxima(X);
[junk,classes]=max(X');
 */

#include <mex.h>
#include <math.h>
#include "mex_util.cpp"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int n,k;
    int i,j,c;
    int *classes;
    double *X;
    double *maximas;
    
    mwSize dims[1];
    
    n = mxGetM(prhs[0]);
    k = mxGetN(prhs[0]);
    X = mxGetPr(prhs[0]);
    
    dims[0] = n;
    
    maximas = (double*)mxCalloc(n , sizeof(double));
    plhs[0] = mxCreateNumericArray(1,dims,mxINT32_CLASS, mxREAL);
    classes = (int *)mxGetData(plhs[0]);
    for (i=0; i!=n; i++){
        maximas[i] = X[i];
        classes[i] = 1;
    }
    c = n;
    for (j=1; j!=k; j++) 
        for (i=0; i!=n; i++,c++)
            if (X[c] > maximas[i]){
                maximas[i] = X[c];
                classes[i] = j+1;
            }
    mxFree(maximas);
}


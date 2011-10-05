/*
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

Computes efficiently the following:
Y = mex_XindicatorTimesX(int32(classes),X);
[n,k] = size(X);
Xindicator=sparse(1:n,classes',1,n,k);
Y = Xindicator' * X;
 */

#include <mex.h>
#include <math.h>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int n,k;
    int i,j,c,nbElts,jTimesk;
    int *classes;
    double *X;
    double *Y;
    
    n = mxGetM(prhs[1]);
    k = mxGetN(prhs[1]);
    X = mxGetPr(prhs[1]);
    classes = (int *) mxGetData(prhs[0]);
    plhs[0] = mxCreateDoubleMatrix(k,k,mxREAL);
    Y = mxGetPr(plhs[0]);
    
    nbElts = k*k;    
    c = 0;
    for (j=0; j!=nbElts; j++)
        Y[c++] = 0;
    
    c = 0;        
    jTimesk = -1;
    for (j=0; j!=k; j++) {        
        for (i=0; i!=n; i++)
            Y[classes[i] + jTimesk ] += X[c++];
        jTimesk += k;
    }
}


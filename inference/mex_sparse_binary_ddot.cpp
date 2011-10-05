#include "mex.h"

/* mex -largeArrayDims mex_reorder_sparse_cols.cpp
 */

#define GETIND(nrow, i, j) (nrow*j + i)

void print_usage(){
    mexPrintf("USAGE:\n");
    mexPrintf("A = mex_sparse_binary_ddot(S, w)\n");
    mexPrintf(" INPUTS:\n");
    mexPrintf(" - M x N sparse S\n");
    mexPrintf(" - N x 1 double w\n");
    return;
}

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{  

    // --------------------------------------------------------
    // CHECK FOR VALID INPUT
    
    if (nrhs != 2) {
        print_usage();
        mexErrMsgTxt("Improper number of inputs.");
    }
    
    int M = mxGetM(prhs[0]);
    int N = mxGetN(prhs[0]);
        
    if (mxGetClassID(prhs[1]) != mxDOUBLE_CLASS) {
        print_usage();
        mexErrMsgTxt("new_order is not DOUBLE.");
    }
    
    if ( mxGetNumberOfElements(prhs[1]) != N) {
        print_usage();
        mexErrMsgTxt("new_order is incorrect size.");
    }
    
    if ( !mxIsSparse(prhs[0]) ) {
        print_usage();
        mexErrMsgTxt("S is not sparse.");
    }
    
    // --------------------------------------------------------
    // DO ACTUAL PROCESSING

    // Allocate output
    plhs[0] = mxCreateDoubleMatrix(M, 1, mxREAL);
    int numelResult = mxGetNumberOfElements(plhs[0]);
    double *sumvals = mxGetPr(plhs[0]);

    int numelWeights = mxGetNumberOfElements(prhs[1]);    
    double *weights = mxGetPr(prhs[1]);

    // get sparse matrix info
    mwIndex *irs = mxGetIr(prhs[0]);
    mwIndex *jcs = mxGetJc(prhs[0]);
    
    // make the 
    for (int j = 0; j < N; j++) {

        // get the values from the old one
        mwIndex startIdx = jcs[j];
        mwIndex endIdx = jcs[j+1];

        for (int idx = startIdx; idx < endIdx; idx++) {
        
            int row = irs[idx];
            if (row >= numelResult || row < 0) {
                mexPrintf("logical indexing of sparse hit out of bounds on row %d\n",row);
                mexErrMsgTxt("out of bounds array access");
            }
            
            if (j >= numelWeights){
                mexPrintf("bad feature value: %d!\n", j);
                mexErrMsgTxt("out of bounds array access");
            }
            
            sumvals[row] += weights[j];
        }
    }  
}


#include "mex.h"

/*
 

 n=10;
 A = reshape(1:100,n,n);
 inds1 = randint(n,1,[1 n]);
 inds2 = randint(n,1,[1 n]);
 
 mex mex_row_max_sparse_inds.cpp
 mex_row_max_sparse_inds(A,int32(inds1),int32(inds2))
 

 
 */

static inline int idx(int y, int x, int sy, int sx) { 
    return x*sy+y;
}

static inline int max(int x, int y) { return (x <= y ? y : x); }

// [maxvals,argmaxes] = mex_row_max_sparse_inds(double(X),int32(inds_row),int32(inds_col))
// this function is equivalent to X(~valid_inds)=-Inf; max(X,[],1),
// i.e., it ignores the missing zero elements
void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
        
{  
    
        const int nargs = 3;
    if (nrhs != nargs)
        mexErrMsgTxt("Wrong number of inputs");
    
    int ncols = mxGetN(prhs[0]);    
    int nrows = mxGetM(prhs[0]);
    int nnz = max(mxGetM(prhs[1]),mxGetN(prhs[1]));
    
     
    double realmin = -1.7e300; // ~realmin
    
    /* Allocate output */
    plhs[0] = mxCreateDoubleMatrix(1,ncols, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,ncols, mxREAL);
    

    double* X = mxGetPr(prhs[0]); 
    int* inds_row = (int*)mxGetPr(prhs[1]); 
    int* inds_col = (int*)mxGetPr(prhs[2]); 
    double* maxvals = mxGetPr(plhs[0]); 
    double* amaxes = mxGetPr(plhs[1]); 
    
//    mexPrintf("nrows = %d, ncols = %d, nnz = %d\n",nrows,ncols,nnz);
    
    for (int i=0; i<ncols; i++){ maxvals[i] = realmin;  amaxes[i] = 1;}
    
     /* aggregate maxes  */
    for (int i=0; i<nnz; i++) { 
        
        double val = X[idx(inds_row[i]-1,inds_col[i]-1,nrows,ncols)];
//        mexPrintf("(%d,%d) --> %f\n",inds_row[i],inds_col[i],val);
        
        if(val>maxvals[inds_col[i]-1]){
            maxvals[inds_col[i]-1] = val;
            amaxes[inds_col[i]-1] = inds_row[i];
        }
        
    }
}


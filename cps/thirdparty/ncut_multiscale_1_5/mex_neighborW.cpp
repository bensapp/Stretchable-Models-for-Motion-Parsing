//function W = mex_neighborW(p,q,connectivity);
// connectivity = 4|8
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

# include "math.h"
# include "mex.h"

void computeW_4(mwIndex *ir, mwIndex *jc, int p,int q) {
    int i,j,k;
    k = 0;
    int ind_j = 0;
    for (j=0;j<q;j++)
        for (i=0;i<p;i++) {
            jc[ind_j] = k;
            if(j>0)
                ir[k++] = ind_j-p;
            if(i>0)
                ir[k++] = ind_j-1;
            if(i<p-1)
                ir[k++] = ind_j+1;
            if(j<q-1)
                ir[k++] = ind_j+p;
            ind_j++;
        }
    jc[ind_j] = k;
}
void computeW_8(mwIndex *ir, mwIndex *jc, int p,int q) {
    int i,j,k;
    k = 0;
    int ind_j = 0;
    for (j=0;j<q;j++)
        for (i=0;i<p;i++) {
            jc[ind_j] = k;
            if(i>0&&j>0)
                ir[k++] = ind_j-p-1;
            if(j>0)
                ir[k++] = ind_j-p;
            if(i<p-1&&j>0)
                ir[k++] = ind_j-p+1;
            if(i>0)
                ir[k++] = ind_j-1;
            if(i<p-1)
                ir[k++] = ind_j+1;
            if(i>0&&j<q-1)
                ir[k++] = ind_j+p-1;
            if(j<q-1)
                ir[k++] = ind_j+p;
            if(i<p-1&&j<q-1)
                ir[k++] = ind_j+p+1;
            ind_j++;
        }
    jc[ind_j] = k;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    mxArray *W;
    int p,q,nnz,connectivity;
    
    connectivity = 4;
    
    p = (int)floor(mxGetScalar (prhs[0]));
    q = (int)floor(mxGetScalar (prhs[1]));
    
    if (nrhs>=3)
        connectivity = (int)floor(mxGetScalar (prhs[2]));
    if (connectivity == 4)
        nnz = 2*(2*p*q-(p+q));
    else
        nnz = 2*(2*p*q-(p+q) + 2*(p-1)*(q-1));
    
    W = mxCreateSparse(p*q,p*q,nnz,mxREAL);
    
    if (connectivity == 4)
        computeW_4(mxGetIr(W),mxGetJc(W),p,q);
    else
        computeW_8(mxGetIr(W),mxGetJc(W),p,q);
    plhs[0] = W;
    double *pr = mxGetPr(W);
    for(int i=0;i<nnz;i++)
        pr[i] = 1.0;
    
}
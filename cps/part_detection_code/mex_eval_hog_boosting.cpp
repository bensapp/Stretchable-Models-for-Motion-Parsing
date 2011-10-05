//You can include any C libraries that you normally use
#include "mex.h"

/*
 
mex mex_eval_hog_boosting.cpp
tic
a = mex_eval_hog_boosting(hfeats,int32(wsize),int32(feat_x), int32(feat_y), int32(feat_z), model.wfilter(:));
toc
 
 */

#define MAX(a, b)  (((a) > (b)) ? (a) : (b))
#define MINVAL 0

void print_usage(){
    mexPrintf("USAGE:\n");
    mexPrintf("mex_eval_hog_boosting(hfeats,wsize,feat_x, feat_y, feat_z, weights) for multiplication of features at locations (x,y,z) with weights\n");
    mexPrintf("or\n");
    mexPrintf("mex_eval_hog_boosting(hfeats,wsize,feat_x, feat_y, feat_z, thresh, highval,lowval) for boosting output\n");
    return;
}

// convert feature locations that are relative to a window of WSIZE
// located at absolute coordinates (X,Y) into absolute coordinates, and
// access the corresponding feature value
double inline get_feature_value(const double* feats, const int* wsize, const int* dims, const int fx, const int fy, const int fz,const int x,const int y) {
    
    //assume f{x,y,z} in 1-based indices, and convert to 0-based indices
    int absx = x - wsize[1]/2 + fx - 1;
    int absy = y - wsize[0]/2 + fy - 1;
    int absz = fz-1;
    int ind = dims[0]*dims[1]*absz + absx*dims[0] + absy;
    
    // pretend out-of-bounds has value 0 everywhere
    double val = 0;
    if(absx >= 0 && absx < dims[1] && absy >= 0 && absy < dims[0] && absz >= 0 && absz < dims[2]) {
        val = feats[ind];
    } 
    //else {mexPrintf("INVALID: ");}
    
    //mexPrintf("f(%d,%d,%d) @ c(%d,%d) -> (%d,%d,%d) = %d, val = %f\n",fx,fy,fz,x,y,absx,absy,absz,ind,val);
    return val;
    
    
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *in[])
{
    
    bool is_mult = 0;
    if(nrhs == 6) {
        is_mult = 1;
    } else if(nrhs != 8) {
        print_usage();
        return;
    }
    
    double* feats = mxGetPr(in[0]);
    int* wsize = (int*)mxGetPr(in[1]);
    int* featx = (int*)mxGetPr(in[2]);
    int* featy = (int*)mxGetPr(in[3]);
    int* featz = (int*)mxGetPr(in[4]);
    
    double* weights = NULL;
    double* hval = NULL;
    double* lval = NULL;
    double* thresh = NULL;
    if(is_mult){
        weights = mxGetPr(in[5]);
    } else {
        thresh = mxGetPr(in[5]);
        hval = mxGetPr(in[6]);
        lval = mxGetPr(in[7]);
    }
    const int nvals = MAX(mxGetN(in[5]),mxGetM(in[5]));
    const int* dims = mxGetDimensions(in[0]);
    const int nrows = dims[0];
    const int ncols = dims[1];

    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    double* out = mxGetPr(plhs[0]);
    
    //fill in heatmap with default value
        for(int i=0; i<dims[0]*dims[1]; i++) { out[i] = MINVAL; }
    
//     mexPrintf("nrows,ncols,nz = %d x %d x %d \n",dims[0],dims[1],dims[2]);
    
    int startx = 0; wsize[1]/2;
    int starty = 0; wsize[0]/2;
    int endx = ncols - 1; ncols - wsize[1]/2 - 1;
    int endy = nrows - 1; nrows - wsize[0]/2 - 1;
    
//     mexPrintf("start = (%d,%d), end = (%d, %d)\n",startx,starty,endx,endy);
    
    double si = 0;
    double vali = 0;
    for(int y=starty; y<=endy; y++){
        for(int x=startx; x<=endx; x++){
            
            // inner evaluation loop
            double s = 0;
            for(int i=0; i<nvals; i++) {
                vali = get_feature_value(feats,wsize,dims,featx[i],featy[i],featz[i],x,y);
                if(is_mult){
                    si = vali*weights[i];
                }
                else {
                    si = vali > thresh[i] ? hval[i] : lval[i];
                }
                
                s = s + si;
            }
            out[x*nrows+y] = s;
        }
    }
    
    return;
    
}

#include <math.h>
#include "mex.h"
#include "mex_utils.h"
#include <vector>

using namespace std;

static inline int idx(int y, int x, int sy, int sx) {
    return x*sy+y;
}

static inline int idx(int y, int x, int z, int sy, int sx, int sz) {
    return z*sx*sy+x*sy+y;
}

static inline int idx(int y, int x, int z, int w, int sy, int sx, int sz, int sw) {
    return w*sx*sy*sz+z*sx*sy+x*sy+y;
}



/*
 * load tmp.mat
 mex mex_limb_pair_geometry_sparse_inds.cpp
 * mex_limb_pair_geometry(joints,parent_joints,uv,parent_uv,parent_uv_orth,angles,parent_angles)
 *
 */

// matlab entry point
// inds1, inds2 denote the pairs to be computed
// geom_feats = mex_limb_pair_geometry(inds1,inds2,joints,parent_joints,uv,parent_uv,parent_uv_orth,angles,parent_angles)
void mexFunction(int nlhs, mxArray *mxout[], int nrhs, const mxArray *in[]) {
    const int nargs = 9;
    if (nrhs != nargs)
        mexErrMsgTxt("Wrong number of inputs");
    
    const int* inds1 = (int*)mxGetPr(in[0]);
    const int* inds2 = (int*)mxGetPr(in[1]);
    const double* joints  = mxGetPr(in[2]);
    const double* parent_joints  = mxGetPr(in[3]);
    const double* uv  = mxGetPr(in[4]);
    const double* parent_uv  = mxGetPr(in[5]);
    const double* parent_uv_orth  = mxGetPr(in[6]);
    const double* angles = mxGetPr(in[7]);
    const double* parent_angles = mxGetPr(in[8]);
    
    // dimension error checking: everything should be 2 x nstates
    for(int i=2; i < nargs-2; i++)
        if(mxGetM(in[i]) != 2){
        mexPrintf("size(in[%d],1) = %d ---> ", i, mxGetM(in[i]));
        mexErrMsgTxt("dimension mismatch");
        }
    
    int N = mxGetM(in[0]);
    int nstates1 = mxGetN(in[3]);
    int nstates2 = mxGetN(in[4]);
    if(mxGetM(in[1]) != N) mexErrMsgTxt("dimension mismatch");
    
    if(mxGetN(in[2]) != mxGetN(in[4]) || mxGetN(in[3]) != mxGetN(in[5])){
        mexErrMsgTxt("dimension mismatch");
    }

    const int nfeats = 5;
    mxout[0] = mxCreateNumericMatrix(nfeats, N, mxDOUBLE_CLASS, mxREAL);
    double* out = mxGetPr(mxout[0]);
    for(int i=0; i<N; i++){
        int i1 = inds1[i];
        int i2 = inds2[i];
        
        int pind = idx(0, i2, 2, nstates2);
        double px = parent_joints[pind];
        double py = parent_joints[pind+1];
        double pu = parent_uv[pind];
        double pv = parent_uv[pind+1];
        double pu_orth = parent_uv_orth[pind];
        double pv_orth = parent_uv_orth[pind+1];
        double pangle = parent_angles[i2];
        
        int ind = idx(0, i1, 2, nstates1);
        double x = joints[ind];
        double y = joints[ind+1];
        double u = uv[ind];
        double v = uv[ind+1];
        double angle = angles[i1];
        

        // feature 1: project difference vector onto parent's uv/uv_orth coordinate axes
        double dx = x - px;
        double dy = y - py;
        double proj_joint_uv = dx*pu+dy*pv;
        double proj_joint_uv_orth = dx*pu_orth+dy*pv_orth;
        
        // feature 2: project angle vector onto parent's uv/uv_orth coordinate axes
        double proj_angle_uv = u*pu+v*pv;
        double proj_angle_uv_orth = u*pu_orth+v*pv_orth;
        //normalize
        double alpha = 1/sqrt(proj_angle_uv*proj_angle_uv+proj_angle_uv_orth*proj_angle_uv_orth);
        proj_angle_uv*=alpha;
        proj_angle_uv_orth*=alpha;
        
        /*
        mexPrintf("i1=%d, i2=%d\n", i1, i2);
        mexPrintf("u=%f, v=%f, pu=%f, pv=%f, pu_orth=%f, pv_orth=%f\n",u,v,pu,pv,pu_orth,pv_orth);
        mexPrintf("alpha=%f, proj_angle_uv=%f, proj_angle_uv_orth=%f\n",alpha, proj_angle_uv,proj_angle_uv_orth);
        */
        
        int outind = idx(0,i,nfeats, N);
        out[outind+0] = proj_joint_uv;
        out[outind+1] = proj_joint_uv_orth;
        out[outind+2] = proj_angle_uv;
        out[outind+3] = proj_angle_uv_orth;
        out[outind+4] = pangle - angle;
        
    }
    
//    mxout[0] = vectorToMxArray(results);
    
}

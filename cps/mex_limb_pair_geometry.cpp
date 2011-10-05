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
load tmp.mat
mex mex_limb_pair_geometry.cpp
mex_limb_pair_geometry(joints,parent_joints,uv,parent_uv,parent_uv_orth,angles,parent_angles)

*/

// matlab entry point

// geom_feats = mex_limb_pair_geometry(joints,parent_joints,uv,parent_uv,parent_uv_orth,angles,parent_angles)
void mexFunction(int nlhs, mxArray *mxout[], int nrhs, const mxArray *in[]) {
    const int nargs = 7;
    if (nrhs != nargs)
        mexErrMsgTxt("Wrong number of inputs");
    
    const double* joints  = mxGetPr(in[0]);
    const double* parent_joints  = mxGetPr(in[1]);
    const double* uv  = mxGetPr(in[2]);
    const double* parent_uv  = mxGetPr(in[3]);
    const double* parent_uv_orth  = mxGetPr(in[4]);
    const double* angles = mxGetPr(in[5]);
    const double* parent_angles = mxGetPr(in[6]);
    
    // dimension error checking: everything should be 2 x nstates
    for(int i=0; i < nargs-2; i++)
        if(mxGetM(in[i]) != 2){
           mexPrintf("size(in[%d],1) = %d ---> ",i,mxGetM(in[i]));
            mexErrMsgTxt("dimension mismatch");
        }
    
    int nstates1 = mxGetN(in[0]);
    int nstates2 = mxGetN(in[1]);
    if(mxGetN(in[0]) != mxGetN(in[2]) || mxGetN(in[1]) != mxGetN(in[3])){
            mexErrMsgTxt("dimension mismatch");
    }
    
    const int nfeats = 5;
    int nstates_squared = nstates1*nstates2;
    mxout[0] = mxCreateNumericMatrix(nfeats, nstates_squared, mxDOUBLE_CLASS, mxREAL);
    double* out = mxGetPr(mxout[0]);
    for(int i=0; i<nstates2; i++){
        int pind = idx(0,i,2,nstates2);
        double px = parent_joints[pind];
        double py = parent_joints[pind+1];
        double pu = parent_uv[pind];
        double pv = parent_uv[pind+1];
        double pu_orth = parent_uv_orth[pind];
        double pv_orth = parent_uv_orth[pind+1];
        double pangle = parent_angles[i];


//        mexPrintf("(%d): %.05f %.05f %.05f %.05f \n",pind, px,py,pu,pv);
        for(int j=0; j<nstates1; j++){
            int ind = idx(0,j,2,nstates1);
            double x = joints[ind];
            double y = joints[ind+1];
            double u = uv[ind];
            double v = uv[ind+1];
            double angle = angles[j];
            
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

            
            int outind = idx(0,j + nstates1*i,nfeats,nstates_squared);
//            mexPrintf("[0,%d] --> outind = %d\n",outind,j + nstates2*i);
           
            
            out[outind+0] = proj_joint_uv;
            out[outind+1] = proj_joint_uv_orth;
            out[outind+2] = proj_angle_uv;
            out[outind+3] = proj_angle_uv_orth;
            out[outind+4] = pangle - angle;
           
            
//            v_ij.push_back(proj_joint_uv);
//            v_ij.push_back(proj_joint_uv_orth);
//            v_ij.push_back(proj_angle_uv);
//            v_ij.push_back(proj_angle_uv_orth);
//            results.push_back(v_ij);
        }
        

    }

//    mxout[0] = vectorToMxArray(results);

   
}

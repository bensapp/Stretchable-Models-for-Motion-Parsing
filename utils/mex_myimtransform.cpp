//You can include any C libraries that you normally use
#include "mex.h"

/*

 mex utils/mex_myimtransform.cpp
 mex_imtransform(img,Tinv)

 */

//function mex_imtransform(img,Tinv,dims)
//Tinv must be 3x3 transformation matrix
//img must be 2d double matrix (rgb not supported yet)
//dims is dimensions of output img

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *in[])
{
    
    if(nrhs < 5) {
        mexPrintf("function mex_imtransform(img,Tinv,dims,do_mirror)\n\n \
                Tinv must be 3x3 transformation matrix\n \
                img must be 2d double matrix(rgb not supported yet)\n \
                dims is dimensions of output img\n \
                bool do_mirror mirrors the image if the mapping is out of bounds\n");
                return;
    }
    
    double* img = mxGetPr(in[0]);
    double* Tinv = mxGetPr(in[1]);
    double padval = mxGetPr(in[2])[0];
    const int* dims = (const int*) mxGetPr(in[3]);
    bool do_mirror = mxGetPr(in[4])[0] > 0;
    
    const int ncols = mxGetN(in[0]);
    const int nrows = mxGetM(in[0]);

    plhs[0] = mxCreateNumericArray(2,dims,mxDOUBLE_CLASS,mxREAL);
    double* out = mxGetPr(plhs[0]);
    
    double t11 = Tinv[0];
    double t21 = Tinv[1];
    double t31 = Tinv[2];
    double t12 = Tinv[3];
    double t22 = Tinv[4];
    double t32 = Tinv[5];
    double t13 = Tinv[6];
    double t23 = Tinv[7];
    double t33 = Tinv[8];
    
    double y_from,x_from,z;
    int y_from_idx,x_from_idx;
    
//     mexPrintf("dims = %d x %d \n",dims[0],dims[1]);
//     mexPrintf("nrows,ncols = %d x %d \n",nrows,ncols);
       
    //assume matlab, 1-based indexing
    for(int y=1;y<=dims[0];y++){
        for(int x=1; x<=dims[1]; x++){
            
            x_from = t11*x + t12*y+t13;
            y_from =t21*x + t22*y+t23;
            z = t31*x+t32*y+t33;
           
            y_from_idx = int(y_from/z + 0.5);
            x_from_idx = int(x_from/z + 0.5);
            
            bool oob = (x_from_idx < 1 || y_from_idx < 1 || x_from_idx > ncols || y_from_idx > nrows);
            
            /*
            if(!oob) {
                mexPrintf("out[%d (%d,%d)] = img[%d (%d,%d)]\n",(x-1)*nrows+(y-1),x,y,(x_from_idx-1)*nrows + (y_from_idx-1),x_from_idx,y_from_idx);
            }
            else {
                mexPrintf("OOB: out[%d (%d,%d)]\n",(x-1)*nrows+(y-1),x,y);
            }
             */

            if(oob && do_mirror){
                
                if(x_from_idx < 1) x_from_idx = -1*x_from_idx+1;
                if(y_from_idx < 1) y_from_idx = -1*y_from_idx+1;
                if(x_from_idx > ncols) x_from_idx = 2*ncols - x_from_idx + 1;
                if(y_from_idx > nrows) y_from_idx = 2*nrows - y_from_idx + 1; 
                
                // not handled: index could still be out of bounds after mirroring
                oob = (x_from_idx < 1 || y_from_idx < 1 || x_from_idx > ncols || y_from_idx > nrows);
            }

            out[(x-1)*dims[0]+(y-1)] = oob ? padval : img[(x_from_idx-1)*nrows + (y_from_idx-1)];
            
            
        }
    }

    return;
    
}

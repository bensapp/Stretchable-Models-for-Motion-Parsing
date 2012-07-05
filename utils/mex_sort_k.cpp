//function [val,ind]=mex_sort_k(X,k,isAscend);
// Timothee Cour, 20-Feb-2009 16:37:41 -- DO NOT DISTRIBUTE



# include "math.h"
# include "mex.h"
#include <string.h> /* needed for memcpy() */

//# include "a_times_b_cmplx.cpp"
# include "mex_math.cpp"
# include "mex_util.cpp"
# include "Matrix.cpp"

# include "QuicksortFirstK.cpp"

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
    mxClassID classID=mxGetClassID(in[0]);
    if(classID==mxDOUBLE_CLASS){
        QuicksortFirstK<double> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxSINGLE_CLASS){
        QuicksortFirstK<float> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else
        assert(0);
}

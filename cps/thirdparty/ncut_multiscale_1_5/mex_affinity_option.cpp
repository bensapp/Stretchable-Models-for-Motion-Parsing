/*================================================================
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE

* function W = mex_affinity_option(w_i,w_j,options);
*=================================================================*/

# undef NDEBUG

# include "mex.h"
# include "math.h"
# include "mex_math.cpp"
# include "mex_util.cpp"

# include "Affinity.cpp"
# include "Affinity_IC.cpp"
# include "Affinity_F.cpp"
# include "Affinity_hist.cpp"
# include "Affinity_multiscale.cpp"
# include "Affinity_multiscale_option.cpp"
# include "Affinity_multiscale_hist.cpp"

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {    
	int *ir2 = (int*)mxGetData(in[0]);
	int *jc2 = (int*)mxGetData(in[1]);
	int n=mxGetNumberOfElements(in[1])-1;

    const mxArray*options=in[2];
	char *mode=mxArrayToString(mxGetField(options, 0,"mode"));

	if(strcmp(mode,"IC")==0){
		Affinity_IC* affinity=new Affinity_IC(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else if(strcmp(mode,"F")==0){
		Affinity_F* affinity=new Affinity_F(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else if(strcmp(mode,"hist")==0){
		Affinity_hist* affinity=new Affinity_hist(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else if(strcmp(mode,"multiscale")==0){
		Affinity_multiscale* affinity=new Affinity_multiscale(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else if(strcmp(mode,"multiscale_option")==0){
		Affinity_multiscale_option* affinity=new Affinity_multiscale_option(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else if(strcmp(mode,"multiscale_hist")==0){
		Affinity_multiscale_hist* affinity=new Affinity_multiscale_hist(ir2, jc2, n, options);
		out[0] = affinity->computeW();
		delete affinity;
	}
	else
		mexErrMsgTxt("wrong input");
}

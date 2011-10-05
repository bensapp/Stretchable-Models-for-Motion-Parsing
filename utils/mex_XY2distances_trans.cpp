/*
// Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

 function D = mex_XY2distances_trans(X,Y);
 *X:kxn1
 *Y:kxn2
 */
#undef NDEBUG
#include <mex.h>
#include "mex_util.cpp"
#include <algorithm>
#include "Matrix.cpp"

//TODO:better with trick used in XY2distances

class Class1{
public:
	double*X;
	double*Y;
	double*D;
	int n1,n2,k;
	double temp;
	double*xi,*yj;
	void XY2distances(){
		for(int j=0;j<n2;j++){
			for(int i=0;i<n1;i++){
				xi=X+k*i;
				yj=Y+k*j;
				double d=0;
				for(int u=0;u<k;u++){
					temp=*xi++ - *yj++;
					//temp=xi[u] - yj[u];
					d+=temp*temp;
					//d+=(xi[u] - yj[u])*(xi[u] - yj[u]);
				}
				D[i+j*n1]=d;
			}
		}
	}
	void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
		k=mxGetM(in[0]);
		int k2=mxGetM(in[1]);
		assert(k==k2);
		n1=mxGetN(in[0]);
		n2=mxGetN(in[1]);
		assert(!mxIsSparse(in[0]) && !mxIsSparse(in[1]));
		assert(mxIsDouble(in[0]) && mxIsDouble(in[1]));
		X=mxGetPr(in[0]);
		Y=mxGetPr(in[1]);
		out[0]=mxCreateDoubleMatrix(n1,n2,mxREAL);
		D=mxGetPr(out[0]);
		XY2distances();
	}

};

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
	Class1 class1;
	class1.mexGate(nargout,out,nargin,in);
}

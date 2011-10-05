//function classes=mex_constraint_classes(p,q,p2,q2);
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


# include "math.h"
# include "mex.h"
# include "mex_math.cpp"

void constraint_classes(double*classes,int p,int q,int p2,int q2,int Lp,int Lq){
	int i=0,j=0,i2=0,j2=0,jw,iw;
	double k2=1;//matlab starts at 1
	for(j2=0;j2<q2;j2++){
		for(i2=0;i2<p2;i2++,k2++){//for all coarse rect
			for(jw=0;jw<Lq;jw++){
				for(iw=0;iw<Lp;iw++){
					i=i2*Lp+iw;
					j=j2*Lq+jw;
					if(i<p && j<q)
						classes[i+j*p]=k2;
				}
			}					
		}
	}
}

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
	int p = (int)mxGetScalar(in[0]);
	int	q = (int)mxGetScalar(in[1]);
	int p2 = (int)mxGetScalar(in[2]);
	int	q2 = (int)mxGetScalar(in[3]);
	//int Lp = (int)mxGetScalar(in[4]);
	//int Lq = (int)mxGetScalar(in[5]);
	int Lp=round2((double)p/p2);
	int Lq=round2((double)q/q2);
	out[0] = mxCreateDoubleMatrix(p,q,mxREAL);
	double*classes=mxGetPr(out[0]);
	constraint_classes(classes,p,q,p2,q2,Lp,Lq);
}
// class Affinity
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <vector>

using namespace std;

class Affinity {
public: 
	//	vector<Entry*>extremas;
	Affinity();
	Affinity(int*ir2_, int*jc2_,  int n_, const mxArray*mxArray_options_);
	virtual ~Affinity();
	mxArray* computeW();

protected:
	mxArray*mxArray_W;
	const mxArray*mxArray_F;
	const mxArray*mxArray_options;
	double*valW;
	mwIndex *ir,*jc;
    int *ir2,*jc2;
	int n;

	virtual void readOption();
	void computeAllWij();
	virtual double computeWij(int i,int j);
	double max_over_segment(int xi,int yi,int xj,int yj,double*map0,double*phase,int p,int q,int k_map,bool isPhase);
};

Affinity::Affinity(){
}
Affinity::Affinity(int*ir2_, int*jc2_, int n_, const mxArray*mxArray_options_){
	ir2=ir2_;
	jc2=jc2_;
	n=n_;
	mxArray_options=mxArray_options_;

	mxArray_W = mxCreateSparse(n,n,jc2[n],mxREAL);
	if (mxArray_W==NULL)
		mexErrMsgTxt("Not enough memory for the output matrix");    
	valW = mxGetPr(mxArray_W);
// 	ir = (int*)mxGetIr(mxArray_W);
// 	jc = (int*)mxGetJc(mxArray_W);
	ir = mxGetIr(mxArray_W);
	jc = mxGetJc(mxArray_W);
}
Affinity::~Affinity(){
}
void Affinity::readOption(){
}

mxArray* Affinity::computeW(){
	//
	computeAllWij();
	return mxArray_W;
}

void Affinity::computeAllWij(){
	int i, j, pi,pi2;    
	pi=0;
	for (j=0; j<n; j++) {
		jc[j] = pi;
		for (pi2=jc2[j]; pi2<jc2[j+1]; pi2++) {
			i = ir[pi] = ir2[pi2];
			valW[pi] = computeWij(i,j);
			pi++;
		}
	}
	jc[n] = pi;
}



double Affinity::max_over_segment(int xi,int yi,int xj,int yj,double*map0,double*phase,int p,int q,int k_map,bool isPhase){
	int n=p*q;
	double maxi=0;
	int dx,dy,x1,x2,y1,y2,abs_dmax,t,i1,i2;
	double linePointer,lineSlope;
	int step;
	bool dySupdx;
	int kr,kr_n;

	dx = (xi - xj);
	dy = (yi - yj);
	x1 = xj;
	y1 = yj;
	i1 = y1+x1*p;

	maxi = 0.0;

	if (abs(dy) >= abs(dx)) {
		abs_dmax = abs(dy);
		step = (yi>=yj) ? 1 : -1;
		lineSlope = (double)dx/abs_dmax;
		y2=yj;
		linePointer = 0.5+xj;
		dySupdx = 1;
	} else {
		abs_dmax = abs(dx);
		step = (xi>=xj) ? 1 : -1;
		lineSlope = (double)dy/abs_dmax;
		x2=xj;
		linePointer = 0.5+yj;
		dySupdx = 0;
	}

	for (t=0; t<abs_dmax; t++) {
		linePointer += lineSlope;// can cause roundoff errors ; write correct value if needed
		if (dySupdx) {
			x2=(int)(linePointer);
			y2+=step;
		} else {
			x2+=step;
			y2=(int)(linePointer);
		}
		i2 = y2+x2*p;

		if (isPhase && (phase[i2] != phase[i1]) )
			maxi = max(maxi , map0[i1] + map0[i2]);
		if(k_map>1){
			for(kr=1,kr_n = n;kr<k_map;kr++,kr_n+=n) {
				if (isPhase && (phase[i2+kr_n] != phase[i1+kr_n]) )
					maxi = max(maxi , map0[i1+kr_n] + map0[i2+kr_n]);                            
			}
		}
		x1=x2;
		y1=y2;
		i1 = i2;
	}

	return maxi*0.5;
}

double Affinity::computeWij(int i,int j){
	return 0;
}

double euclidian_dist(int i,int j,double*valF,int nF,int kF){
	double temp,dist=0;
	double*pvalFi=valF+i;
	double*pvalFj=valF+j;
	for(int k=0;k<kF;k++,pvalFi+=nF,pvalFj+=nF){
		temp=*pvalFi-*pvalFj;
		dist+=temp*temp;
	}
	return dist;
}
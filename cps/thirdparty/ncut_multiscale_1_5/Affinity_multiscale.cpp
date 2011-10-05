// class Affinity_multiscale
//based on code from Florence Benezit, 2004
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <vector>

using namespace std;

class Affinity_multiscale : public Affinity {
public: 
	Affinity_multiscale(int*ir2_, int*jc2_,int n_,const mxArray*mxArray_options_);

private:
	void readOption();
	double computeWij(int i,int j);

	int p0,q0,n0,k_emag,kF;
	double*emag;
	double*ephase;
	double*valF;
	int*location;
	bool isPhase;
};


Affinity_multiscale::Affinity_multiscale(int*ir2_, int*jc2_, int n_,const mxArray*mxArray_options_) : Affinity(ir2_,jc2_,n_,mxArray_options_) {
	readOption();
}

void Affinity_multiscale::readOption(){
	const mxArray *temp;
	temp = mxGetField(mxArray_options, 0,"emag");
	emag=mxGetPr(temp);
	getSizes(temp,p0,q0,k_emag);
	n0=p0*q0;

	temp = mxGetField(mxArray_options, 0,"ephase");
	ephase=mxGetPr(temp);

	temp = mxGetField(mxArray_options, 0,"isPhase");
	isPhase=(bool)mxGetScalar(temp);

	temp = mxGetField(mxArray_options, 0,"F");
	valF=mxGetPr(temp);
	kF=getSize3(temp);

	temp = mxGetField(mxArray_options, 0,"location");
	//int*location0=(int*)mxGetData(temp);
	int*location0=readInt32(temp);
	location=createArray(n,(int)0);
	for(int i=0;i<n;i++)
		location[i]=location0[i]-1;
}
double Affinity_multiscale::computeWij(int i,int j){
	double w=0;
	int xi, yi, xj, yj;

	if (i==j){
		w = 1;
		return w;
	}
	int zi=location[i];
	int zj=location[j];

	xi = zi / p0;
	yi = zi % p0;
	xj = zj / p0;
	yj = zj % p0;

	double maxi = max_over_segment(xi,yi,xj,yj,emag,ephase,p0,q0,k_emag,isPhase);
	double w_IC = exp(-maxi * maxi);

	double dist=euclidian_dist(zi,zj,valF,n0,kF);
	double w_kernel = exp(-dist);
	w=sqrt(w_IC*w_kernel)+0.1*w_IC;
	//w=w_IC;
	//w=w_kernel;
	return w;
}

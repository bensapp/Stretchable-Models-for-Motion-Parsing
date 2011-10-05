// class Affinity_multiscale_option
//based on code from Florence Benezit, 2004
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <vector>

using namespace std;

class Affinity_multiscale_option : public Affinity {
public: 
	Affinity_multiscale_option(int*ir2_, int*jc2_,int n_,const mxArray*mxArray_options_);

	enum Enum_mode {MODE_F,MODE_IC,MODE_MIXED,MODE_HIST};

private:
	void readOption();
	double computeWij(int i,int j);

	int p0,q0,n0,k_emag,kF;
	double*emag;
	double*ephase;
	double*valF;
	int*location;
	bool isPhase;

	string stringMode2;
	Enum_mode mode2;
};


Affinity_multiscale_option::Affinity_multiscale_option(int*ir2_, int*jc2_, int n_,const mxArray*mxArray_options_) : Affinity(ir2_,jc2_,n_,mxArray_options_) {
	readOption();
}

void Affinity_multiscale_option::readOption(){
	mxArrayStruct2array(mxArray_options,0,"mode2",stringMode2);
	if(stringMode2=="F")
		mode2=MODE_F;
	else if(stringMode2=="IC")
		mode2=MODE_IC;
	else if(stringMode2=="mixed")
		mode2=MODE_MIXED;
	else if(stringMode2=="hist")
		mode2=MODE_HIST;
	else
		printError;


	const mxArray *temp;


	if(mode2==MODE_IC || mode2==MODE_MIXED){
		temp = mxGetField(mxArray_options, 0,"emag");
		emag=mxGetPr(temp);
		getSizes(temp,p0,q0,k_emag);
		n0=p0*q0;

		temp = mxGetField(mxArray_options, 0,"ephase");
		ephase=mxGetPr(temp);

		temp = mxGetField(mxArray_options, 0,"isPhase");
		isPhase=(bool)mxGetScalar(temp);
	}

	if(mode2==MODE_F || mode2==MODE_MIXED){
		temp = mxGetField(mxArray_options, 0,"F");
		valF=mxGetPr(temp);

		getSizes(temp,p0,q0,kF);
		n0=p0*q0;
		//kF=getSize3(temp);
	}
	temp = mxGetField(mxArray_options, 0,"location");
    assert(mxIsDouble(temp));
    double*location0=mxGetPr(temp);
	//int*location0=(int*)mxGetData(temp);
// 	int*location0=readInt32(temp);
	location=createArray(n,(int)0);
	for(int i=0;i<n;i++)
		location[i]=(int)location0[i]-1;
}
double Affinity_multiscale_option::computeWij(int i,int j){
	double w=0;
	int xi, yi, xj, yj;

	if (i==j){
		w = 1.0;
		return w;
	}
	int zi=location[i];
	int zj=location[j];

	xi = zi / p0;
	yi = zi % p0;
	xj = zj / p0;
	yj = zj % p0;

	double maxi,w_IC,dist,w_kernel;
	if(mode2==MODE_IC || mode2==MODE_MIXED){
		maxi = max_over_segment(xi,yi,xj,yj,emag,ephase,p0,q0,k_emag,isPhase);
		w_IC = exp(-maxi * maxi);
	}
	if(mode2==MODE_F || mode2==MODE_MIXED){
		dist=euclidian_dist(zi,zj,valF,n0,kF);
		w_kernel = exp(-dist);
	}
	if(mode2==MODE_F)
		w=w_kernel;
	else if(mode2==MODE_IC)
		w=w_IC;
	else if(mode2==MODE_MIXED)
		w=sqrt(w_IC*w_kernel)+0.1*w_IC;
	else if(mode2==MODE_HIST)
		w=0;

	return w;
}

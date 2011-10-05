// class Affinity_IC
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <vector>

using namespace std;

class Affinity_IC : public Affinity {
public: 
	Affinity_IC(int*ir2_, int*jc2_,int n_,const mxArray*mxArray_options_);

private:
	void readOption();
	double computeWij(int i,int j);

	int p,q,k_emag;
	double*emag;
	double*ephase;
	bool isPhase;
};


Affinity_IC::Affinity_IC(int*ir2_, int*jc2_, int n_,const mxArray*mxArray_options_) : Affinity(ir2_,jc2_,n_,mxArray_options_) {
	readOption();
}

void Affinity_IC::readOption(){
	const mxArray *temp;
	temp = mxGetField(mxArray_options, 0,"emag");
	emag=mxGetPr(temp);
	getSizes(temp,p,q,k_emag);

	temp = mxGetField(mxArray_options, 0,"ephase");
	ephase=mxGetPr(temp);

	temp = mxGetField(mxArray_options, 0,"isPhase");
	isPhase=(bool)mxGetScalar(temp);
}
double Affinity_IC::computeWij(int i,int j){
	double w=0;
	int xi, yi, xj, yj;

	if (i==j){
		w = 1;
		return w;
	}

	xi = i / p;
	yi = i % p;
	xj = j / p;
	yj = j % p;

	double maxi = max_over_segment(xi,yi,xj,yj,emag,ephase,p,q,k_emag,isPhase);

	w = exp(-maxi * maxi);
	return w;
}

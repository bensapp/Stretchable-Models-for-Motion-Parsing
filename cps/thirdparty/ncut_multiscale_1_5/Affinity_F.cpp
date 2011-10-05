// class Affinity_IC
// Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


#include <math.h>
#include <matrix.h>
#include <mex.h>
#include <vector>

using namespace std;

class Affinity_F : public Affinity {
public: 
	Affinity_F(int*ir2_, int*jc2_,int n_,const mxArray*mxArray_options_);

private:
	void readOption();
	double computeWij(int i,int j);

	int kF;
	double*valF;
};


Affinity_F::Affinity_F(int*ir2_, int*jc2_, int n_,const mxArray*mxArray_options_) : Affinity(ir2_,jc2_,n_,mxArray_options_) {
	readOption();
}

void Affinity_F::readOption(){
	const mxArray *temp;
	temp = mxGetField(mxArray_options, 0,"F");
	valF=mxGetPr(temp);
	kF=mxGetNumberOfElements(temp)/n;
}
double Affinity_F::computeWij(int i,int j){
	double dist=euclidian_dist(i,j,valF,n,kF);
	double w=exp(-dist);
	return w;
}

//function D = mex_indij2distances_chisquared(F,indi,indj,isAllPairs);
//computes D=sum((F(:,indi)-F(:,indj)).^2,2);
//F:[d,n]
//F: double or single
//#undef NDEBUG
// Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

#include <math.h>
#include <mex.h>

//# include "mex_math.cpp"

//#include <algorithm>
//#include <vector>
//using namespace std;
#include "mex_util.cpp"
#include "Matrix.cpp"


// typedef float typeF;

template<class typeF> class Class1{
    public:
        Matrix<int>indi;
        Matrix<int>indj;
        // 	Matrix<double>F;
        typeF*F;
        Matrix<typeF>D;
        int d,n;
        void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
            // 		F.readmxArray(in[0]);
//             assert(mxIsDouble(in[0]) && !mxIsSparse(in[0]));
            assert(!mxIsSparse(in[0]));
            F=(typeF*)mxGetData(in[0]);
            d=mxGetM(in[0]);
            n=mxGetN(in[0]);
            
            indi.readmxArray(in[1]);
            indj.readmxArray(in[2]);
            indi.add(-1);
            indj.add(-1);
            
            bool isAllPairs=0;
            if(nargin>=4){                
                isAllPairs=(bool)mxGetScalar(in[3]);
            }
            if(isAllPairs){
                indij2distances_chisquared_all();
            }
            else{
                assert(indi.n==indj.n);
                indij2distances_chisquared();
            }
            out[0]=D.tomxArray();
        }
        void indij2distances_chisquared(){
            D.resize(indi.n,1);
            typeF*Fi,*Fj;
            typeF temp,temp2;
            
            typeF Fik,Fjk;
            for(int u=0;u<indi.n;u++){
                typeF Du=0;
                int i=indi[u];
                int j=indj[u];
                Fi=&F[i*d];
                Fj=&F[j*d];
                for(int k=0;k<d;k++){
                    Fik=*Fi++;
                    Fjk=*Fj++;
                    if((temp=Fik+Fjk)>0){
                        temp2=Fik-Fjk;
                        Du += temp2*temp2/temp;
                    }
                }
                D[u]=Du*0.5;
            }
        }
        void indij2distances_chisquared_all(){
            D.resize(indi.n,indj.n);
            typeF*Fi,*Fj;
            typeF temp,temp2;
           
            typeF Fik,Fjk;
            for(int u2=0;u2<indj.n;u2++){
//                  mexPrintf("%d/%d...\n",u2,indj.n);
                int j=indj[u2];
                for(int u1=0;u1<indi.n;u1++){
                    int i=indi[u1];
                    Fi=&F[i*d];
                    Fj=&F[j*d];

                    typeF Du=0;                    
                    for(int k=0;k<d;k++){
                        Fik=*Fi++;
                        Fjk=*Fj++;
                        if((temp=Fik+Fjk)>0){
                            temp2=Fik-Fjk;
                            Du += temp2*temp2/temp;
                        }
                    }
                    D[u1+u2*indi.n]=Du*0.5;
                }
            }
        }
};

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
    mxClassID classID=mxGetClassID(in[0]);
    if(classID==mxDOUBLE_CLASS){
        Class1<double>class1;
        class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxSINGLE_CLASS){
        Class1<float>class1;
        class1.mexGate(nargout,out,nargin,in);
    }
    else{
        assert(0);
    }
}

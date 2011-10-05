//function D = mex_indij2distances_fun(fun,F,indi,indj,isAllPairs);
// Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

/*
F: dxn
TODO:
 mex mex_indij2distances_fun.cpp
 
 *
valij = mex_indij2distances_fun('L2',H,indi,indj,0);

 */
//computes D=sum((F(:,indi)-F(:,indj)).^2,2);
//F:[d,n]
//F: double or single
//#undef NDEBUG
#include <math.h>
#include <mex.h>

//# include "mex_math.cpp"

//#include <algorithm>
//#include <vector>
//using namespace std;
#include "mex_util.cpp"
#include "Matrix.cpp"


// typedef float typeF;
//  #define CALL_MEMBER_FN(object,ptrToMember)  ((object).*(ptrToMember))
 
template<class typeF> class Class1{
    public:
        
        Matrix<int>indi;
        Matrix<int>indj;
//         unsigned int*indi;
//         unsigned int*indj;
//         int nindi,nindj;

        typeF*F;
        typeF*D;
        int d,n;
        
        typeF (Class1<typeF>::*fun)(typeF*Fi,typeF*Fj);
        
        void compute_fun(string fun_string){
            if(fun_string=="chi2")
                fun=&Class1<typeF>::fun_chi2;
            else if(fun_string=="hellinger")
                fun=&Class1<typeF>::fun_hellinger;
            else if(fun_string=="L2")
                fun=&Class1<typeF>::fun_L2;
             else if(fun_string=="L0")
                fun=&Class1<typeF>::fun_L0;
             else if(fun_string=="L1")
                fun=&Class1<typeF>::fun_L1;
            else
                assert(0);
        }
        
        typeF fun_chi2(typeF*Fi,typeF*Fj){
            typeF val=0;
            typeF temp,temp2,Fik,Fjk;
            for(int k=0;k<d;k++){
                Fik=*Fi++;
                Fjk=*Fj++;
                temp=Fik+Fjk;
                if(temp>0){
                    temp2=Fik-Fjk;
                    val += temp2*temp2/temp;
                }
            }
            return val*0.5;            
        }
        typeF fun_hellinger(typeF*Fi,typeF*Fj){
            typeF val=0;
            typeF temp;
            for(int k=0;k<d;k++){
                temp=(sqrt(*Fj++) - sqrt(*Fi++));
                val+=temp*temp;
            }
            return sqrt(val);            
        }
        typeF fun_L2(typeF*Fi,typeF*Fj){
            typeF val=0;
            typeF temp;
            for(int k=0;k<d;k++){
                temp=(*Fj++ - *Fi++);
                val+=temp*temp;
            }
            return sqrt(val);            
        }
        
        typeF fun_L0(typeF*Fi, typeF*Fj){
            typeF val=0;
            typeF temp;
            for(int k=0;k<d;k++){
                temp = (*Fj++ - *Fi++);
                val+=(temp!=0);
            }
            return val;            
        }
        
        typeF fun_L1(typeF*Fi, typeF*Fj){
            typeF val=0;
            typeF temp;
            for(int k=0;k<d;k++){
                val+= fabs(*Fj++ - *Fi++);
            }
            return val;            
        }
        
        void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
            string fun_string;
            mxArray2array(in[0],fun_string);
            compute_fun(fun_string);
            
            const mxArray*mx_F=in[1];
            assert(!mxIsSparse(mx_F));
            F=Matrix<typeF>::getData(mx_F);
            d=mxGetM(mx_F);
            n=mxGetN(mx_F);
            
            indi.readmxArray(in[2]);
            indj.readmxArray(in[3]);
            indi.add(-1);
            indj.add(-1);
            
            bool isAllPairs=0;
            if(nargin>=5){                
                isAllPairs=(bool)mxGetScalar(in[4]);
            }
            if(isAllPairs){
                out[0]=Matrix<typeF>::createmxArray_uninitialized(indi.n,indj.n);
                D=Matrix<typeF>::getData(out[0]);
                indij2distances_fun_all();
            }
            else{
                assert(indi.n==indj.n);
                out[0]=Matrix<typeF>::createmxArray_uninitialized(indi.n);
                D=Matrix<typeF>::getData(out[0]);
                indij2distances_fun();
            }
        }
        void indij2distances_fun(){
            typeF*Fi,*Fj;
            for(int u=0;u<indi.n;u++){
                typeF Du=0;
                int i=indi[u];
                int j=indj[u];
                Fi=&F[i*d];
                Fj=&F[j*d];
                D[u]=(this->*fun)(Fi,Fj);
            }
        }
        void indij2distances_fun_all(){
            typeF*Fi,*Fj;
            for(int u2=0;u2<indj.n;u2++){
                int j=indj[u2];
                for(int u1=0;u1<indi.n;u1++){
                    int i=indi[u1];
                    Fi=&F[i*d];
                    Fj=&F[j*d];
                    D[u1+u2*indi.n]=(this->*fun)(Fi,Fj);
                }
            }
        }
};

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
    mxClassID classID=mxGetClassID(in[1]);
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

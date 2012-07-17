/*
// Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

function images=mex_extractWindow(image,rhulls,is_allow_outside);
images=mex_extractWindow(image,rhulls,is_allow_outside);
image=mex_extractWindow(image,rhull,is_allow_outside);
*/
#undef NDEBUG
#include <math.h>
#include <mex.h>
#include "mex_util.cpp"
#include "mex_math.cpp"
#include "Matrix.cpp"
#include "Rhull.cpp"



template<class T>class Class1{
    public:
        vector<Rhull>rhulls;
        int x1,x2,y1,y2;
        T*image;
        T*image2;
        int p,q,k;
        int pw,qw;
        int nb;
        
        bool is_allow_outside;
        void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
            image=Matrix<T>::getData(in[0]);
            getSizes(in[0],p,q,k);
            if(mxIsCell(in[1])){
                int nb=mxGetNumberOfElements(in[1]);
                rhulls.resize(nb);
                for(int i=0;i<nb;i++){
                    rhulls[i].readmxArray(mxGetCell(in[1],i),true);
                }
            }
            else{
                assert(mxIsNumeric(in[1]));
                rhulls.resize(1);
                rhulls[0].readmxArray(in[1],true);
            }
            if(nargin<3)
                is_allow_outside=false;
            else
                is_allow_outside=(bool)(mxGetScalar(in[2]));
            
            pw=0;
            qw=0;
            
            nb=rhulls.size();
            if(nb){
                rhulls[0].getSize(pw,qw);
            }
            bool is_outside=false;
            for(int i=0;i<nb;i++){
                int pwi,qwi;
                Rhull&rhull=rhulls[i];
                rhull.getSize(pwi,qwi);
                assert(pwi==pw && qwi==qw);                
                if(!(rhull.x1>=0 && rhull.x2<p && rhull.y1>=0 && rhull.y2<q))
                    is_outside=true;
            }
            assert(is_allow_outside || !is_outside);
            if(is_outside)
                out[0]=Matrix<T>::createmxArray(pw,qw,k*nb);
            else
                out[0]=Matrix<T>::createmxArray_uninitialized(pw,qw,k*nb);
            
            image2=Matrix<T>::getData(out[0]);
            extractWindow_layers_rhulls();
        }
        void extractWindow_layers_rhulls(){
            for(int ind=0;ind<nb;ind++){
                extractWindow_layers(ind);
            }
        }
        void extractWindow_layers(int ind){
            for(int i=0;i<k;i++){
                T*pimage=&image[((mwIndex)p*q)*i];//prevent overflow for 64 bit
                T*pimage2=&image2[((mwIndex)pw*qw)*(i+ind*k)];
                Rhull&rhull=rhulls[ind];
                extractWindow(pimage,pimage2,rhull);
            }
        }
        void  extractWindow(T*pimage,T*pimage2,Rhull&rhull){
            int x1=max(rhull.x1,0);
            int x2=min(rhull.x2,p-1);
            int y1=max(rhull.y1,0);
            int y2=min(rhull.y2,q-1);
            pimage2 += x1-rhull.x1 + (y1-rhull.y1)*pw;
            for(int y=y1;y<=y2;y++){
                T*pimagei=&pimage[x1+y*p];
                T*pimage2i=&pimage2[(y-y1)*pw];
                for(int x=x1;x<=x2;x++){
                    *pimage2i++ = *pimagei++;
                }
            }
        }
            
};

void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
    mxClassID classID=mxGetClassID(in[0]);
    if(classID==mxDOUBLE_CLASS){
        Class1<double> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxSINGLE_CLASS){
        Class1<float> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxINT32_CLASS){
        Class1<int> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxUINT8_CLASS){
        Class1<uint8_T> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else
        assert(0);
}

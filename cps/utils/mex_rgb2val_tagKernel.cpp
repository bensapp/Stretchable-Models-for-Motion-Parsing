/*
// Timothee Cour, 28-Jul-2008 15:19:29 -- DO NOT DISTRIBUTE

function image2=mex_rgb2val_tagKernel(image,tagKernel);
image: pxqx3 RGB image (uint8 or double)
image2: pxqxk (float)
tagKernel: nbColors x k  (ex: 64^3 x 32)
 
 */

#undef NDEBUG
#include <math.h>
#include "mex.h"
#include "mex_util.cpp"
#include "Matrix.cpp"

typedef float T_tag;

template<class T>class Class1{
    public:
        T*image;
        T_tag*tagKernel;
        T_tag*image2;
        bool is_uint8;
        
        void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
            image=Matrix<T>::getData(in[0]);
            is_uint8=mxGetClassID(in[0])==mxUINT8_CLASS;
            int p,q,r;
            getSizes(in[0],p,q,r);
            int num_pixels=p*q;
            
            bool is3d=true;
            if(q==3 && r==1){
                num_pixels=p;
                is3d=false;
            }
            else
                assert(r==3);
            
            
            tagKernel = Matrix<T_tag>::getData(in[1]);
            int nbColors=mxGetM(in[1]);
            int k=mxGetN(in[1]);
            
            if(is3d)
                out[0]=Matrix<T_tag>::createmxArray(p,q,k);
            else{
                out[0]=Matrix<T_tag>::createmxArray(p,k);
            }
            image2=Matrix<T_tag>::getData(out[0]);
            
            if (nbColors==262144)//64^3
                compute_image2_64(num_pixels,k,nbColors);
            else
                assert(0);
            
        }
        
        void compute_image2_64(int num_pixels,int k,int nbColors){
            int r;
            int g;
            int b;
            int inr;
            int ing;
            int inb;
            long int i;
            T*image_g=image+num_pixels;
            T*image_b=image+2*num_pixels;
            
            T temp;            
            T_tag*pimage2;
            T_tag*ptag;
            for(i=0; i<num_pixels; ++i){
                if(is_uint8){
                    r = *image++;
                    g = *image_g++;
                    b = *image_b++;
                }
                else{
                    assert((temp=*image++) <=1);
                    r = (uint8_T)(temp*255.0);
                    
                    assert((temp=*image_g++) <=1);
                    g = (uint8_T)(temp*255.0);
                    
                    assert((temp=*image_b++) <=1);
                    b = (uint8_T)(temp*255.0);
                    
//                     r = (uint8_T)temp;
//                     g = (uint8_T)(*image_g++ /255.0);
//                     b = (uint8_T)(*image_b++ /255.0);
                }                
                inr=(r>>2);
                ing=(g>>2);
                inb=(b>>2);
                pimage2=&image2[i];
                ptag=&tagKernel[inr + (ing<<6) + (inb<<12) ];
                //         for(int j=0;j<k;j++,pimage2+=num_pixels)
                //             *pimage2 = *ptag++;
                for(int j=0;j<k;j++,pimage2+=num_pixels,ptag+=nbColors)
                    *pimage2 = *ptag;
            }
        }
        
};


void mexFunction(int nargout, mxArray *out[], int nargin, const mxArray *in[]){
    mxClassID classID=mxGetClassID(in[0]);
    if(classID==mxDOUBLE_CLASS){
        Class1<double> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else if(classID==mxUINT8_CLASS){
        Class1<uint8_T> class1; class1.mexGate(nargout,out,nargin,in);
    }
    else
        assert(0);
}








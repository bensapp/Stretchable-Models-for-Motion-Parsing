#pragma once
#include "mex.h"


#include "cxcore.h"

#include <vector>
using namespace std;

IplImage* mxArrayToIplImage(const mxArray* m){
    unsigned char* mxImg = (unsigned char*)mxGetPr(m);
    const int ndims = mxGetNumberOfDimensions(m);
    const int* dims = mxGetDimensions(m);
    IplImage* img = NULL;
    
    //     mexPrintf("dims = %d x %d x %d(ndims == %d)\n",dims[0],dims[1],dims[2],ndims);
    img = cvCreateImage(cvSize(dims[1],dims[0]),IPL_DEPTH_8U,ndims==3?dims[2] : 1);
    
    for (int k = 0; k < (ndims==3 ? dims[2] : 1); k++) {
        for (int i = 0; i < dims[0]; i++) {
            for (int j = 0; j < dims[1]; j++) {
                int val = CV_IMAGE_ELEM( img, unsigned char, i, j*(ndims==3?3:1)+k) = (unsigned char)mxImg[k*dims[0]*dims[1]+j*dims[0]+i];
                //                 mexPrintf("%d ",val);
            }
            //             mexPrintf("\n");
        }
        //         mexPrintf("\n");
    }
    
    return img;
}

IplImage* mxArrayToIplImage32F(const mxArray* m, IplImage* img = NULL, bool display = false){
    double* mxImg = (double*)mxGetPr(m);
    const int ndims = mxGetNumberOfDimensions(m);
    const int* dims = mxGetDimensions(m);
    
    if(!img){
        img = cvCreateImage(cvSize(dims[1],dims[0]),IPL_DEPTH_32F,1);
    }
    
    if(display) mexPrintf("m is %dx%d, img is %dx%d\n",dims[0],dims[1],img->height,img->width);
    
    if(display) mexPrintf("\n----dump----\n");
    for (int i = 0; i < dims[0]; i++) {
        for (int j = 0; j < dims[1]; j++) {
            float val = CV_IMAGE_ELEM( img, float, i, j) = (float)mxImg[j*dims[0]+i];
                             if(display && j < 2000) { mexPrintf("%05f ",val);}
                                     
        }
                     if(display) mexPrintf("\n");
    }
    if(display) mexPrintf("\n----end dump----\n");
    
     
    return img;
}


mxArray* IplImage8U2mxArray(const IplImage* img){
    int dims[] = {img->width, img->height};
    mxArray* mxm = mxCreateDoubleMatrix(dims[1],dims[0], mxREAL);
    double* m = mxGetPr(mxm);
    for (int y = 0; y < dims[1]; y++) {
        for (int x = 0; x < dims[0]; x++) {
            m[x*dims[1]+y] = CV_IMAGE_ELEM( img, unsigned char, y, x);
        }
    }
    return mxm;
}


mxArray* IplImage32F2mxArray(const IplImage* img){
    int dims[] = {img->width, img->height};
    mxArray* mxm = mxCreateDoubleMatrix(dims[1],dims[0], mxREAL);
    double* m = mxGetPr(mxm);
    for (int y = 0; y < dims[1]; y++) {
        for (int x = 0; x < dims[0]; x++) {
            m[x*dims[1]+y] = CV_IMAGE_ELEM( img, float, y, x);
        }
    }
    return mxm;
}

CvMat* mxArrayToCvMat(const mxArray* m){
    int* mxMat = (int*)mxGetPr(m);
    const int ndims = mxGetNumberOfDimensions(m);
    const int* dims = mxGetDimensions(m);
    CvMat* mat = NULL;
    
//     mexPrintf("dims = %d x %d x %d(ndims == %d)\n",dims[0],dims[1],dims[2],ndims);
    mat = cvCreateMat( dims[0], dims[1], CV_32SC1);
    
    for (int i = 0; i < dims[0]; i++) {
        for (int j = 0; j < dims[1]; j++) {
            double val = CV_MAT_ELEM( *mat, int, i, j) = (int)mxMat[j*dims[0]+i];
            //             mexPrintf("%.0f ",val);
        }
        //         mexPrintf("\n");
    }
    //     mexPrintf("\n");
    return mat;
}

CvMat* mxArrayToCvMat32F(const mxArray* m){
    double* mxMat = (double*)mxGetPr(m);
    const int ndims = mxGetNumberOfDimensions(m);
    const int* dims = mxGetDimensions(m);
    CvMat* mat = NULL;
    
//     mexPrintf("dims = %d x %d x %d(ndims == %d)\n",dims[0],dims[1],dims[2],ndims);
    mat = cvCreateMat( dims[0], dims[1], CV_32F);
    
    for (int i = 0; i < dims[0]; i++) {
        for (int j = 0; j < dims[1]; j++) {
            double val = CV_MAT_ELEM( *mat, float, i, j) = (float)mxMat[j*dims[0]+i];
            //             mexPrintf("%.0f ",val);
        }
        //         mexPrintf("\n");
    }
    //     mexPrintf("\n");
    return mat;
}


void dump_IplImage32F(const IplImage* img){
    int dims[] = {img->width, img->height};
    for (int y = 0; y < dims[1]; y++) {
            for (int x = 0; x < dims[0]; x++) {
            mexPrintf("%.03f ",CV_IMAGE_ELEM( img, float, y, x));
        }
        mexPrintf("\n");
    }
}













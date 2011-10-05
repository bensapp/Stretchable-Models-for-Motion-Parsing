#pragma once
#include "mex.h"
#include <vector>
using namespace std;

// Converts a Matlab matrix to an stl vector
mxArray* vectorToMxArray(vector<vector<double> > &x) {
    int nRows = x.size();  // i.e., number of rows
    
    if(nRows == 0) {
        mxArray* m = mxCreateDoubleMatrix(0, 0, mxREAL);
        return m;
    }
    
    int nCols = x[0].size();
    
    mxArray* m = mxCreateDoubleMatrix(nRows, nCols, mxREAL);
    for (int i=0; i < nRows; i++) {
        for (int j=0; j < nCols; j++) {
            mxGetPr(m)[j*nRows + i] = x[i][j];
        }
    }
    
    return m;
}

template <class myType>
        mxArray* vectorToMxArray(vector<myType> &x) {
    int nRows = x.size();  // i.e., number of rows
    
    if(nRows == 0) {
        mxArray* m = mxCreateDoubleMatrix(0, 0, mxREAL);
        return m;
    }
    mxArray* m = mxCreateDoubleMatrix(nRows, 1, mxREAL);
    for (int i=0; i < nRows; i++) {
        mxGetPr(m)[i] = (double)x[i];
    }
    return m;
}
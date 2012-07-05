//QuicksortFirstK.cpp
//# include "a_times_b_cmplx.cpp"
//# include "mex_math.cpp"
//# include "mex_util.cpp"
//# include "Matrix.cpp"
// Timothee Cour, 20-Feb-2009 16:37:41 -- DO NOT DISTRIBUTE


/*
int partition2(double *x, int left, int right, int pivotIndex) {
    double pivotValue = x[pivotIndex];
    double temp=0;
 
    int i=left;
    int j=right;
    do
    {
        while (x[i]<pivotValue) i++;
        while (x[j]>pivotValue) j--;
        if (i<=j)
        {
            temp=x[i]; x[i]=x[j]; x[j]=temp;
            i++; j--;
        }
    } while (i<=j);
    return j+1;
}
 */

template<class T>class QuicksortFirstK{
    public:
        void mexGate(int nargout, mxArray *out[], int nargin, const mxArray *in[]) {
            int p=mxGetM(in[0]);
            int q=mxGetN(in[0]);
            int k = (int)mxGetScalar(in[1]);
            bool isAscend = true;
            if(nargin>=3) {
                isAscend = (bool)mxGetScalar(in[2]);
            }
            
            T*X=Matrix<T>::getData(in[0]);
            Matrix<T>val(k,q);
            Matrix<int>ind(k,q);
            
            assert(k<=p);
            sort_columns(X,val,ind,isAscend,p,q);
            
            ind.add(1);
            out[0]=val.tomxArray();
            out[1]=ind.tomxArray(mxDOUBLE_CLASS);
            
        }
        
        int partition(T*x, int *ind, int left, int right, int pivotIndex) {
            T pivotValue = x[pivotIndex];
            T temp=0;
            int tempI=0;
            
            //swap(&x[pivotIndex], &x[right]); // Move pivot to end
            temp=x[pivotIndex];
            x[pivotIndex]=x[right];
            x[right]=temp;
            
            tempI=ind[pivotIndex];
            ind[pivotIndex]=ind[right];
            ind[right]=tempI;
            
            int storeIndex = left;
            for (int i=left;i<=right-1;i++)//right-1??
                if (x[i] <= pivotValue) {
                    //swap(&x[storeIndex], &x[i]);
                    temp=x[storeIndex];
                    x[storeIndex]=x[i];
                    x[i]=temp;
                    
                    tempI=ind[storeIndex];
                    ind[storeIndex]=ind[i];
                    ind[i]=tempI;
                    
                    storeIndex++;
                }
            //swap(&x[right], &x[storeIndex]); // Move pivot to its final place
            temp=x[right];
            x[right]=x[storeIndex];
            x[storeIndex]=temp;
            
            tempI=ind[right];
            ind[right]=ind[storeIndex];
            ind[storeIndex]=tempI;
            
            return storeIndex;
        }
        
        void quicksortFirstK(T *x, int *ind, int left, int right, int n, int k, bool isAscend) {
            if (right > left) {
                //select a pivot value x[pivotIndex]
                int pivotIndex = (left+right)/2;//TODO:randomize
                T temp=x[pivotIndex];
                int pivotNewIndex = partition(x, ind, left, right, pivotIndex);
                if(isAscend) {
                    quicksortFirstK(x, ind, left, pivotNewIndex-1, n,k,isAscend);
                    if (pivotNewIndex+1 < k)
                        quicksortFirstK(x, ind, pivotNewIndex+1, right, n,k,isAscend);
                }else{
                    if (pivotNewIndex > n-k)
                        quicksortFirstK(x, ind, left, pivotNewIndex-1, n,k,isAscend);
                    quicksortFirstK(x, ind, pivotNewIndex+1, right, n,k,isAscend);
                }
            }
        }
        
        void sort_k(T *x,T *val,int *ind,int *ind2,int n,int k, bool isAscend) {
            int i;
            for(i=0;i<n;i++)
                ind[i]=i;
            quicksortFirstK(x, ind, 0, n-1, n,k,isAscend);
            if(isAscend)
                for(i=0;i<k;i++){
                    val[i]=x[i];
                    //ind2[i]=(double)(ind[i]+1);//matlab indexes => +1
                    ind2[i]=ind[i];
                }
            else
                for(i=0;i<k;i++) {
                    val[i]=x[n-1-i];
                    //ind2[i]=(double)(ind[n-1-i]+1);
                    ind2[i]=ind[n-1-i];
                }
        }
        
        void sort_columns(T*X,Matrix<T>&val,Matrix<int>&ind,bool isAscend,int p,int q){
            int k=val.p;
            vector<int>indTemp(p);
            vector<T>x_copy(p);
            for(int j=0;j<q;j++){
                T *Xj = &X[j*p];
                T*valj= &val.data[j*k];
                int*indj= &ind.data[j*k];
                for(int i=0;i<p;i++){
                    x_copy[i]=Xj[i];
                }
                sort_k(&x_copy[0],valj,&indTemp[0],indj,p,k,isAscend);
            }
            
/*
    double *x = copyArray(in[0]);
    //int n = max(mxGetN(in[0]),mxGetM(in[0]));
    out[0] = mxCreateDoubleMatrix(k, q, mxREAL);
    out[1] = mxCreateDoubleMatrix(k, q, mxREAL);
    double *val=mxGetPr(out[0]);
    int *ind = (int*)mxCalloc(n,sizeof(int));
    double *ind2 = mxGetPr(out[1]);
    sort_k(x,val,ind,ind2,n,k,isAscend);
 */
        }
};

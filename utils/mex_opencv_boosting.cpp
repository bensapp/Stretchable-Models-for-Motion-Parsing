#include "mex.h"
#include "mex_opencv_utils.h"
#include "mex_utils.h"
#include <ostream>
#include <cxcore.h>
#include <cv.h>
#include <ml.h>
#include <vector>
#include <numeric>
using namespace std;

// function declarations
pair<vector<double>,vector<double> > run_weak_predictors(CvSeq* weak, CvMat* sample, int weak_count = 0);
void mess_with_predictors(CvSeq* weak, CvMat* sample);
void print_node(const CvDTreeNode* node);
pair<vector<vector<double> >,vector<vector<double> > > features2kernel(const mxArray* _H,const mxArray* _W,const char* model_file, int nweak);
pair<vector<vector<double> >,vector<vector<double> > > features2kernel_deprecated(const mxArray*,const mxArray*,const char* model_file);

inline int mexlength(const mxArray* m){
    return mxGetM(m) > mxGetN(m) ? mxGetM(m) : mxGetN(m);
}


void usage()
{
    mexPrintf("\n");
    mexPrintf("USAGE [1]: mex_opencv_boosting('train',X,int32(y),'model_name.xml',nrounds,maxdepth);\n");
    mexPrintf("USAGE [2]: [scores,leaf_idx] = mex_opencv_boosting('test',X,[],'model_name.xml',nrounds)\n");
    mexPrintf("- scores is the score of each weak classifier as a column, so classification of the ensemble for each examples is sum(scores,2)\n");
    mexPrintf("- leaf_idx is the index of the leaf that each example falls into for each weak tree classifier.  if maxdepth = 3, leaf_idx is in range [0,7]\n");
    mexPrintf("USAGE [3]: [K_w,K_same_diff] = mex_opencv_boosting('features2kernel',H,W,'modelname.mdl',nrounds)\n");
    mexPrintf("- H is m-by-n matrix of n original HOG features for all m examples\n");
    mexPrintf("- W is learned weighting of tree features.  If there are k weak learners, each with maxdepth d, W should be d-by-k\n");
    mexPrintf("- K_w_ij is exp(-tree_leaf_feat(H_ij)*W), and K_same_diff_ij = tree_score(H_ij)\n");
    mexPrintf("\n\n");
}

/*
 *
 
 mex_opencv('mex_opencv_boosting.cpp')
 
 *
 */

void train(const mxArray* _X, const mxArray* _y, const char* model_file,int nrounds, int maxdepth){
    
    CvMat* X = mxArrayToCvMat32F(_X);
    CvMat* y = mxArrayToCvMat(_y);
    
    // boosting
    int boost_type = CvBoost::GENTLE;
    int weak_count = nrounds;
    double weight_trim_rate = 0.95;
    int max_depth = maxdepth;
    bool use_surrogates = 0;
    const float* priors  = NULL;
    CvMat* var_type = cvCreateMat(1, X->cols+1, CV_8UC1);
    cvSet(var_type, cvScalar(CV_VAR_NUMERICAL));
    cvSet1D(var_type, X->cols, cvScalar(CV_VAR_CATEGORICAL));
    CvMat* missing_mask = cvCreateMat(X->rows, X->cols, CV_8UC1);
    cvZero(missing_mask);
    

    
    CvBoostParams params = CvBoostParams(boost_type, weak_count, weight_trim_rate, max_depth, use_surrogates, priors);
    //train the classifier (by calling the boosted tree classifier create function)
    //I hacked the opencv mlboost.cpp/ml.h to give CvBoost a new constructor which takes a log filename for which it dumps training info
    //as a second hack, i'm just passing in the clasifier savefile as the log file, so the training log will dump to the file, and then 
    //when we save the model 4 lines down, the log gets deleted.
    CvBoost booster = CvBoost(model_file);
    booster.train(X, CV_ROW_SAMPLE, y, NULL, NULL, var_type, missing_mask, params, false);

    mexPrintf("training done! saving to %s\n",model_file);
    booster.save(model_file);
    
    cvReleaseMat(&var_type);
    cvReleaseMat(&missing_mask);
    cvReleaseMat(&X);
    cvReleaseMat(&y);
    
}

pair<vector<vector<double> >, vector<vector<double> > >
test(const mxArray* _X, const char* model_file, int num_weak=0){
    CvMat* X = mxArrayToCvMat32F(_X);
    CvBoost booster = CvBoost();
    booster.load(model_file);
    CvSeq* weak = booster.get_weak_predictors();
    if(num_weak==0){
        num_weak = cvSliceLength( CV_WHOLE_SEQ, weak );
    }
            
    CvMat* sample = cvCreateMat(1, X->cols, CV_32F);
    //evaluate weak learners myself
    vector<vector<double> > scores;
    vector<vector<double> > leaf_idx;
    scores.reserve(X->rows);
    //turn off leaf_idx output to save memory for eccv2010
//    leaf_idx.reserve(X->rows);
    for(int i=0; i< X->rows; i++){
        cvGetRow(X, sample, i);
        pair<vector<double>, vector<double> > p_and_idx= run_weak_predictors(weak, sample,num_weak);
        scores.push_back(p_and_idx.first);
//        leaf_idx.push_back(p_and_idx.second);
    }
    
    cvReleaseMat(&X);
    cvReleaseMat(&sample);
    return pair<vector<vector<double> >, vector<vector<double> > >(scores,leaf_idx);
}

void mexFunction(int nlhs, mxArray *out[], int nrhs, const mxArray *in[]) {
    
    if (nrhs < 4) {
        usage();
        return;
    }
    
    char optstr[16];
    char model_file[256];
    
    mxGetString(in[0], optstr, mxGetN(in[0])+1);
    mxGetString(in[3], model_file, mxGetN(in[3])+1);
    
    const mxArray* X = in[1];
    const mxArray* y = in[2];
    
    if(strcmp(optstr,"train") == 0){
        if (nrhs != 6) {
            usage();
            return;
        }
        int nrounds =  (int)mxGetScalar(in[4]);
        int maxdepth = (int)mxGetScalar(in[5]);
        train(X,y,model_file,nrounds,maxdepth);
        return;
    }
        
    if(strcmp(optstr,"test") == 0){
        int nrounds =  (int)mxGetScalar(in[4]);
        pair<vector<vector<double> >, vector<vector<double> > > scores_and_idx = test(X,model_file,nrounds);
        out[0] = vectorToMxArray(scores_and_idx.first);   
        //turn off leaf idx to save memory for eccv2010
//        out[1] = vectorToMxArray(scores_and_idx.second);        
        return;
    }
    
    if(strcmp(optstr,"features2kernel") == 0){
        
        const mxArray* H = X;
        const mxArray* W = y;
        int nrounds =  (int)mxGetScalar(in[4]);
        pair<vector<vector<double> >, vector<vector<double> > > Ks 
                = features2kernel(H,W,model_file,nrounds);
        
        out[0] = vectorToMxArray(Ks.first);  //K_w
        out[1] = vectorToMxArray(Ks.second); //K_same_diff
        return;
    }
    
    if(strcmp(optstr, "features2kernel_deprecated") == 0){
        
        const mxArray* H = X;
        const mxArray* W = y;
        pair<vector<vector<double> >, vector<vector<double> > > Ks 
                = features2kernel_deprecated(H,W,model_file);
        
        out[0] = vectorToMxArray(Ks.first);  //K_w
        out[1] = vectorToMxArray(Ks.second); //K_same_diff
        return;
    }
    
    
    mexPrintf("invalid option: %s\n",optstr);
    return;
}

pair<vector<vector<double> >,vector<vector<double> > >
features2kernel_deprecated(const mxArray* _H,const mxArray* _W,const char* model_file){
    IplImage* H = mxArrayToIplImage32F(_H);
    IplImage* W = mxArrayToIplImage32F(_W);
    int num_ex = H->height;
    int num_hog_feat = H->width;
    int num_leaves = W->height;
    //note that num_weak might be less than the number of weak learners in the ensemble, because we fewer were chosen due to over fitting...
    int num_weak = W->width;
    CvBoost booster = CvBoost();
    booster.load(model_file);
    /*
     * For each pair i,j:
     * (1) compute hog feature vector f_ij = H(:,i).*H(:,j)
     * (2) pass f_ij through boosting trees, getting leaf_idx
     * (3) weight leaf_idx's by corresponding W to get dis(i,j)
     *
     */

    vector<vector<double> > K_w,K_same_diff;
    IplImage* Hi = cvCreateImage(cvGetSize(H),IPL_DEPTH_32F,1);
    IplImage* X = cvCreateImage(cvGetSize(H),IPL_DEPTH_32F,1);
    CvMat* boost_sample = cvCreateMat(1, num_hog_feat, CV_32F);
    for(int i = 0; i < num_ex; i++){
        if(!(i%100)) {mexPrintf("%03d/%03d\n",i,num_ex); mexEvalString("drawnow;"); }
        
        K_w.push_back(vector<double>(num_ex,0));
        K_same_diff.push_back(vector<double>(num_ex,0));
        
        //same as Hi = repmat(H(i,:),size(H,2),1)
        CvRect ith_row = cvRect(0,i,H->width,1);
        cvSetImageROI(H, ith_row);
        cvRepeat(H,Hi);
        cvResetImageROI(H);
        
        //same as X = Hi(1:i,:).*H(1:i,:)
        CvRect first_to_ith_row = cvRect(0,0,H->width,i+1);
        cvSetImageROI(H, first_to_ith_row);
        cvSetImageROI(Hi, first_to_ith_row);
        cvSetImageROI(X, first_to_ith_row);
        cvMul(Hi,H,X);
        cvResetImageROI(Hi);
        cvResetImageROI(H);
        cvResetImageROI(X);        
        
        //get leaf idx and score
        for(int j=0; j<i;j++){
            cvGetRow(X, boost_sample, j);
            
//            int t1 = 3000; int t2 = num_hog_feat;
//            for(int ii=t1; ii<t2; ii++) mexPrintf("%.05f ", CV_MAT_ELEM(*boost_sample, float, 0, ii)); mexPrintf("\n");

            
            float sum = 0;
            pair<vector<double>,vector<double> > scores_and_leaf_idx = run_weak_predictors(booster.get_weak_predictors(), boost_sample, num_weak);
            vector<double> leaf_idx = scores_and_leaf_idx.second;
            vector<double> scores = scores_and_leaf_idx.first;
            for(int k = 0; k < num_weak; k++){
                for(int leaf = 0; leaf < num_leaves; leaf++){
                   sum += (leaf_idx[k]==leaf)*CV_IMAGE_ELEM(W,float,leaf,k);
                }
            }

            K_w[i][j] = exp(-sum);
            K_same_diff[i][j] = std::accumulate(scores.begin(),scores.end(),0.0);
//              mexPrintf("K[%d][%d] = (%f / %f)\n",i,j,K_w[i][j],K_same_diff[i][j]);
//            return pair<vector<vector<double> >, vector<vector<double> > >(K_w, K_same_diff);

        }
    }
    
    cvReleaseImage(&H);
    cvReleaseImage(&W);
    cvReleaseImage(&Hi);
    cvReleaseImage(&X);
    cvReleaseMat(&boost_sample);
    
    return pair<vector<vector<double> >,vector<vector<double> > >(K_w,K_same_diff);
    
}

pair<vector<vector<double> >,vector<vector<double> > >
features2kernel(const mxArray* desc,const mxArray* _W,const char* model_file, int num_weak){
    IplImage* W = mxArrayToIplImage32F(_W);
    int num_ex;
    if(mxGetField(desc,0,"n")==NULL){
        mexPrintf("ERROR: desc must have a field 'n' for number of examples\n");
        return pair<vector<vector<double> >,vector<vector<double> > >();
    } 
    else {    
        num_ex = (int)(*mxGetPr(mxGetField (desc,0,"n")));
    }

    mxArray* inds1 = mxCreateDoubleMatrix(1, 1, mxREAL); *mxGetPr(inds1) = 1;
    mxArray* inds2 = mxCreateDoubleMatrix(1, 1, mxREAL); *mxGetPr(inds2) = 1;
    mxArray* args[] = {(mxArray*)desc,inds1,inds2};
    mxArray* X = NULL;
    mexCallMATLAB(1, &X, 3, args, "ps_kernel_raw_features2pair_features");
    
    
    
    int num_feats = mexlength(X);
    int num_leaves = W->height;

    CvBoost booster = CvBoost();
    booster.load(model_file);
    /*
     * For each pair i,j:
     * (1) compute hog feature vector f_ij = H(:,i).*H(:,j)
     * (2) pass f_ij through boosting trees, getting leaf_idx
     * (3) weight leaf_idx's by corresponding W to get dis(i,j)
     *
     */
    
    inds2 = mxCreateDoubleMatrix(num_ex, 1, mxREAL); *mxGetPr(inds2) = 1;
    double* ptr = mxGetPr(inds2);
    for(int i=1 ; i<=num_ex; i++){
        *ptr++ = i;
    }

    vector<vector<double> > K_w,K_same_diff;
    IplImage* Xipl = cvCreateImage(cvSize(num_feats,num_ex),IPL_DEPTH_32F,1);
    CvMat* boost_sample = cvCreateMat(1, num_feats, CV_32F);
    for(int i = 0; i < num_ex; i++){
        if(!(i%100)) {mexPrintf("%03d/%03d\n",i,num_ex); mexEvalString("drawnow;"); }
        
        K_w.push_back(vector<double>(num_ex,0));
        K_same_diff.push_back(vector<double>(num_ex,0));
        
        
        // get all pairwise features from i to j=1:i-1
        *mxGetPr(inds1) = i+1;
        mxArray* args[] = {(mxArray*)desc, inds1, inds2, inds1};
        mexCallMATLAB(1, &X, 4, args, "ps_kernel_raw_features2pair_features");
        mxArrayToIplImage32F(X,Xipl);

        
        //get leaf idx and score
        for(int j=0; j<i;j++){
            cvGetRow(Xipl, boost_sample, j);
            float sum = 0;
            pair<vector<double>, vector<double> > scores_and_leaf_idx = run_weak_predictors(booster.get_weak_predictors(), boost_sample, num_weak);
            vector<double> leaf_idx = scores_and_leaf_idx.second;
            vector<double> scores = scores_and_leaf_idx.first;
            for(int k = 0; k < num_weak; k++){
                for(int leaf = 0; leaf < num_leaves; leaf++){
                   sum += (leaf_idx[k]==leaf)*CV_IMAGE_ELEM(W,float,leaf,k);
                }
            }
            K_w[i][j] = exp(-sum);
            K_same_diff[i][j] = std::accumulate(scores.begin(),scores.end(),0.0);
        }
        
        mxDestroyArray(X);
    }
    
    cvReleaseImage(&W);
    cvReleaseImage(&Xipl);
    cvReleaseMat(&boost_sample);
    
    return pair<vector<vector<double> >,vector<vector<double> > >(K_w,K_same_diff);
    
}

pair<vector<double>,vector<double> > run_weak_predictors(CvSeq* weak, CvMat* sample, int weak_count) {
    
    CvSeqReader reader;
    if(!weak_count){
        weak_count = cvSliceLength( CV_WHOLE_SEQ, weak );
    }
    cvStartReadSeq( weak, &reader );
    cvSetSeqReaderPos( &reader, 0 );
    vector<double> p(weak_count,0);    
    vector<double> leaf_idx(weak_count, 0);
    for(int i = 0; i < weak_count; i++ ) {
        CvBoostTree* wtree;
        const CvDTreeNode* node;
        CV_READ_SEQ_ELEM( wtree, reader );
        
        unsigned int binary_idx = 0;
        // tree traversal
        node = wtree->get_root();
        while( node->left ) {
            CvDTreeSplit* split = node->split;
            int vi = split->var_idx;
            float val = sample->data.fl[vi];
            int dir = val <= split->ord.c ? -1 : 1;
            if( split->inversed )
                dir = -dir;
            node = dir < 0 ? node->left : node->right;
            
            //if we go left, put a 1 in the k'th bit, otherwise put a zero
            binary_idx = binary_idx<<1;
            binary_idx |= (dir<0);
            
//            mexPrintf("data[%d] = (%f) <= split->ord.c (%f) ? %d", vi, val, split->ord.c, dir);
        }
//        mexPrintf(" --> value = %f\n",node->value);
        p[i] = node->value;
        leaf_idx[i] = binary_idx;
        
    }
    
    
    return pair<vector<double>,vector<double> >(p,leaf_idx);
}

void mess_with_predictors(CvSeq* weak, CvMat* sample) {
    
    CvSeqReader reader;
    int weak_count = cvSliceLength( CV_WHOLE_SEQ, weak );
    cvStartReadSeq( weak, &reader );
    cvSetSeqReaderPos( &reader, 0 );
    double sum = 0;
    for(int i = 0; i < weak_count; i++ ) {
        mexPrintf("wtree %d:\n", i);
        CvBoostTree* wtree;
        const CvDTreeNode* node;
        CV_READ_SEQ_ELEM( wtree, reader );
        
        // tree traversal
        node = wtree->get_root();
        print_node(node);
        print_node(node->left);
        print_node(node->left->left);
        print_node(node->left->right);
        print_node(node->right);
        print_node(node->right->left);
        print_node(node->right->right);

//        while( node->left ) {
//            CvDTreeSplit* split = node->split;
//            int vi = split->condensed_idx;
//            float val = sample->data.fl[vi];
//            int dir = val <= split->ord.c ? -1 : 1;
//            if( split->inversed )
//                dir = -dir;
//            node = dir < 0 ? node->left : node->right;
//            
//            mexPrintf("split feature %d, split thresh %f, inversed = %d\n", vi, split->ord.c, split->inversed);
//        }
//        mexPrintf("node->value = %f\n", node->value);
//        sum += node->value;
    }
    
    
    return;
}

void print_node(const CvDTreeNode* node) {
    if(!node){ 
        mexPrintf("NULL NODE!\n"); 
        return; 
    }
    if(node->split)
    {
        int vi = node->split->condensed_idx;
        mexPrintf("SPLIT NODE: feature %d, split thresh %f, inversed = %d, value = %f\n", vi, node->split->ord.c, node->split->inversed, node->value);
    } else {
        mexPrintf("LEAF NODE: value = %f\n",node->value);
    }
 
}

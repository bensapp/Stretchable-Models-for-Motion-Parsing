//class Rhull
// Timothee Cour, 04-Mar-2009 05:49:24 -- DO NOT DISTRIBUTE

#pragma once
#include <math.h>
#include <mex.h>
#include "mex_math.cpp"

#include "Matrix.cpp"

class Rhull {
public:
	int x1,x2,y1,y2;
	//x1<=x<=x2,y1<=y<=y2 //new convention....
	Rhull(){
		x1=0;
		x2=0;
		y1=0;
		y2=0;
	}
	Rhull(const Rhull&rhull){
		x1=rhull.x1;
		x2=rhull.x2;
		y1=rhull.y1;
		y2=rhull.y2;
	}
	Rhull(vector<int>&v){
		x1=v[0];
		x2=v[1];
		y1=v[2];
		y2=v[3];
	}
	Rhull(int x1,int x2,int y1,int y2){
		this->x1=x1;
		this->x2=x2;
		this->y1=y1;
		this->y2=y2;
	}
	bool isEmpty(){
		return (x1>x2 || y1>y2);
	}
	void intersect(Rhull*rhull1,Rhull*rhull2){//TODO:use &
		x1=max(rhull1->x1,rhull2->x1);
		x2=min(rhull1->x2,rhull2->x2);
		y1=max(rhull1->y1,rhull2->y1);
		y2=min(rhull1->y2,rhull2->y2);
	}
	void union2(Rhull&rhull){
		x1=min(x1,rhull.x1);
		x2=max(x2,rhull.x2);
		y1=min(y1,rhull.y1);
		y2=max(y2,rhull.y2);
	}
	void translate(int x,int y){
		x1+=x;
		x2+=x;
		y1+=y;
		y2+=y;
	}
	void set(int x1,int x2,int y1,int y2){
		this->x1=x1;
		this->x2=x2;
		this->y1=y1;
		this->y2=y2;
	}
    void getSize(int &p,int &q){
        p=max(0,x2-x1+1);
        q=max(0,y2-y1+1);
    }
    int area(){
        int p=max(0,x2-x1+1);
        int q=max(0,y2-y1+1);
        return p*q;
    }
    void readmxArray(const mxArray *A,bool is_offset){
        Matrix<int>rhull(A);
        assert(rhull.n==4);
        if(is_offset)
            rhull.add(-1);
        set(rhull[0],rhull[1],rhull[2],rhull[3]);     
    }
    static void readmxArray(const mxArray *A, bool is_offset, vector<Rhull>&rhulls){
        if(mxIsCell(A)){
            int nb=mxGetNumberOfElements(A);
            rhulls.resize(nb);
            for(int i=0;i<nb;i++){
                rhulls[i].readmxArray(mxGetCell(A, i), is_offset);
            }
        }
        else{
            assert(mxIsNumeric(A));
            rhulls.resize(1);
            rhulls[0].readmxArray(A, is_offset);
        }
    }
    mxArray* tomxArray(bool is_offset) const{
        vector<double>rhull(4);
        if(is_offset){
            rhull[0]=x1+1;
            rhull[1]=x2+1;
            rhull[2]=y1+1;
            rhull[3]=y2+1;
        }
        else{
            rhull[0]=x1;
            rhull[1]=x2;
            rhull[2]=y1;
            rhull[3]=y2;
        }
        return Matrix<double>::tomxArray(rhull);
    }
    void disp(){
        Matrix<double>rhull(1,4);
        rhull[0]=x1;
        rhull[1]=x2;
        rhull[2]=y1;
        rhull[3]=y2;
        rhull.disp();
    }
};

function [C,C12]=computeMultiscaleConstraint_1scale(p1,q1,p2,q2,indexes1,indexes2,nTot);
% input: parameters for 2 consecutive layers
% output:
% C: rows of the global multiscale constraint matrix corresponding to those 2 layers; 
% indexes1 and indexes2 are used for indexing into the global multiscale
% constraint matrix
% C12: interpolation matrix between the 2 layers
% Timothee Cour, 04-Aug-2008 20:46:38 -- DO NOT DISTRIBUTE


classes=mex_constraint_classes(p1,q1,p2,q2);
[C,C12]=computeConstraintFromClasses(classes,indexes1,indexes2,nTot);

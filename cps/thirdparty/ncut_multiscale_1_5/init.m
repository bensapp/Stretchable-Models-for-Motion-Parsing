function init;
% adds paths to subdirectories
addpath(genpath(pwd));

if verLessThan2('7.1')
    addpath(genpath('compatibility/private/7.1'));
end
if verLessThan2('7.4')
    addpath(genpath('compatibility/private/7.4'));
end

addpath_SuiteSparse();
addpath_libraries();

function addpath_SuiteSparse();
dir_input='/Users/timothee/research/programs/autre_code/SuiteSparse';
if ~isdir(dir_input)
    return;
end
addpath(dir_input);
addpath(fullfile(dir_input,'UMFPACK/MATLAB'));
addpath(fullfile(dir_input,'CHOLMOD/MATLAB'));
addpath(fullfile(dir_input,'AMD/MATLAB'));
addpath(fullfile(dir_input,'COLAMD/MATLAB'));
addpath(fullfile(dir_input,'CCOLAMD/MATLAB'));
addpath(fullfile(dir_input,'CAMD/MATLAB'));
addpath(fullfile(dir_input,'CXSparse/MATLAB/CSparse'));
addpath(fullfile(dir_input,'CXSparse/MATLAB/Demo'));
addpath(fullfile(dir_input,'CXSparse/MATLAB/UFget'));
addpath(fullfile(dir_input,'LDL/MATLAB'));
addpath(fullfile(dir_input,'BTF/MATLAB'));
addpath(fullfile(dir_input,'KLU/MATLAB'));
addpath(fullfile(dir_input,'UFcollection'));

function addpath_libraries();
%{
% addpath(genpath('/Users/timothee/research/programs/autre_code/temp'));       %sparse cell:
addpath(genpath('/Users/timothee/research/programs/autre_code/cvx'));
addpath(genpath('/Users/timothee/research/programs/autre_code/c_inference_ver2.2'));
addpath('/Applications/mosek/5/toolbox/r2007a');
%}


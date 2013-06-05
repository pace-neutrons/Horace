function test_multifit2(varargin)
% Performs a number of tests of syntax.
% Optionally writes results to output file or tests output against stored output
%
%   >> test_multifit_2           % Compares with previously saved results in test_multifit_2_output.mat
%                                % in the same folder as this function
%   >> test_multifit_2 ('save')  % Save to  c:\temp\test_multifit_2_output.mat
%
% Reads previously created test data in .\make_data\test_multifit_datasets_1.mat

if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

%% =====================================================================================================================
%  Setup location of reference functions (fortran or matlab)
% ======================================================================================================================
rootpath=fileparts(mfilename('fullpath'));
load(fullfile(rootpath,'make_data','test_multifit_datasets_1.mat'));

%% =====================================================================================================================
%  Perform tests
% ======================================================================================================================
pin=[100,50,7,0,0];

% Single dataset
% ----------------
set_multifit_version(1)
[wref,fref]=multifit(w1,@mftest_gauss_bkgd,pin);
set_multifit_version(2)
[ww,ff]=multifit2(w1,@mftest_gauss_bkgd,pin);
[ww,ff]=multifit2(w1,@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
[ww,ff]=multifit2(w1,@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3));


% Two datasets
% ----------------
set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_gauss_bkgd,pin);
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss_bkgd,pin);

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_gauss,pin(1:3),[1 0 1],@mftest_bkgd,pin(4:5));
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),[1 0 1],@mftest_bkgd,pin(4:5));

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin);
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5),'local_fore');

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
    {{{1,3,2},{3,3,2},{2,2,2}},{{1,3}}});
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),[],{1,3},@mftest_bkgd,pin(4:5));

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
    {{{4,4,2,1},{5,5,2,1},{1,3}},{{1,3}}});
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3),[],{{1,3}});

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3}}, {{1,3},{5,5,1,1}}});
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3}},@mftest_bkgd,pin(4:5),[0,1],{{{2,2,2,1}},{}},'local_fore');
[wm,fm]=multifit2([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{{1,3}},'local_fore');

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3}}, {{1,3,1},{3,3,1,1},{2,2,1,1},{5,5,1,1}}});
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{1,3},'local_fore','global_back');

set_multifit_version(1)
[wmref,fmref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3,1,10},{5,3,2,0.01}}, {{1,3,2,10},{5,3,1,0.02}}});
set_multifit_version(2)
[wm,fm]=multifit2([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3,[],10}},@mftest_bkgd,pin(4:5),[0,1],{{{2,3,-2,0.01}},{2,3,-1,0.02}},'local_fore');





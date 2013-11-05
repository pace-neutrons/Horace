function test_multifit_2(varargin)
% Performs a number of tests of syntax.
% Optionally writes results to output file or tests output against stored output
%
%   >> test_multifit_2           % Compares with previously saved results in test_multifit_2_output.mat
%                                % in the same folder as this function
%   >> test_multifit_2 ('save')  % Save to  c:\temp\test_multifit_2_output.mat
%
% Reads previously created test data in .\make_data\test_multifit_datasets_1.mat
%
% Author: T.G.Perring

banner_to_screen(mfilename)

data_filename='testdata_multifit_1.mat';
results_filename='test_multifit_2_output.mat';

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
load(fullfile(rootpath,data_filename));


%% =====================================================================================================================
%  Perform tests
% ======================================================================================================================
pin=[100,50,7,0,0];


% Single dataset
% ----------------
tol=-1e-8;
tol_special=-1e-7;   % some special cases where a fit parameter is very small need coarser tolerance

[ws1_ref,fs1_ref]=multifit(w1,@mftest_gauss_bkgd,pin);

[ws1a,fs1a]=multifit(w1,@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
pars=[fs1a.p,fs1a.bp];
[ok,mess]=equal_to_tol(pars, fs1_ref.p, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end

[ws1b,fs1b]=multifit(w1,@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3));
pars=[fs1b.bp,fs1b.p];
[ok,mess]=equal_to_tol(pars, fs1_ref.p, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


% Two datasets
% ----------------
% Try various combinations of background and foreground functions
[wm1_ref,fm1_ref]=multifit([w1,w3],@mftest_gauss_bkgd,pin);
[wm1,fm1]=multifit([w1,w3],@mftest_gauss_bkgd,pin);
pars_ref=fm1_ref.p;
pars=fm1.p;
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm2_ref,fm2_ref]=multifit([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
[wm2,fm2]=multifit([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
pars_ref=[fm2_ref.p,fm2_ref.bp{1},fm2_ref.bp{2}];
pars=[fm2.p,fm2.bp{1},fm2.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm3_ref,fm3_ref]=multifit([w1,w3],@mftest_gauss,pin(1:3),[1 0 1],@mftest_bkgd,pin(4:5));
[wm3,fm3]=multifit([w1,w3],@mftest_gauss,pin(1:3),[1 0 1],@mftest_bkgd,pin(4:5));
pars_ref=[fm3_ref.p,fm3_ref.bp{1},fm3_ref.bp{2}];
pars=[fm3.p,fm3.bp{1},fm3.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm4_ref,fm4_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin);
[wm4,fm4]=multifit([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5),'local_fore');
pars_ref=[fm4_ref.bp{1},fm4_ref.bp{2}];
pars=[fm4.p{1},fm4.bp{1},fm4.p{2},fm4.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm5_ref,fm5_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
    {{{1,3,2},{3,3,2},{2,2,2}},{{1,3}}});
[wm5,fm5]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{1,3},@mftest_bkgd,pin(4:5));
pars_ref=[fm5_ref.bp{1},fm5_ref.bp{2}];
pars=[fm5.p,fm5.bp{1},fm5.p,fm5.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol_special, 'min_denominator', 1);
if ~ok, assertTrue(false,mess), end


[wm6_ref,fm6_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
    {{{4,4,2,1},{5,5,2,1},{1,3}},{{1,3}}});
[wm6,fm6]=multifit([w1,w3],@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3),[],{{1,3}});
pars_ref=[fm6_ref.bp{1},fm6_ref.bp{2}];
pars=[fm6.bp{1},fm6.p,fm6.bp{2},fm6.p];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm7_ref,fm7_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3}}, {{1,3},{5,5,1,1}}});
[wm7a,fm7a]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3}},@mftest_bkgd,pin(4:5),[0,1],{{{2,2,2,1}},{}},'local_fore');
pars_ref=[fm7_ref.bp{1},fm7_ref.bp{2}];
pars=[fm7a.p{1},fm7a.bp{1},fm7a.p{2},fm7a.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end
[wm7b,fm7b]=multifit([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{{1,3}},'local_fore');
pars=[fm7b.bp{1},fm7b.p{1},fm7b.bp{2},fm7b.p{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm8_ref,fm8_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3}}, {{1,3,1},{3,3,1,1},{2,2,1,1},{5,5,1,1}}});
[wm8,fm8]=multifit([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{1,3},'local_fore','global_back');
pars_ref=[fm8_ref.bp{1},fm8_ref.bp{2}];
pars=[fm8.bp,fm8.p{1},fm8.bp,fm8.p{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


[wm9_ref,fm9_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
    {{{1,3,1,10},{5,3,2,0.01}}, {{1,3,2,10},{5,3,1,0.02}}});
[wm9,fm9]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3,[],10}},@mftest_bkgd,pin(4:5),[0,1],{{{2,3,-2,0.01}},{2,3,-1,0.02}},'local_fore');
pars_ref=[fm9_ref.bp{1},fm9_ref.bp{2}];
pars=[fm9.p{1},fm9.bp{1},fm9.p{2},fm9.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol, 'min_denominator', 0.01);
if ~ok, assertTrue(false,mess), end


%% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    if get(herbert_config,'log_level')>-1
        disp('====================================')
        disp('    Comparing with saved output')
        disp('====================================')
    end    
    output_file=fullfile(rootpath,results_filename);
    old=load(output_file);
    nam=fieldnames(old);
    tol=1.0e-8;
    % The test proper
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}), old.(nam{i}), tol, 'min_denominator', 0.01);
        if ~ok 
            assertTrue(false,['[',nam{i},']',mess])
        else
            if get(herbert_config,'log_level')>-1            
                disp (['[',nam{i},']',': ok'])
            end
        end
    end
    % Success announcement
    if get(herbert_config,'log_level')>-1    
        banner_to_screen([mfilename,': Test(s) passed (matches are within requested tolerances)'],'bot')
    end        
end


%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file=fullfile(tempdir,results_filename);
    save(output_file,...
        'ws1_ref','fs1_ref','ws1a','fs1a','ws1b','fs1b',...
        'wm1_ref','fm1_ref','wm1','fm1',...
        'wm2_ref','fm2_ref','wm2','fm2',...
        'wm3_ref','fm3_ref','wm3','fm3',...
        'wm4_ref','fm4_ref','wm4','fm4',...
        'wm5_ref','fm5_ref','wm5','fm5',...
        'wm6_ref','fm6_ref','wm6','fm6',...
        'wm7_ref','fm7_ref','wm7a','fm7a','wm7b','fm7b',...
        'wm8_ref','fm8_ref','wm8','fm8',...
        'wm9_ref','fm9_ref','wm9','fm9');

    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end


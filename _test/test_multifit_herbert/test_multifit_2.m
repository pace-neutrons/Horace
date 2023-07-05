function test_multifit_2(varargin)
% Performs a number of tests of syntax.
% Optionally writes results to output file or tests output against stored output
%
%   >> test_multifit_2           % Compares with previously saved results in test_multifit_2_output.mat
%                                % in the same folder as this function
%   >> test_multifit_2 ('save')  % Save to test_multifit_2_output.mat int he Matlab temporary directory
%
% Reads previously created test data in testdata_multifit_1.mat
%
% Author: T.G.Perring

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
%  Setup location of reference functions
% ======================================================================================================================
clob = set_temporary_warning('off','MATLAB:unknownObjectNowStruct');

rootpath=fileparts(mfilename('fullpath'));
ld = load(fullfile(rootpath,data_filename));
% old classes conversion
flds =fieldnames(ld);
for i=1:numel(flds)
    fld = flds{i};
    if isstruct(ld.(fld)) && numel(fieldnames(ld.(fld))) == 7
        %assignin('caller', fld,IX_dataset_1d(ld.(fld)))
        eval([fld,' = IX_dataset_1d(ld.(fld));']);
    else
        %assignin('caller', fld,ld.(fld))
        eval([fld,' = ld.(fld);']);
    end
end


%% =====================================================================================================================
%  Perform tests
% ======================================================================================================================
pin=[100,50,7,0,0];

tol = [1e-10,1e-8];

% Single dataset
% ----------------
% Legacy syntax - retain for future use
% [ws1_ref,fs1_ref]=multifit(w1,@mftest_gauss_bkgd,pin);
% [ws1a,fs1a]=multifit(w1,@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5));
% [ws1b,fs1b]=multifit(w1,@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3));

mf1_ref = multifit(w1);
mf1_ref = mf1_ref.set_fun(@mftest_gauss_bkgd, pin);
[ws1_ref,fs1_ref] = mf1_ref.fit();

mf1a = multifit(w1);
mf1a = mf1a.set_fun(@mftest_gauss, pin(1:3));
mf1a = mf1a.set_bfun(@mftest_bkgd, pin(4:5));
[ws1a,fs1a] = mf1a.fit();

pars=[fs1a.p,fs1a.bp];
[ok,mess]=equal_to_tol(pars, fs1_ref.p, tol);
if ~ok, assertTrue(false,mess), end

mf1b = multifit(w1);
mf1b = mf1b.set_fun(@mftest_bkgd, pin(4:5));
mf1b = mf1b.set_bfun(@mftest_gauss, pin(1:3));
[ws1b,fs1b] = mf1b.fit();

pars=[fs1b.bp,fs1b.p];
[ok,mess]=equal_to_tol(pars, fs1_ref.p, tol);
if ~ok, assertTrue(false,mess), end


% Two datasets
% ----------------
% Legacy syntax - retain for future use
% [wm4_ref,fm4_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin);
% [wm4,fm4]        =multifit([w1,w3],@mftest_gauss,pin(1:3),@mftest_bkgd,pin(4:5),'local_fore');

mf4_ref = multifit([w1,w3]);
mf4_ref = mf4_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf4_ref = mf4_ref.set_bfun(@mftest_gauss_bkgd,pin);
[wm4_ref,fm4_ref] = mf4_ref.fit();

mf4 = multifit([w1,w3]);
mf4 = mf4.set_local_foreground();
mf4 = mf4.set_fun(@mftest_gauss,pin(1:3));
mf4 = mf4.set_bfun(@mftest_bkgd, pin(4:5));
[wm4,fm4] = mf4.fit();

pars_ref=[fm4_ref.bp{1},fm4_ref.bp{2}];
pars=[fm4.p{1},fm4.bp{1},fm4.p{2},fm4.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%---------------------------------------------
% Legacy syntax - retain for future use
% [wm5_ref,fm5_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
%     {{{1,3,2},{3,3,2},{2,2,2}},{{1,3}}});
% [wm5,fm5]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{1,3},@mftest_bkgd,pin(4:5));

mf5_ref = multifit([w1,w3]);
mf5_ref = mf5_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf5_ref = mf5_ref.set_bfun(@mftest_gauss_bkgd,pin);
mf5_ref = mf5_ref.set_bbind({[1,1],[3,2]},{[3,1],[3,2]},{2,[2,2]},{[1,2],[3,2]});
[wm5_ref,fm5_ref] = mf5_ref.fit();

mf5 = multifit([w1,w3]);
mf5 = mf5.set_fun(@mftest_gauss,pin(1:3));
mf5 = mf5.set_bind({1,3});
mf5 = mf5.set_bfun(@mftest_bkgd, pin(4:5));
[wm5,fm5] = mf5.fit();

pars_ref=[fm5_ref.bp{1},fm5_ref.bp{2}];
pars=[fm5.p,fm5.bp{1},fm5.p,fm5.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%---------------------------------------------
% Legacy syntax - retain for future use
% [wm6_ref,fm6_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[],...
%     {{{4,4,2,1},{5,5,2,1},{1,3}},{{1,3}}});
% [wm6,fm6]=multifit([w1,w3],@mftest_bkgd,pin(4:5),@mftest_gauss,pin(1:3),[],{{1,3}});

mf6_ref = multifit([w1,w3]);
mf6_ref = mf6_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf6_ref = mf6_ref.set_bfun(@mftest_gauss_bkgd,pin);
mf6_ref = mf6_ref.set_bbind({1,3},{4,[4,2],1},{5,[5,2],1});
[wm6_ref,fm6_ref] = mf6_ref.fit();

mf6 = multifit([w1,w3]);
mf6 = mf6.set_fun(@mftest_bkgd, pin(4:5));
mf6 = mf6.set_bfun(@mftest_gauss,pin(1:3));
mf6 = mf6.set_bbind({1,3});
[wm6,fm6] = mf6.fit();

pars_ref=[fm6_ref.bp{1},fm6_ref.bp{2}];
pars=[fm6.bp{1},fm6.p,fm6.bp{2},fm6.p];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%---------------------------------------------
% Legacy syntax - retain for future use
% [wm7_ref,fm7_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
%     {{{1,3}}, {{1,3},{5,5,1,1}}});
% [wm7a,fm7a]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3}},@mftest_bkgd,pin(4:5),[0,1],{{{2,2,2,1}},{}},'local_fore');
% [wm7b,fm7b]=multifit([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{{1,3}},'local_fore');

mf7_ref = multifit([w1,w3]);
mf7_ref = mf7_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf7_ref = mf7_ref.set_bfun(@mftest_gauss_bkgd,pin);
mf7_ref = mf7_ref.set_bfree([1,1,1,0,1]);
mf7_ref = mf7_ref.set_bbind({[1,1],[3,1]},{[1,2],[3,2]},{5,[5,1],1});
[wm7_ref,fm7_ref] = mf7_ref.fit();

mf7a = multifit([w1,w3]);
mf7a = mf7a.set_local_foreground();
mf7a = mf7a.set_fun(@mftest_gauss,pin(1:3));
mf7a = mf7a.set_bind({1,3});
mf7a = mf7a.set_bfun(@mftest_bkgd, pin(4:5));
mf7a = mf7a.set_bfree([0,1]);
mf7a = mf7a.set_bbind({2,[2,2],1});
[wm7a,fm7a] = mf7a.fit();

mf7b = multifit([w1,w3]);
mf7b = mf7b.set_local_foreground();
mf7b = mf7b.set_fun(@mftest_bkgd, pin(4:5));
mf7b = mf7b.set_free([0,1]);
mf7b = mf7b.set_bind({2,[2,2],1});
mf7b = mf7b.set_bfun(@mftest_gauss,pin(1:3));
mf7b = mf7b.set_bbind({1,3});
[wm7b,fm7b] = mf7b.fit();

pars_ref=[fm7_ref.bp{1},fm7_ref.bp{2}];
pars=[fm7a.p{1},fm7a.bp{1},fm7a.p{2},fm7a.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end

pars=[fm7b.bp{1},fm7b.p{1},fm7b.bp{2},fm7b.p{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%---------------------------------------------
% Legacy syntax - retain for future use
% [wm8_ref,fm8_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
%     {{{1,3}}, {{1,3,1},{3,3,1,1},{2,2,1,1},{5,5,1,1}}});
% [wm8,fm8]=multifit([w1,w3],@mftest_bkgd,pin(4:5),[0,1],{{{2,2,-2,1}},{}},@mftest_gauss,pin(1:3),[],{1,3},'local_fore','global_back');

mf8_ref = multifit([w1,w3]);
mf8_ref = mf8_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf8_ref = mf8_ref.set_bfun(@mftest_gauss_bkgd,pin);
mf8_ref = mf8_ref.set_bfree([1,1,1,0,1]);
mf8_ref = mf8_ref.set_bbind({[1,1],[3,1]});
mf8_ref = mf8_ref.add_bbind({[1,2],[3,1]},{[2,2],[2,1]},{[3,2],[3,1]});
mf8_ref = mf8_ref.add_bbind({5,[5,1],1});
[wm8_ref,fm8_ref] = mf8_ref.fit();

mf8 = multifit([w1,w3]);
mf8 = mf8.set_local_foreground();
mf8 = mf8.set_fun(@mftest_bkgd, pin(4:5));
mf8 = mf8.set_free([0,1]);
mf8 = mf8.set_bind({[2,1],[2,2],1});
mf8 = mf8.set_global_background();
mf8 = mf8.set_bfun(@mftest_gauss,pin(1:3));
mf8 = mf8.set_bbind({1,3});
[wm8,fm8] = mf8.fit();

pars_ref=[fm8_ref.bp{1},fm8_ref.bp{2}];
pars=[fm8.bp,fm8.p{1},fm8.bp,fm8.p{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%---------------------------------------------
% Legacy syntax - retain for future use
% [wm9_ref,fm9_ref]=multifit([w1,w3],@mftest_bkgd,[0,0],[0,0],@mftest_gauss_bkgd,pin,[1,1,1,0,1],...
%     {{{1,3,1,10},{5,3,2,0.01}}, {{1,3,2,10},{5,3,1,0.02}}});
% [wm9,fm9]=multifit([w1,w3],@mftest_gauss,pin(1:3),[],{{1,3,[],10}},...
%     @mftest_bkgd,pin(4:5),[0,1],{{{2,3,-2,0.01}},{2,3,-1,0.02}},'local_fore');

mf9_ref = multifit([w1,w3]);
mf9_ref = mf9_ref.set_fun(@mftest_bkgd,[0,0],[0,0]);
mf9_ref = mf9_ref.set_bfun(@mftest_gauss_bkgd,pin);
mf9_ref = mf9_ref.set_bfree([1,1,1,0,1]);
mf9_ref = mf9_ref.set_bbind({1,3,10},{[5,1],[3,2],0.01});
mf9_ref = mf9_ref.add_bbind({[5,2],[3,1],0.02});
[wm9_ref,fm9_ref] = mf9_ref.fit();

mf9 = multifit([w1,w3]);
mf9 = mf9.set_local_foreground();
mf9 = mf9.set_fun(@mftest_gauss,pin(1:3));
mf9 = mf9.set_bind({1,3,10});
mf9 = mf9.set_bfun(@mftest_bkgd, pin(4:5));
mf9 = mf9.set_bfree([0,1]);
mf9 = mf9.set_bbind({[2,1],[3,-2],0.01});
mf9 = mf9.add_bbind({[2,2],[3,-1],0.02});
[wm9,fm9] = mf9.fit();

pars_ref=[fm9_ref.bp{1},fm9_ref.bp{2}];
pars=[fm9.p{1},fm9.bp{1},fm9.p{2},fm9.bp{2}];
[ok,mess]=equal_to_tol(pars, pars_ref, tol);
if ~ok, assertTrue(false,mess), end


%% =====================================================================================================================
% Compare with saved output
% ======================================================================================================================
if ~save_output
    output_file=fullfile(rootpath,results_filename);

    clob = set_temporary_warning('off','MATLAB:unknownObjectNowStruct');

    old=load(output_file);
    nam=fieldnames(old);
    tol=[1e-10,1e-8];
    % The test proper
    for i=1:numel(nam)
        var = eval(nam{i});
        if isstruct(old.(nam{i})) && numel(fieldnames(old.(nam{i}))) == 7
            old.(nam{i}) = IX_dataset_1d(old.(nam{i}));
        end
        [ok,mess]=equal_to_tol(var, old.(nam{i}), tol);
        if ~ok
            assertTrue(false,['[',nam{i},']',mess])
        end
    end
end


%% =====================================================================================================================
% Save data
% ======================================================================================================================
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')

    output_file=fullfile(tmp_dir,results_filename);
    save(output_file,...
        'ws1_ref','fs1_ref','ws1a','fs1a','ws1b','fs1b',...
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

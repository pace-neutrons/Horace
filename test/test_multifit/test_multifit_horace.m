function test_multifit_horace(varargin)
% Performs some tests of fitting to Horace objects using multifit_sqw and other functions.
% Optionally writes results to output file
%
%   >> test_multifit            % compares with previously saved results in test_multifit_horace.mat in the same folder as this function
%   >> test_multifit ('save')   % save to  c:\temp\test_multifit_horace.mat
%
% Reads previously created test data sets.

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

%% ------------------------------------------------------------------------------------------------
% Example of fitting more than one sqw object
% -------------------------------------------------------------------------------------------------
demo_dir=fileparts(mfilename('fullpath'));

% Read in data
% ------------
w1data=read_sqw(fullfile(demo_dir,'w1data.sqw'));
w2data=read_sqw(fullfile(demo_dir,'w2data.sqw'));


% Combine the two cuts into an array of sqw objects and fit
% ---------------------------------------------------------
% The data were created using the cross-section model that is fitted shortly,
% with parameters [5,5,1,20,0], random noise added and then a background of
% 0.01 and 0.02 to the first and second data sets. That is, when the fit is
% performed, we expect the results [5,5,1,20,0.01] and [5,5,1,20,0.02]

% Perform a fit that constrains the first two parameters (gap and J) to be
% the same in both data sets, but allow the intensity and gamma to vary
% independently. A constant background can also vary independently.

win=[w1data,w2data];

% This will take a long time with your cross-section... first the evaluation of the initial conditions
wsim_1=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate' );

acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
dp(win)     % Draw Points
pl(wsim_1)  % Plot Line

% and now the fit
[wfit_1,fitpar_1]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});

acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
dp(win)     % Draw Points
pl(wfit_1)  % Plot Line


% This will be faster, because it gets the average h,k,l,e for all data pixels in a bin
% and evaluates only at that point. The final answer will be a little different of course -
% the extent will be dependent on how rapidly your dispersion function varies, and how big your
% bins are in the cut.
wsim_2=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'evaluate', 'ave' );
    
[wfit_2,fitpar_2]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}}, 'ave' );

acolor b r  % Set colours to blue followed by red; repeats this in succession if more than two objects in an array
dp(win)     % Draw Points
pl(wfit_2)  % Plot Line


%% ------------------------------------------------------------------------------------------------
% Example of fitting single dataset or independently fitting an array of datasets
% -------------------------------------------------------------------------------------------------

% Check fit_sqw correctly fits array of input
[wfit_single1,fitpar_single1]=fit_sqw(w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
[wfit_single2,fitpar_single2]=fit_sqw(w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
[wfit_single12,fitpar_single12]=fit_sqw(win, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
if ~equal_to_tol([wfit_single1,wfit_single2],wfit_single12)||~equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12), error('fit_sqw not working'), end

[wfit_single1,fitpar_single1]=multifit_sqw(w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
[wfit_single2,fitpar_single2]=multifit_sqw(w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1], @linear_bkgd, [0,0]);
if ~equal_to_tol([wfit_single1,wfit_single2],wfit_single12)||~equal_to_tol([fitpar_single1,fitpar_single2],fitpar_single12), error('fit_sqw not working'), end

% Check fit_sqw_sqw behaves as is should
[wfit_sqw_sqw,fitpar_sqw_sqw]=fit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,0], @sqw_bcc_hfm, [5,5,0,1,0], [0,0,0,0,1]);
[tmp1,ftmp1]=multifit_sqw_sqw(w1data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1]);
[tmp2,ftmp2]=multifit_sqw_sqw(w2data, @sqw_bcc_hfm, [5,5,1,10,0], [0,1,1,1,1]);
if ~equal_to_tol([tmp1,tmp2],wfit_sqw_sqw,-5e-12), error('fit_sqw_sqw not working'), end




%% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(demo_dir,'test_multifit_horace_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}),  old.(nam{i}), tol); if ~ok, error(['[',nam{i},']',mess]), end
    end    
end


%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file='c:\temp\test_multifit_horace_output.mat';
    save(output_file, 'wsim_1', 'wfit_1', 'fitpar_1', 'wsim_2', 'wfit_2', 'fitpar_2',...
        'wfit_single1','fitpar_single1','wfit_single2','fitpar_single2','wfit_single12','fitpar_single12',...
        'wfit_sqw_sqw','fitpar_sqw_sqw');

    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end

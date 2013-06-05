function test_multifit_horace_2(varargin)
% Performs some tests of fitting to Horace objects using multifit_sqw and other functions.
% Optionally writes results to output file
%
%   >> test_multifit_horace_2            % Compares with previously saved results in test_multifit_horace_2_output.mat
%                                        % in the same folder as this function
%   >> test_multifit_horace_2 ('save')   % Save to  c:\temp\test_multifit_horace_2_output.mat
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
% The data were created using the cross-section model sqw_bcc_hfm (which
% has a constant background as well as the spin wave cross-section)
% with parameters [5,5,1,20,0], random noise added and then a background of
% 0.01 and 0.02 to the first and second data sets. That is, when the fit is
% performed, we expect the results [5,5,1,20,0.01] and [5,5,1,20,0.02]

% Perform a fit that constrains the first two parameters (gap and J) to be
% the same in both data sets, but allow the intensity and gamma to vary
% independently. A constant background can also vary independently.

win=[w1data,w2data];

% fit
[wfit_1,fitpar_1]=multifit_sqw_sqw(win, @sqw_bcc_hfm, [5,5,0,10,0], [1,1,0,0,0],...
    @sqw_bcc_hfm, {[5,5,1.2,10,0],[5,5,1.4,15,0]}, [1,1,1,1,1], {{{1,1,0},{2,2,0}}});

% fit using new local foreground model
[wfit_1_locfore,fitpar_1_locfore]=multifit_sqw(win, @sqw_bcc_hfm_no_bkgd, {[5,5,1.2,10],[5,5,1.4,15]}, [], {{},{{1,1,-1},{2,2,-1}}},...
    @linear_bkgd, [0,0], [1,0], 'local_fore');

% Check fit parameter values
p1=[fitpar_1.bp{1},fitpar_1.bp{2}];
p1sig=[fitpar_1.bsig{1},fitpar_1.bsig{2}];
p1_alt=[fitpar_1_locfore.p{1},fitpar_1_locfore.bp{1}(1),fitpar_1_locfore.p{2},fitpar_1_locfore.bp{2}(1)];
p1sig_alt=[fitpar_1_locfore.sig{1},fitpar_1_locfore.bsig{1}(1),fitpar_1_locfore.sig{2},fitpar_1_locfore.bsig{2}(1)];

tol=-1e-8;
if ~equal_to_tol(p1, p1_alt, tol, 'min_denominator', 0.01) || ~equal_to_tol(p1sig, p1sig_alt, tol, 'min_denominator', 0.01)
    error('local background and local foreground equivalent fitting give different answers')
end




%% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(demo_dir,'test_multifit_horace_2_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    % The test proper
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}), old.(nam{i}), tol, 'min_denominator', 0.01, 'ignore_str', 1); if ~ok, error(['[',nam{i},']',mess]), end
    end    
    disp(' ')
    disp(' All OK')
    disp(' ')
end


%% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file='c:\temp\test_multifit_horace_2_output.mat';
    save(output_file, 'wfit_1', 'fitpar_1', 'wfit_1_locfore', 'fitpar_1_locfore');

    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end

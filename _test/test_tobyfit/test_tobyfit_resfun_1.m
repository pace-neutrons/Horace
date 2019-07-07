function varargout = test_tobyfit_resfun_1 (option)
% Test plotting of resolution function
%
% Perform tests:
%   >> test_test_tobyfit_resfun_1    
%               % Run the Tobyfit tests and test against stored fit
%               % parameters in test_tobyfit_resfun_1_out.mat in the same
%               % folder as this file
%
%   >> test_test_tobyfit_resfun_1 ('-save')
%               % Run the Tobyfit tests and save fit parameters
%               % to file test_tobyfit_resfun_1_out.mat
%               % in the temporary folder (given by tempdir)
%               % Copy to the same folder as this file to use in tests
%
%   >> test_test_tobyfit_resfun_1 ('-notest')
%               % Run without testing against previously stored results.
%               % For performing visual checks or debugging the tests!
%
% In all of the above, get the full output of the fits as a structure:
%
%   >> test_test_tobyfit_resfun_1

% ----------------------------------------------------------------------------
% Setup (should only have to do in extremis - assumes data on Toby Perring's computer
%   >> test_test_tobyfit_resfun_1 ('-setup')     % Create the cuts that will be fitted and save in
%                                   % test_tobyfit_resfun_1_data.mat in the temporary folder
%                                   % given by tempdir. Copy this file to the same folder
%                                   % that holds this .m file to use it in the following
%                                   % tests
%   >> status = test_resfun_1 ('-setup')


%% --------------------------------------------------------------------------------------
% Determine whether or not to save output
save_data = false;
save_output = false;
test_output = true;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-setup')
        save_data = true;
    elseif ischar(option) && isequal(lower(option),'-save')
        save_output = true;
    elseif ischar(option) && isequal(lower(option),'-notest')
        test_output = false;
    else
        error('Invalid option')
    end
end


%% --------------------------------------------------------------------------------------
% Setup
data_source = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';

datafile='test_tobyfit_resfun_1_data.mat';      % filename where saved results are written
savefile='test_tobyfit_resfun_1_out.mat';       % filename where saved results are written


%% --------------------------------------------------------------------------------------
% Create cuts to save as input data
% --------------------------------------------------------------------------------------
if save_data
    proj_110 = projaxes([1,1,0],[0,0,1]);
    % q-e plot along [0,0,1]
    w2a = cut_sqw(data_source,proj_110,[0.45,0.55],[-0.5,0.01,1.5],[-0.05,0.05],[-2,0,12],'-pix');
    % q-q plot
    wce = cut_sqw(data_source,proj_110,[0,0.01,1],[0,0.01,1],[-0.05,0.05],[5.8,6.2],'-pix');
    % q-e plot along [1,1,0]
    w2b = cut_sqw(data_source,proj_110,[0,0.01,1],[0.45,0.55],[-0.05,0.05],[-2,0,12],'-pix');
    
    % Now save to file for future use
    datafile_full = fullfile(tempdir,datafile);
    save(datafile_full,'w2a','wce','w2b');
    disp(['Saved data for future use in',datafile_full])
    if nargout>0
        varargout{1}=true;
    end
    return
    
else
    % Read in data
    load(datafile);
end

% Add instrument and sample information to cuts
sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
w2a=set_sample_and_inst(w2a,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
wce=set_sample_and_inst(wce,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
w2b=set_sample_and_inst(w2b,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');


%% --------------------------------------------------------------------------------------
% Read test results if necessary
% --------------------------------------------------------------------------------------
if test_output
    tmp=load(savefile);
end


%% --------------------------------------------------------------------------------------
% Standalone plots
% ---------------------------------------------------------------------------------------
pause_time = 0;

inst = maps_instrument_obj_for_tests(90,250,'s');
samp = IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);

det.x2=6;
det.phi=30;
det.azim=0;
det.width=0.0254;
det.height=0.0367;

ww1=resolution_plot([12.5,13.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3);
if test_output
    if ~equal_to_tol(ww1,tmp.ww1,[1e-8,1e-8])
        mess = 'ww1 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)

iax = [1,4];
ww2=resolution_plot([-0.5,0.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
if test_output
    if ~equal_to_tol(ww2,tmp.ww2,[1e-8,1e-8])
        mess = 'ww2 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)

iax = [1,4];
ww3=resolution_plot([39.5,40.5],inst,samp,det,100,1,[3,4,5],[90,90,90],[1,1,0],[0,0,1],24,0,1,2,3, iax);
if test_output
    if ~equal_to_tol(ww3,tmp.ww3,[1e-8,1e-8])
        mess = 'ww3 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)


%% --------------------------------------------------------------------------------------
% Plot resolution functions on a plot of an sqw object
% ---------------------------------------------------------------------------------------

% q-e plot along [0,0,1]
% ----------------------
% Pixels corresponding to the two points at which the resolution function woill be plotted
% [0.3,6]:    1596531
% [0.7,6]:    1602248
plot(w2a)
lx -0.5 1.5
lz 0 1000
cov1 = resolution_plot (w2a, [0.3,6; 0.7,6], 'curr');
if test_output
    if ~equal_to_tol(cov1,tmp.cov1,[1e-8,1e-8])
        mess = 'cov1 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)

    
% q-q plot
% ----------------------
% Pixels corresponding to the four points at which the resolution function woill be plotted
% [0.3,6]:    1596531
% [0.7,6]:    1602248
% [0.64,0.5]      363269
% [0.36,0.5]      361210
plot(wce)
lz 0 1000
cov2 = resolution_plot (wce, [0.5,0.3; 0.5,0.7], 'curr');
cov3 = resolution_plot (wce, [0.64,0.5; 0.36,0.5], 'curr');
if test_output
    if ~equal_to_tol(cov2,tmp.cov2,[1e-8,1e-8])
        mess = 'cov2 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
    if ~equal_to_tol(cov3,tmp.cov3,[1e-8,1e-8])
        mess = 'cov3 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)


% q-e plot along [1,1,0]
% ----------------------
% Pixels corresponding to the two points at which the resolution function woill be plotted
% [0.64,0.5]      363269
% [0.36,0.5]      361210
plot(w2b)
lz 0 1000
cov4 = resolution_plot (w2b, [0.36,6; 0.64,6], 'curr');
if test_output
    if ~equal_to_tol(cov4,tmp.cov4,[1e-8,1e-8])
        mess = 'cov4 not the same';
        warning ([mess,'. Press <cr> to continue'])
        pause
        error(mess)
    end
end
pause(pause_time)


%% --------------------------------------------------------------------------------------
% Collect results together as a structure
% ---------------------------------------------------------------------------------------

% Cuts
res.w2a = w2a;
res.wce = wce;
res.w2b = w2b;

res.ww1 = ww1;
res.ww2 = ww2;
res.ww3 = ww3;

res.cov1 = cov1;
res.cov2 = cov2;
res.cov3 = cov3;
res.cov4 = cov4;

if nargout>0
    varargout{1}=res;
end


%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),...
        'ww1','ww2','ww3','cov1','cov2','cov3','cov4');
end

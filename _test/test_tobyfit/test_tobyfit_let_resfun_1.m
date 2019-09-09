function test_tobyfit_let_resfun_1 (option)
% Test plotting of resolution function
%
% Perform tests:
%   >> test_test_tobyfit_let_resfun_1
%               % Run the Tobyfit tests and test against stored fit
%               % parameters in test_tobyfit_let_resfun_1_out.mat in the same
%               % folder as this file
%
%   >> test_test_tobyfit_let_resfun_1 ('-save')      
%               % Run the Tobyfit tests and save fit parameters
%               % to file test_tobyfit_resfun_1_out.mat
%               % in the temporary folder (given by tempdir)
%               % Copy to the same folder as this file to use in tests
%
%   >> test_test_tobyfit_let_resfun_1 ('-notest')   
%               % Run without testing against previously stored results.
%               % For performing visual checks or debugging the tests!


%% --------------------------------------------------------------------------------------
% Determine whether or not to save output
save_output = false;
test_output = true;

if exist('option','var')
    if ischar(option) && isequal(lower(option),'-save')
        save_output = true;
        test_output = false;
    elseif ischar(option) && isequal(lower(option),'-notest')
        test_output = false;
    else
        error('Invalid option')
    end
end


%% --------------------------------------------------------------------------------------
% Setup
datafile='test_tobyfit_let_resfun_1_data.mat';      % filename where saved results are written
savefile='test_tobyfit_let_resfun_1_out.mat';       % filename where saved results are written


%% --------------------------------------------------------------------------------------
% Create cuts to save as input data
% --------------------------------------------------------------------------------------
S=load(datafile);

% Add instrument and sample information to cuts
efix = 8.04;
instru = let_instrument_obj_for_tests (efix, 280, 140, 20, 2, 2);
sample = IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.012,0.012,0.04]);
w_nb_qe=set_sample(S.w_nb_qe,sample);
w_nb_qe=set_instrument(w_nb_qe,instru);


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

det.x2=3.5;
det.phi=60;
det.azim=0;
det.width=0.025;
det.height=0.04;

emode = 1;
alatt = [3.3,3.3,3.3];
angdeg = [90,90,90];
u = [1,1,0];
v = [0,0,1];

ww1=resolution_plot([2-0.01,2+0.01],instru,sample,det,efix,emode,alatt,angdeg,u,v,0,0,0,0,0);
if test_output
    if ~equal_to_tol(ww1,tmp.ww1,[1e-8,1e-8])
        mess = 'ww1 not the same';
        error(mess)
    end
end
pause(pause_time)

iax = [1,4];
ww2=resolution_plot([2-0.01,2+0.01],instru,sample,det,efix,emode,alatt,angdeg,u,v,0,0,0,0,0,iax);
if test_output
    if ~equal_to_tol(ww2,tmp.ww2,[1e-8,1e-8])
        mess = 'ww2 not the same';
        error(mess)
    end
end
pause(pause_time)



%% --------------------------------------------------------------------------------------
% Plot resolution functions on a plot of an sqw object
% ---------------------------------------------------------------------------------------

% q-e plot along [0,0,1]
% ----------------------
plot(w_nb_qe)
lx 0 0.2
lz 0 10000
% 
% *** MUST DEBUG: cov1 = resolution_plot (w_nb_qe, [0.3,1.20], 'curr');
cov1 = resolution_plot (w_nb_qe, [0.05,1.20; 0.15,2.80], 'curr');
if test_output
    if ~equal_to_tol(cov1,tmp.cov1,[1e-8,1e-8])
        mess = 'cov1 not the same';
        error(mess)
    end
end
pause(pause_time)


% %% --------------------------------------------------------------------------------------
% % Collect results together as a structure
% % ---------------------------------------------------------------------------------------
% 
% % Cuts
% res.w_nb_qe = w_nb_qe;
% res.ww1 = ww1;
% res.ww2 = ww2;
% res.cov1 = cov1;



%% --------------------------------------------------------------------------------------
% Save fit parameter output if requested
% ---------------------------------------------------------------------------------------
if save_output
    save(fullfile(tempdir,savefile),...
        'ww1','ww2','cov1');
end

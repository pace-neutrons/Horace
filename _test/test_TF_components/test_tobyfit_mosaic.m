classdef test_tobyfit_mosaic < TestCaseWithSave
    % Test of fitting moderator with Tobyfit
    
    properties
        w2_200_eval
        w2_020_eval
        alatt
        angdeg
        modQ
        mc
        seed
        rng_state
    end
    
    methods
        function obj = test_tobyfit_mosaic (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            % Note: in the (hopefully) extremely rare case of needing to
            % regenerate the data, use the static method generate_data (see
            % elsewhere in this class definition)
            data_file = 'test_tobyfit_mosaic_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);
            
            % Load sqw cuts
            load (data_file, 'w2_200_eval', 'w2_020_eval');
            
            % Add instrument and sample information to cuts
            sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.04,0.03,0.02],[6,0,4]);
            
            w2_200_eval=set_sample_and_inst(w2_200_eval,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
            w2_020_eval=set_sample_and_inst(w2_020_eval,sample,@maps_instrument_obj_for_tests,'-efix',600,'S');
            
            % Get lattice parameters
            obj.alatt = w2_020_eval.data.alatt;
            obj.angdeg = w2_020_eval.data.angdeg;
            obj.modQ = 2*(2*pi/obj.alatt(1));
            
            % Initialise test object properties
            obj.w2_200_eval = w2_200_eval;
            obj.w2_020_eval = w2_020_eval;
            obj.mc = 100;
            obj.seed = 0;
            
            % Required final line (see testCaseWithSave documentation)
            obj.save();
        end
        
        function obj = setUp(obj)
            % Save current rng state and force random seed and method
            obj.rng_state = rng(obj.seed, 'twister');
            warning('off', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        function obj = tearDown(obj)
            % Undo rng state
            rng(obj.rng_state);
            warning('on', 'HERBERT:mask_data_for_fit:bad_points')
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Simulate mosaic spread in Tobyfit
        % ---------------------------------------------------------------------------------------
        
        function obj = test_mosaic_200(obj)
            % Model parameters for Bragg blobs
            amp=1;  qfwhh=0.1;   efwhh=1;
            
            % Tobyfit simulations
            kk = tobyfit(obj.w2_200_eval);
            kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[obj.alatt,obj.angdeg]});
            kk = kk.set_mc_points(obj.mc);
            kk = kk.set_mc_contributions('none');
            w2_200_nores = kk.simulate;
            
            kk = kk.set_mc_contributions('mosaic');
            w2_200_mosaic = kk.simulate;
            
            % Average and covariance of 2D Bragg peak
            [av_nores, cov_nores] = covariance2 (w2_200_nores);
            av_nores = av_nores / obj.modQ;
            cov_nores = cov_nores / (obj.modQ)^2;
            
            [av_mos, cov_mos] = covariance2 (w2_200_mosaic);
            av_mos = av_mos / obj.modQ;
            cov_mos = cov_mos / (obj.modQ)^2;
            
            assertEqualToTolWithSave (obj, av_nores, [0, 0.05])
            assertEqualToTolWithSave (obj, cov_nores, [0, 0.05])
            
            assertEqualToTolWithSave (obj, av_mos, [0, 0.05])
            assertEqualToTolWithSave (obj, cov_mos, [0, 0.05])
            
        end
        
        
        function obj = test_mosaic_020(obj)
            % Model parameters for Bragg blobs
            amp=1;  qfwhh=0.1;   efwhh=1;
            
            % Tobyfit simulations
            kk = tobyfit(obj.w2_020_eval);
            kk = kk.set_fun(@make_bragg_blobs,{[amp,qfwhh,efwhh],[obj.alatt,obj.angdeg]});
            kk = kk.set_mc_points(obj.mc);
            kk = kk.set_mc_contributions('none');
            w2_020_nores = kk.simulate;
            
            kk = kk.set_mc_contributions('mosaic');
            w2_020_mosaic = kk.simulate;
            
            % Average and covariance of 2D Bragg peak
            [av_nores, cov_nores] = covariance2 (w2_020_nores);
            av_nores = av_nores / obj.modQ;
            cov_nores = cov_nores / (obj.modQ)^2;
            
            [av_mos, cov_mos] = covariance2 (w2_020_mosaic);
            av_mos = av_mos / obj.modQ;
            cov_mos = cov_mos / (obj.modQ)^2;
            
            assertEqualToTolWithSave (obj, av_nores, [0, 0.05])
            assertEqualToTolWithSave (obj, cov_nores, [0, 0.05])
            
            assertEqualToTolWithSave (obj, av_mos, [0, 0.05])
            assertEqualToTolWithSave (obj, cov_mos, [0, 0.05])
            
        end
        
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function generate_data (datafile)
            % Generate data and save to file
            %
            % Use:
            %   >> test_tobyfit_mosaic.generate_data ('my_output_file.mat')
            %
            % Input:
            % ------
            %   datafile    Name of file to which to save cuts for future use
            %               e.g. fullfile(tempdir,'test_tobyfit_mosaic_data.mat')
            %               Normal practice is to write to tempdir to check contents
            %               before manually replacing the file in the repository.
            
            % sqw files from which to take cuts for setup
            % These are private to Toby's computer as of 22/1/2023
            % Long term solution needed for data source locations
            data_source = 'T:\data\Fe\sqw_Toby\Fe_ei787.sqw';
            
            % Cuts from Fe
            % ------------
            % Area cuts about 200 and 020
            proj_100.u = [1,0,0];
            proj_100.v = [0,1,0];
            w2_200 = cut_sqw(data_source,proj_100,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);
            
            % w2_200_qk_cut = cut_sqw(data_source,proj_100,[1.95,2.05],[-0.3,0.02,0.3],[-0.05,0.05],[-10,10]);
            % w2_200_ql_cut = cut_sqw(data_source,proj_100,[1.95,2.05],[-0.05,0.05],[-0.3,0.02,0.3],[-10,10]);
            
            proj_010.u = [0,1,0];
            proj_010.v = [-1,0,0];
            w2_020=cut_sqw(data_source,proj_010,[1.95,2.05],[-0.3,0.02,0.3],[-0.3,0.02,0.3],[-10,10]);
            
            % Get lattice parameters
            alatt = w2_020.data.alatt;
            angdeg = w2_020.data.angdeg;
            
            % Simulate narrow Bragg blobs
            amp=1;  qfwhh=0.1;   efwhh=1;
            w2_200_eval=sqw_eval(w2_200,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
            w2_020_eval=sqw_eval(w2_020,@make_bragg_blobs,{[amp,qfwhh,efwhh],[alatt,angdeg]});
            
            % Make error bars all non-zero (so Tobyfit will not later filter these points out)
            tmp = sigvar(w2_200_eval); tmp.e = 1;
            w2_200_eval = sigvar_set(w2_200_eval, tmp);
            tmp = sigvar(w2_020_eval); tmp.e = 1;
            w2_020_eval = sigvar_set(w2_020_eval, tmp);
            
            
            % Save data
            % ---------
            save(datafile, 'w2_200_eval', 'w2_020_eval');
            disp(['Saved data for future use in ',datafile])
            
        end
    end
    
end


%==========================================================================
function [av, cov] = covariance2 (w)
% Get covariance of a 2D sqw object

x = (w.data.p{1}(2:end) + w.data.p{1}(1:end-1))/2;
y = (w.data.p{2}(2:end) + w.data.p{2}(1:end-1))/2;
signal = w.data.s;
[xx,yy] = ndgrid (x,y);
x_av = sum(xx(:).*signal(:)) / sum(signal(:));
y_av = sum(yy(:).*signal(:)) / sum(signal(:));
c_xx = sum(((xx(:)-x_av).^2).*signal(:)) / sum(signal(:));
c_yy = sum(((yy(:)-y_av).^2).*signal(:)) / sum(signal(:));
c_xy = sum(((xx(:)-x_av).*(yy(:)-y_av)).*signal(:)) / sum(signal(:));

av = [x_av; y_av];
cov = zeros(2);
cov(1,1) = c_xx;
cov(2,2) = c_yy;
cov(1,2) = c_xy;
cov(2,1) = c_xy;

end

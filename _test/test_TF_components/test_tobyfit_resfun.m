classdef test_tobyfit_resfun < TestCaseWithSave
    % Test of fitting moderator with Tobyfit
    
    properties
        w2a
        wce
        w2b
        tolerance
    end
    
    methods
        function obj = test_tobyfit_resfun (name)
            % Initialise object properties and pre-load test cuts for faster tests
            
            % Note: in the (hopefully) extremely rare case of needing to
            % regenerate the data, use the static method generate_data (see
            % elsewhere in this class definition)
            data_file = 'test_tobyfit_resfun_data.mat';   % filename where cuts for tests are stored
            obj = obj@TestCaseWithSave(name);
            
            % Load sqw cuts
            load (data_file, 'w2a','wce','w2b');
            
            % Add sample and instrument information to the RbMnF3 cuts
            sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            sample.alatt = [4.2240 4.2240 4.2240];
            sample.angdeg = [90 90 90];
            w2a=set_sample_and_inst(w2a,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
            wce=set_sample_and_inst(wce,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
            w2b=set_sample_and_inst(w2b,sample,@maps_instrument_obj_for_tests,'-efix',300,'S');
            
            % Initialise test object properties
            obj.w2a = w2a;      % q-e plot along [0,0,1]
            obj.wce = wce;      % q-q plot
            obj.w2b = w2b;      % q-e plot along [1,1,0]
            obj.tolerance = [1e-12, 1e-8];
            
            % Required final line (see testCaseWithSave documentation)
            obj.save();
        end
        
        
        %% --------------------------------------------------------------------------------------
        % Plot various ellipsoids on plots of sqw objects
        % ---------------------------------------------------------------------------------------
        
        % Manual check on how they look is required at the moment. The automatic
        % checks are the covariance matrices from which the plots are created.
        
        function obj = test_qe_along_001 (obj)
            plot(obj.w2a)
            lx -0.5 1.5
            lz 0 1000
            cov1 = resolution_plot (obj.w2a, [0.3,6; 0.7,6], 'curr');
            
            assertEqualToTolWithSave (obj, cov1, obj.tolerance)
        end
        
        
        function obj = test_qq_1 (obj)
            plot(obj.wce)
            lz 0 1000
            cov2 = resolution_plot (obj.wce, [0.5,0.3; 0.5,0.7], 'curr');
            
            assertEqualToTolWithSave (obj, cov2, obj.tolerance)
        end
        
        
        function obj = test_qq_2 (obj)
            plot(obj.wce)
            lz 0 1000
            cov3 = resolution_plot (obj.wce, [0.64,0.5; 0.36,0.5], 'curr');
            
            assertEqualToTolWithSave (obj, cov3, obj.tolerance)
        end
        
        
        function obj = test_qe_along_110 (obj)
            plot(obj.w2b)
            lz 0 1000
            cov4 = resolution_plot (obj.w2b, [0.36,6; 0.64,6], 'curr');
            
            assertEqualToTolWithSave (obj, cov4, obj.tolerance)
        end
        
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function generate_data (datafile)
            % Generate data and save to file
            %
            % Use:
            %   >> test_tobyfit_resfun.generate_data ('my_output_file.mat')
            %
            % Input:
            % ------
            %   datafile    Name of file to which to save cuts for future use
            %               e.g. fullfile(tempdir,'test_tobyfit_resfun_data.mat')
            %               Normal practice is to write to tempdir to check contents
            %               before manually replacing the file in the repository.
            
            % sqw files from which to take cuts for setup
            % These are private to Toby's computer as of 22/1/2023
            % Long term solution needed for data source locations
            data_source = 'T:\data\RbMnF3\sqw\rbmnf3_ref_newformat.sqw';
            
            % Cuts from RbMnF3
            % ----------------
            proj_110.u=[1,1,0];
            proj_110.v=[0,0,1];
            % q-e plot along [0,0,1]
            w2a = cut_sqw(data_source,proj_110,[0.45,0.55],[-0.5,0.01,1.5],[-0.05,0.05],[-2,0,12],'-pix');
            % q-q plot
            wce = cut_sqw(data_source,proj_110,[0,0.01,1],[0,0.01,1],[-0.05,0.05],[5.8,6.2],'-pix');
            % q-e plot along [1,1,0]
            w2b = cut_sqw(data_source,proj_110,[0,0.01,1],[0.45,0.55],[-0.05,0.05],[-2,0,12],'-pix');
            
            % Save data
            % ---------
            save(datafile,'w2a','wce','w2b');
            disp(['Saved data for future use in ',datafile])
            
        end
    end
    
end

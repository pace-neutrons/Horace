classdef test_mushroom_sqw < TestCaseWithSave
    % Test to buiild instrument in indirect mode, containing
    % multiple detectors fixed energies
    %
    % Optionally writes results to output file to compare with previously
    % saved sample test results
    %---------------------------------------------------------------------
    % Usage:
    %
    %1) Normal usage:
    % Run all unit tests and compare their results with previously saved
    % results stored in test_gen_sqw_accumulate_sqw_output.mat file
    % located in the same folder as this function:
    %
    %>>runtests test_gen_sqw_accumulate_sqw_sep_session
    %---------------------------------------------------------------------
    %2) Run particular test case from the suite:
    %
    %>>tc = test_gen_sqw_accumulate_sqw_sep_session();
    %>>tc.test_[particular_test_name] e.g.:
    %>>tc.test_accumulate_sqw14();
    %or
    %>>tc.test_gen_sqw();
    %---------------------------------------------------------------------
    %3) Generate test file to store test results to compare with them later
    %   (it stores test results into tmp folder.)
    %
    %>>tc=test_mushroom_sqw('save');
    %>>tc.save():
    properties
        % properties to use as input for data
        data_path;
        working_dir
        det_energy;
        
    end
    
    methods
        function obj=test_mushroom_sqw(test_class_name)
            %
            % Should be used as
            %
            %   >> runtests test_mushroom_sqw          % Compares with
            %   previously saved results in
            %   test_gen_sqw_accumulate_sqw_output.mat
            %                                           % in the same
            %                                           folder as this
            %                                           function
            %   >> test_gen_sqw_accumulate_sqw ('save') % Save to
            %   test_multifit_horace_1_output.mat
            %
            if ~exist('test_class_name','var')
                test_class_name = 'test_mushroom_sqw';
            end
            data_path= fullfile(fileparts(mfilename('fullpath')),'TestData');
            
            % Reads previously created test data sets.
            obj = obj@TestCaseWithSave(test_class_name,fullfile(data_path,'test_mushroom_sqw.mat'));
            obj.data_path = data_path;
            
            hc = hor_config;
            obj.working_dir = hc.working_directory;
            
            %------------------------------------------------------------
            ef_file = fullfile(data_path,'det_positions.dat');
            % e-fixed
            %------------------------------------------------------------
            fid = fopen(ef_file,'r');
            clOb = onCleanup(@()fclose(fid));
            tline = fgets(fid);
            tline = fgets(fid);
            n_det = textscan(tline,'%d10');
            n_det = n_det{1};
            tline = fgets(fid);
            obj.det_energy = zeros(1,n_det );
            for k=1:n_det
                tline = fgets(fid);
                Cont = textscan(tline ,'%9d %11.5f %11.5f %11.5f  %11.5f  %11.5f');
                obj.det_energy(k) = Cont{6};
            end
            
        end
        %
        function test_gen_sqw(obj)
            
            wkdir = obj.working_dir;
            sqw_file= fullfile(wkdir,'test_gen_sqw_indirect.sqw');
            cleanup_obj1=onCleanup(@()obj.delete_files(sqw_file));
            
            data_file = fullfile(obj.data_path,'MushroomSingleDE.nxspe');
            
            gen_sqw (data_file, '', sqw_file, obj.det_energy,...
                2, [2*pi,2*pi,2*pi], [90,90,90], [0,0,1], [0,-1,0],0,0,0,0,0);
            
            sqo = read_sqw(sqw_file);
            % Make some cuts: ---------------
            u=[0,0,1]; v=[0,1,0];
            proj = struct('u',u,'v',v);
            
            w2e = cut_sqw(sqo,proj,[0,0.01,3],[0,1.5],[0,1.1],[0,0.06,6]);
            obj.assertEqualToTolWithSave (w2e, [1.e-6,1.e-6],'ignore_str',1);
            w2xy = cut_sqw(sqo,proj,[0,3],[0,0.02,1.5],[0,0.01,1.1],[0,6]);
            obj.assertEqualToTolWithSave (w2xy, [1.e-6,1.e-6],'ignore_str',1);
            
            w2xz = cut_sqw(sqo,proj,[0,0.01,3],[0,1.5],[0,0.01,1.1],[0,6]);
            obj.assertEqualToTolWithSave (w2xz, [1.e-6,1.e-6],'ignore_str',1);
            
            w2yz = cut_sqw(sqo,proj,[0,0.01,3],[0,0.01,1.5],[0,1.1],[0,6]);
            obj.assertEqualToTolWithSave (w2yz, [1.e-6,1.e-6],'ignore_str',1);
            
            
            %             plot(w2e)
            %             keep_figure
            %             plot(w2xy)
            %             keep_figure
            %             plot(w2xz)
            %             keep_figure
            %
            %             plot(w2yz)
            %             keep_figure
            
        end
        
        %
        
        %
    end
end

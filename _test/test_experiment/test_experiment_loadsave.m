classdef test_experiment_loadsave < TestCase
    % Tests to check if the Experiment class loads and saves correctly

    properties
        % full path of this file --V
        % its directory --V
        this_dir = fileparts(mfilename('fullpath'));
        test_dir;
    end

    methods
        function obj = test_experiment_loadsave(name)
            obj = obj@TestCase(name);
            obj.test_dir = fullfile(fileparts(obj.this_dir),'common_data');
        end

        function test_loadsave_single_run_and_sqw(obj)
            % 'rundata_vs_sqw_refdata.mat' is an existing .mat file in the
            % test_sqw suite which provides a single sqw object sq4 with the old
            % header structure using one struct per run (single run) for all data.
            % sq4 is held in a struct test_rundata_sqw which is loadable
            % from the .mat file
            matfile = fullfile(obj.test_dir, 'rundata_vs_sqw_refdata.mat');
            % the file is loaded; the load process should convert the old
            % struct-type headers into an Experiment class
            ld = load(matfile);
            assertTrue( isa(ld.test_rundata_sqw.sq4.experiment_info, 'Experiment') );
            % the sq4 object is renamed as 'test_rundata_sqw.sq4' cannot be
            % saved as-is
            tmp_sqw = ld.test_rundata_sqw.sq4;
            % the sqw object is saved with the new Experiment class
            % experiment_info
            wkfile = fullfile(tmp_dir,'experiment_sqw.mat');
            clOb = onCleanup(@()delete(wkfile));
            save(wkfile, 'tmp_sqw');

            % tmp_sqw is reloaded from the .mat file, it should reload the
            % Experiment class experiment_info as-is
            ld1 = load(wkfile);
            % tmp_sqw is checked that it now does not have the marker field
            assertTrue( isa(ld1.tmp_sqw.experiment_info, 'Experiment') );
            assertEqual( ld1.tmp_sqw.experiment_info.detector_arrays, ...
                             tmp_sqw.experiment_info.detector_arrays );
            assertEqual( ld1.tmp_sqw.experiment_info.instruments, ...
                             tmp_sqw.experiment_info.instruments );
            assertEqual( ld1.tmp_sqw.experiment_info.samples, ...
                             tmp_sqw.experiment_info.samples );
            assertEqual( ld1.tmp_sqw.experiment_info.expdata, ...
                             tmp_sqw.experiment_info.expdata );
            assertEqualToTol( ld1.tmp_sqw, ld.test_rundata_sqw.sq4,1.e-7,'-ignore_date');
        end

        function test_loadsave_multiple_run_and_sqw(obj)
            % 'multisqw.mat' is an existing .mat file in the
            % test_sqw suite which provides an array sq3 of 2 sqw objects with the old
            % header structure using one struct per run (two runs) for all data.
            % sq3 is  is loadable directly from the .mat file.
            % NB sq3 was created from the 'rundata_vs_sqw_refdata.mat' file
            % by unpacking its object sq4 in an environment without the Experiment
            % class and (1) duplicating the header structs into a cell array
            % (2) duplicating the sqw objects into a top level array. The
            % headers have been made unique by appending '_1/2/3/4' to the
            % filename roots in the headers.
            matfile = fullfile(obj.this_dir, 'multisqw.mat');
            % the file is loaded; the load process should convert the old
            % struct-type headers into an Experiment class
            ldd = load(matfile);
            assertEqual( numel(ldd.sq3), 2);
            assertTrue( isa(ldd.sq3(1).experiment_info, 'Experiment') );
            assertTrue( isa(ldd.sq3(2).experiment_info, 'Experiment') );
            % OLD file was generated doing duplicated headers. The run-id/s
            % for these files were the same but same headers were
            % duplicated.
            % NEW FILE FORMAT: duplicated headers, which do not contain
            % references to pixels were deleted at loading.
            assertEqual( numel(ldd.sq3(1).experiment_info.expdata), 1);
            assertEqual( ldd.sq3(1).experiment_info.instruments.n_runs, 1);
            assertEqual( ldd.sq3(1).experiment_info.samples.n_runs, 1);
            assertEqual( numel(ldd.sq3(2).experiment_info.expdata), 1);
            assertEqual( ldd.sq3(2).experiment_info.instruments.n_runs, 1);
            assertEqual( ldd.sq3(2).experiment_info.samples.n_runs, 1);
            % the sqw object is saved with the new Experiment class
            % experiment_info
            loadsavefile = fullfile(tmp_dir, 'experiment_multisqw.mat');
            cleanup_obj = onCleanup(@()delete(loadsavefile));
            sq3 = ldd.sq3;
            save(loadsavefile, 'sq3');
            % sq3 is reloaded from the .mat file, it should reload the
            % Experiment class experiment_info as-is
            ld1 = load(loadsavefile);
            % sq3 is checked that it now does not have the marker field
            % extra in its main_header
            assertTrue( isa(ld1.sq3(1).experiment_info, 'Experiment') );
            assertTrue( isa(ld1.sq3(2).experiment_info, 'Experiment') );
            assertEqual( ld1.sq3(1).experiment_info.detector_arrays, ...
                             sq3(1).experiment_info.detector_arrays );
            assertEqual( ld1.sq3(1).experiment_info.instruments, ...
                             sq3(1).experiment_info.instruments );
            assertEqual( ld1.sq3(1).experiment_info.samples, ...
                             sq3(1).experiment_info.samples );
            assertEqual( ld1.sq3(1).experiment_info.expdata, ...
                             sq3(1).experiment_info.expdata );
            assertEqual( ld1.sq3(2).experiment_info.detector_arrays, ...
                             sq3(2).experiment_info.detector_arrays );
            assertEqual( ld1.sq3(2).experiment_info.instruments, ...
                             sq3(2).experiment_info.instruments );
            assertEqual( ld1.sq3(2).experiment_info.samples, ...
                             sq3(2).experiment_info.samples );
            assertEqual( ld1.sq3(2).experiment_info.expdata, ...
                             sq3(2).experiment_info.expdata );
            
            assertEqual( numel(ld1.sq3), 2);
            assertEqualToTol(sq3,ld1.sq3,1.e-12,'-ignore_date','ignore_str',true);
        end % test_loadsave_multiple_run_and_sqw
        
        function test_loadsave_detectors(~)
            % partial setup of an sqw for the purposes of testing the
            % saving and reloading of detector arrays 
            
            % empty sqw
            mysqw = sqw();
            % add IX_experiment, instrument, sample for 2 runs
            expdata = IX_experiment();
            expdata = repmat(expdata, 2, 1);
            inst = IX_null_inst();
            inst = repmat({inst},2,1);
            samp = IX_samp();
            samp = repmat({samp},2,1);
            % create a detpar structure with dummy data
            detpar = struct('filename','fake',  ...
                            'filepath', '/fake',...
                            'group',    [1; 2; 3; 4], ...
                            'x2',       [5; 5; 5; 5], ...
                            'phi',      [1; 1; 1; 1], ...
                            'azim',     [2; 2; 2; 2], ...
                            'width',    [3; 3; 3; 3], ...
                            'height',   [4; 4; 4; 4]  ...
                            );
             % clone it and alter x2 to distingiush the 2 detpars
             detpar2 = detpar;
             detpar2.x2 = [6; 6; 6; 6];
             % make detector arrays from the detpars and combine in a cell
             det = IX_detector_array(detpar);
             det2 = IX_detector_array(detpar2);
             dets = {det,det2};
             % store all the above in an experiment and initialise
             % experiment_info for the sqw
             expinf = Experiment(dets,inst,samp,expdata);
             mysqw.experiment_info = expinf;
             assertEqual(mysqw.experiment_info.detector_arrays.n_runs,2);
             
             % save, load and compare the experiment info and detpar struct
             % into a .mat file
             cl0b_file = onCleanup(@()delete('a.mat','mysqw.sqw'));
             save('a.mat','mysqw');
             zzz = load('a.mat');
             % compare the experiment_info and detpar (equivalent to the detector_arrays in experiment_info) for the
             % original and reloaded sqws
             assertEqualToTol(zzz.mysqw.experiment_info, mysqw.experiment_info,0.0,'ignore_str',true);
             assertEqualToTol(zzz.mysqw.detpar, mysqw.detpar,0.0,'ignore_str',true);
             % repeat the save and load to a file and repeat the comparison
             mysqw.save('mysqw.sqw');
             nusqw = read_sqw('mysqw.sqw','-nopix');
             assertEqualToTol(nusqw.experiment_info, mysqw.experiment_info,0.0,'ignore_str',true);
             assertEqualToTol(nusqw.experiment_info.detector_arrays, ...
                 mysqw.experiment_info.detector_arrays,0.0,'ignore_str',true);
        end
    end
end

classdef test_experiment_cnstrct_and_properties < TestCase

    methods
        
        function obj = test_experiment_cnstrct_and_properties(varargin)
        % CONSTRUCTOR - could be defaulted, inserted for ease of upgrade
            if nargin == 0
                name = 'test_experiment_cnstrct_and_properties';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        
        function test_default_constructor_creates_appropriate_objects(~)
        % DEFAULT CONSTRUCTOR TEST - should construct its instrument, samples
        % and detector_arrays containers and the experiment data array,
        % which, being empty, will define a zero number of runs.
        
            expt = Experiment();
            assertEqual(expt.n_runs,0);

            assertTrue( isa( expt.samples, 'unique_references_container' ) );
            assertEqual( expt.samples.global_name, 'GLOBAL_NAME_SAMPLES_CONTAINER' );
            assertEqual( expt.samples.n_runs, 0 );
            function throw1()
                expt.samples{1};
            end
            assertExceptionThrown(@throw1, 'HERBERT:unique_references_container:invalid_subscript');

            assertTrue( isa( expt.instruments, 'unique_references_container' ) );
            assertEqual( expt.instruments.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );
            assertEqual( expt.instruments.n_runs, 0 );
            function throw2()
                expt.instruments{1};
            end
            assertExceptionThrown(@throw2, 'HERBERT:unique_references_container:invalid_subscript');

            assertTrue( isa( expt.detector_arrays, 'unique_references_container' ) );
            assertEqual( expt.detector_arrays.global_name, 'GLOBAL_NAME_DETECTORS_CONTAINER' );
            assertEqual( expt.detector_arrays.n_runs, 0 );
            function throw3()
                expt.detector_arrays{1};
            end
            assertExceptionThrown(@throw2, 'HERBERT:unique_references_container:invalid_subscript');

            assertTrue(isempty(expt.expdata));
        end
        
        function test_nontrivial_runid_map(~)
        % CONSTRUCTOR WITH 4 ARGS TEST - where the arguments are
        % cells/arrays. The calculated runid is also tested
            instruments = {IX_inst_DGfermi(), IX_inst_DGdisk(),IX_inst_DGdisk()};
            sample1 = IX_sample;
            sample1.name = 'sample1';
            sample2 = IX_sample;
            sample2.name = 'sample2';
            sample3  = IX_samp();
            sample3.name = 'sample3';
            samples = {sample1,sample2,sample3};
            exp = repmat(IX_experiment,3,1);
            exp(1).run_id = 10;
            exp(1).filename = 'a1';
            exp(2).run_id = 20;
            exp(2).filename = 'a2';
            exp(3).run_id = 30;
            exp(3).filename = 'a3';
            detectors = repmat(IX_detector_array(),1,numel(exp));

            exper= Experiment(detectors,instruments,samples,exp);
            % at this point the samples have not been given lattice
            % definitions so a warning will be issued
            [a,b] = lastwarn;
            assertEqual(a, ...
                'Samples in experiment are defined but their lattice is undefined');
            assertEqual(b, ...
                'HORACE:Experiment:lattice_undefined');
            
            % now add lattice definitions and clear the last warning
            lastwarn('nothing warned','HORACE:Experiment:set_no_previous_warnings');            
            sample1.alatt = [6,6,6];
            sample2.alatt = [6,6,6];
            sample3.alatt = [6,6,6];
            sample1.angdeg = [90,90,90];
            sample2.angdeg = [90,90,90];
            sample3.angdeg = [90,90,90];
            
            samples2 = {sample1,sample2,sample3};
            
            % now the lattice definitions should be dealt with so no
            % additional warning should be issued
            exper= Experiment(detectors,instruments,samples2,exp);
            assertEqual(lastwarn, 'nothing warned');
  
            assertEqual(exper.n_runs,3)

            assertFalse(exper.runid_recalculated)
            assertEqual(exper.runid_map.keys,{10,20,30});
            assertEqual(exper.runid_map.values,{1,2,3});
            exp = exper.expdata;
            id = exp.get_run_ids();
            assertEqual(id,[10,20,30]);

        end

        function test_creates_object_with_single_object_arguments(~)
            detector_array = IX_detector_array();
            instrument = IX_inst_DGfermi();
            sample = IX_sample();
            info = IX_experiment();
            expt = Experiment(detector_array, instrument, sample,info);

            assertEqual(expt.samples{1}, sample);
            assertEqual(expt.instruments{1}, instrument);
            assertEqual(expt.detector_arrays{1}, detector_array);
        end

        function test_creates_object_with_empty_object_arguments(~)
            expt = Experiment([], [], [],[]);
            assertEqual(expt.n_runs,0);
            assertEqual(expt.instruments.n_runs, 0);
            assertEqual(expt.samples.n_runs, 0);
            assertEqual(expt.detector_arrays.n_runs, 0);
            assertTrue(isempty(expt.expdata));
        end
        
        function test_constructor_raises_error_with_invalid_single_input(~)
            assertExceptionThrown(@()Experiment('something incorrect'),...
                'HORACE:Experiment:invalid_argument');
        end

        function test_constructor_raises_error_with_no_sample(~)
            assertExceptionThrown(@()Experiment(IX_detector_array, IX_inst_DGfermi, 'not-a-sample',IX_experiment),...
                'HORACE:Experiment:invalid_argument');
        end
        function test_constructor_raises_error_with_no_instrument(~)
            assertExceptionThrown(@()Experiment(IX_detector_array, 'not-an-inst', IX_sample, IX_experiment),...
                'HORACE:Experiment:invalid_argument');
        end
        function test_constructor_raises_error_with_no_detectors(~)
            assertExceptionThrown(@()Experiment('not-a-da', IX_inst_DGfermi, IX_sample, IX_experiment),...
                'HORACE:Experiment:invalid_argument');
        end
        function test_constructor_raises_error_with_no_expdata(~)
            assertExceptionThrown(@()Experiment(IX_detector_array, IX_inst_DGfermi, IX_sample, 'not-a-expd'),...
                'HORACE:Experiment:invalid_argument');
        end

        function test_creates_object_with_array_object_arguments(~)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi();
            sample = IX_sample;
            sample.alatt = [6,6,6];
            sample.angdeg = [90,90,90];
            info = [IX_experiment,IX_experiment];
            expt = Experiment( ...
                [detector_array, detector_array], ...
                [instrument, instrument], ...
                [sample, sample],info);

            assertEqual({expt.samples{1}, expt.samples{2}}, {sample, sample});
            assertEqual({expt.instruments{1}, expt.instruments{2}}, {instrument, instrument});
            assertEqual({expt.detector_arrays{1},expt.detector_arrays{2}}, {detector_array, detector_array});
            info = expt.expdata;
            assertTrue(expt.runid_recalculated)
            assertEqual(numel(info),2)
            assertEqual(info(1).run_id,1)
            assertEqual(info(2).run_id,2)
            assertEqual(expt.runid_map.keys,{1,2});
            assertEqual(expt.runid_map.values,{1,2});

        end

        function test_load_save_object_creates_identical_object(~)
            tmpfile = fullfile(tmp_dir(), 'loadsave.mat');
            clobR=onCleanup(@()delete(tmpfile));

            instruments = {IX_inst_DGfermi(), IX_inst_DGdisk()};
            sample1 = IX_sample;
            sample1.name = 'sample1';
            sample1.alatt = [6 6 6];
            sample1.angdeg = [90 90 90];
            sample2 = IX_sample;
            sample2.name = 'sample2';
            sample2.alatt = [6 6 6];
            sample2.angdeg = [90 90 90];
            samples = [sample1, sample2];
            data = [IX_experiment(),IX_experiment()];
            detectors = repmat(IX_detector_array(), 1, numel(data));

            expt = Experiment(detectors, instruments, samples,data);
            info = expt.expdata;
            assertTrue(expt.runid_recalculated)
            assertEqual(numel(info),2)
            assertEqual(info(1).run_id,1)
            assertEqual(info(2).run_id,2)
            assertEqual(expt.runid_map.keys,{1,2});
            assertEqual(expt.runid_map.values,{1,2});

            save(tmpfile, 'expt');
            clear('expt');

            load(tmpfile, 'expt');
            s1 = expt.samples{1};
            s2 = expt.samples{2};
            assertEqual(s1.name, 'sample1')
            assertEqual(s1.alatt, [6 6 6]);
            assertEqual(s1.angdeg, [90 90 90]);
            assertEqual(s2.name, 'sample2')
            assertEqual(s2.alatt, [6 6 6]);
            assertEqual(s2.angdeg, [90 90 90]);
            assertTrue(isa(expt.instruments{1}, 'IX_inst_DGfermi'));
            assertTrue(isa(expt.instruments{2}, 'IX_inst_DGdisk'));
            assertEqual(expt.detector_arrays.n_runs, 2);
            assertTrue( isa( expt.detector_arrays{1}, 'IX_detector_array') );
            info = expt.expdata;
            assertEqual(numel(info),2)
            assertEqual(info(1).run_id,1)
            assertEqual(info(2).run_id,2)
            assertEqual(expt.runid_map.keys,{1,2});
            assertEqual(expt.runid_map.values,{1,2});
        end

        function test_load_save_default_object_creates_default_object(~)
            tmpfile = fullfile(tmp_dir(), 'loadsave_default.mat');
            clobR=onCleanup(@()delete(tmpfile));

            expt = Experiment();

            save(tmpfile, 'expt');
            clear('expt');

            load(tmpfile, 'expt');
            
            assertTrue( isa( expt.samples, 'unique_references_container'));
            assertTrue( isa( expt.instruments, 'unique_references_container'));
            assertTrue( isa( expt.detector_arrays, 'unique_references_container'));
            assertEqual( expt.samples.n_runs, 0);
            assertEqual( expt.instruments.n_runs, 0);
            assertEqual( expt.detector_arrays.n_runs, 0);
            
            assertEqual(expt.expdata, []);
        end

        function test_instruments_setter_updates_value_for_valid_value(~)
            instruments = {IX_inst_DGfermi(),...
                IX_inst_DGdisk()};
            expt = Experiment();
            function throw1()
                expt.instruments = instruments;
            end
            assertExceptionThrown(@throw1, ...
                      'HORACE:Experiment:invalid_argument');

            % cannot add instruments if there are no runs defined      
            assertEqual(expt.instruments.n_runs, 0);
            
            % create new experiment with consistent contents
            % can only create experiment this way, not by adding items
            % individually (although you can modify them afterwards
            expdata = [IX_experiment(), IX_experiment()];
            samps = {IX_samp(), IX_samp()};
            exp2 = Experiment([], instruments, samps, expdata);
            assertEqual(exp2.instruments{2}, instruments{2});
            assertEqual(exp2.samples{1}, samps{1});
            assertEqual(exp2.n_runs, 2);
        end

        function test_instruments_setter_raises_error_for_invalid_value(~)
            instruments = 'non-instrument object value';
            expt = Experiment();

            assertExceptionThrown(@() setInstrumentsProperty(expt, instruments),...
                'HORACE:Experiment:invalid_argument');
            function setInstrumentsProperty(e, i)
                e.instruments = i;
            end
        end

        function test_construction_with_all_valid_components(~)
            samples = IX_sample;
            instruments = IX_null_inst();
            detectors = IX_detector_array();
            expdata = IX_experiment();
            % as only 1 run, set it here and then the final comparison will
            % work (otherwise it's 1 vs. NaN)
            expdata.run_id = 1;
            
            expt = Experiment(detectors, instruments, samples,expdata);
            % expt.samples = {samples};

            assertEqual(expt.samples{1}, samples);
            urc = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp');
            urc = urc.add(samples);
            assertEqual(expt.samples,  urc);

            assertEqual(expt.instruments{1}, instruments);
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            urc = urc.add(instruments);
            assertEqual(expt.instruments,  urc);

            assertEqual(expt.detector_arrays{1}, detectors);
            urc = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER','IX_detector_array');
            urc = urc.add(detectors);
            assertEqual(expt.detector_arrays,  urc);
            
            assertEqual(expt.expdata, expdata);
        end

        function test_loadsave_with_all_valid_components(~)
            samples = IX_sample;
            samples.alatt = [6,6,6];
            samples.angdeg = [90,90,90];
            instruments = IX_null_inst();
            detectors = IX_detector_array();
            expdata = IX_experiment();
            % as only 1 run, set it here and then the final comparison will
            % work (otherwise it's 1 vs. NaN)
            expdata.run_id = 1;
            
            expt = Experiment(detectors, instruments, samples,expdata);

            tmpfile = fullfile(tmp_dir(), 'loadsave_constructed.mat');
            clobR=onCleanup(@()delete(tmpfile));

            save(tmpfile, 'expt');
            clear('expt');

            load(tmpfile, 'expt');            
            assertEqual(expt.samples{1}, samples);
            urc = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp');
            urc = urc.add(samples);
            assertEqual(expt.samples,  urc);

            assertEqual(expt.instruments{1}, instruments);
            urc = unique_references_container('GLOBAL_NAME_INSTRUMENTS_CONTAINER','IX_inst');
            urc = urc.add(instruments);
            assertEqual(expt.instruments,  urc);

            assertEqual(expt.detector_arrays{1}, detectors);
            urc = unique_references_container('GLOBAL_NAME_DETECTORS_CONTAINER','IX_detector_array');
            urc = urc.add(detectors);
            assertEqual(expt.detector_arrays,  urc);
            
            assertEqual(expt.expdata, expdata);
        end

        function test_samples_setter_raises_error_for_invalid_value(~)
            samples = 'non-sample object value';
            expt = Experiment();

            % this fails and is caught as the value is invalid
            % see next test for failure to set with a valid value as expt
            % is empty.
            assertExceptionThrown(@() setSamplesProperty(expt, samples),...
                'HORACE:Experiment:invalid_argument');
            function setSamplesProperty(e, s)
                e.samples = s;
            end
        end

        function test_detector_arrays_setter_updates_value_for_valid_value(~)
            detector_arrays = IX_detector_array;
            expt = Experiment();
            
            % attempt to set detector arrays should fail because there are
            % no runs in the empty Experiment
            function throw1()
                expt.detector_arrays = detector_arrays;
            end
            assertExceptionThrown(@throw1, ...
                'HORACE:Experiment:invalid_argument');
            
            % attempt to get a detector array out of experiment should fail
            % because there are none; the previous attempt to define them
            % failed.
            function throw2()   
                assertEqual(expt.detector_arrays{1}, detector_arrays);
            end
            assertExceptionThrown(@throw2, ...
                'HERBERT:unique_references_container:invalid_subscript');
        end

        function test_detector_arrays_setter_raises_error_for_invalid_value(~)
            detector_arrays = 'non-detector_arrays object value';
            expt = Experiment();

            % see previous test for failure with valid value
            assertExceptionThrown(@() setDetectorArraysProperty(expt, detector_arrays),...
                'HORACE:Experiment:invalid_argument');
            function setDetectorArraysProperty(e, d)
                e.detector_arrays = d;
            end
        end
    end
end


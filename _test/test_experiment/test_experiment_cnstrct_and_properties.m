classdef test_experiment_cnstrct_and_properties < TestCase

    methods
        function test_default_constructor_creates_appropriate_objects(~)
            expt = Experiment();
            assertEqual(expt.n_runs,0);

            assertTrue( isa( expt.samples, 'unique_references_container' ) );
            assertEqual( expt.samples.global_name, 'GLOBAL_NAME_SAMPLES_CONTAINER' );
            assertEqual( expt.samples.n_runs, 0 );
            function throw1()
                expt.samples{1};
            end
            assertExceptionThrown(@throw1, 'HERBERT:unique_references_container:invalid_argument');
            assertTrue( isa( expt.instruments, 'unique_references_container' ) );
            assertEqual( expt.instruments.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );
            assertEqual( expt.instruments.n_runs, 0 );
            function throw2()
                expt.instruments{1};
            end
            assertExceptionThrown(@throw2, 'HERBERT:unique_references_container:invalid_argument');
            assertTrue(isempty(expt.detector_arrays));
            assertTrue(isempty(expt.expdata));
        end
        function test_nontrivial_runid_map(~)
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
            clOwr =set_temporary_warning('off','HORACE:Experiment:invalid_argument');
            exper= Experiment(IX_detector_array,instruments,samples,exp);

            assertEqual(exper.n_runs,3)

            assertFalse(exper.runid_recalculated)
            assertEqual(exper.runid_map.keys,{10,20,30});
            assertEqual(exper.runid_map.values,{1,2,3});
            exp = exper.expdata;
            id = exp.get_run_ids();
            assertEqual(id,[10,20,30]);

        end

        function test_creates_object_with_single_object_arguments(~)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi();
            sample = IX_sample;
            info = IX_experiment();
            clOwr =set_temporary_warning('off','HORACE:Experiment:invalid_argument');
            expt = Experiment(detector_array, instrument, sample,info);

            assertEqual(expt.samples{1}, sample);
            assertEqual(expt.instruments{1}, instrument);
            assertEqual(expt.detector_arrays, detector_array);
        end

        function test_creates_object_with_empty_object_arguments(~)
            expt = Experiment([], [], [],[]);
            assertEqual(expt.n_runs,0);

            assertTrue(isa(expt.samples{1},'IX_null_sample'));
            assertTrue(isa(expt.instruments{1},'IX_null_inst'));
            assertTrue(isempty(expt.detector_arrays));
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
            info = [IX_experiment,IX_experiment];
            clOwr =set_temporary_warning('off','HORACE:Experiment:invalid_argument');
            expt = Experiment( ...
                [detector_array, detector_array], ...
                [instrument, instrument], ...
                [sample, sample],info);

            assertEqual({expt.samples{1}, expt.samples{2}}, {sample, sample});
            assertEqual({expt.instruments{1}, expt.instruments{2}}, {instrument, instrument});
            assertEqual(expt.detector_arrays, [detector_array, detector_array]);
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
            sample2 = IX_sample;
            sample2.name = 'sample2';
            samples = [sample1, sample2];
            data = [IX_experiment(),IX_experiment()];
            clOwr =set_temporary_warning('off','HORACE:Experiment:invalid_argument');
            expt = Experiment(IX_detector_array, instruments, samples,data);
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
            assertEqual(s2.name, 'sample2')
            assertTrue(isa(expt.instruments{1}, 'IX_inst_DGfermi'));
            assertTrue(isa(expt.instruments{2}, 'IX_inst_DGdisk'));
            assertEqual(expt.detector_arrays, IX_detector_array);
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
            assertTrue( isa( expt.samples, 'unique_references_container' ) );
            assertEqual( expt.samples.global_name, 'GLOBAL_NAME_SAMPLES_CONTAINER' );
            assertEqual( expt.samples.n_runs, 0 );
            function throw1()
                expt.samples{1};
            end
            assertExceptionThrown(@throw1, 'HERBERT:unique_references_container:invalid_argument');
            assertTrue( isa( expt.instruments, 'unique_references_container' ) );
            assertEqual( expt.instruments.global_name, 'GLOBAL_NAME_INSTRUMENTS_CONTAINER' );
            assertEqual( expt.instruments.n_runs, 0 );
            function throw2()
                expt.instruments{1};
            end
            assertExceptionThrown(@throw2, 'HERBERT:unique_references_container:invalid_argument');
            assertEqual(expt.detector_arrays, []);
        end

        function test_instruments_setter_updates_value_for_valid_value(~)
            instruments = {IX_inst_DGfermi(),...
                IX_inst_DGdisk()};
            expt = Experiment();
            expt.instruments = instruments;

            assertEqual(expt.instruments{1}, instruments{1});
            assertEqual(expt.instruments{2}, instruments{2});
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

        function test_samples_setter_updates_value_for_valid_value(~)
            samples = IX_sample;
            expt = Experiment();
            expt.samples = {samples};

            assertEqual(expt.samples{1}, samples);
            urc = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp');
            urc = urc.add(samples);
            assertEqual(expt.samples,  urc);
        end

        function test_samples_setter_raises_error_for_invalid_value(~)
            samples = 'non-sample object value';
            expt = Experiment();

            assertExceptionThrown(@() setSamplesProperty(expt, samples),...
                'HORACE:Experiment:invalid_argument');
            function setSamplesProperty(e, s)
                e.samples = s;
            end
        end

        function test_detector_arrays_setter_updates_value_for_valid_value(~)
            detector_arrays = IX_detector_array;
            expt = Experiment();
            expt.detector_arrays = detector_arrays;

            assertEqual(expt.detector_arrays, detector_arrays);
        end

        function test_detector_arrays_setter_raises_error_for_invalid_value(~)
            detector_arrays = 'non-detector_arrays object value';
            expt = Experiment();

            assertExceptionThrown(@() setDetectorArraysProperty(expt, detector_arrays),...
                'HORACE:Experiment:invalid_argument');
            function setDetectorArraysProperty(e, d)
                e.detector_arrays = d;
            end
        end
    end
end


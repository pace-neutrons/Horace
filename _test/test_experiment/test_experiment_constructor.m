classdef test_experiment_constructor < TestCase

    methods
        function test_default_constructor_creates_object_of_empty_arrays(~)
            expt = Experiment();

            assertTrue(isempty(expt.samples));
            assertTrue(isempty(expt.instruments));
            assertTrue(isempty(expt.detector_arrays));
        end

        function test_creates_object_with_single_object_arguments(~)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi();
            sample = IX_sample;
            expt = Experiment(detector_array, instrument, sample);

            assertEqual(expt.samples{1}, sample);
            assertEqual(expt.instruments{1}, instrument);
            assertEqual(expt.detector_arrays, detector_array);
        end

        function test_creates_object_with_empty_object_arguments(~)
            expt = Experiment([], [], []);

            assertTrue(isempty(expt.samples));
            assertTrue(isempty(expt.instruments));
            assertTrue(isempty(expt.detector_arrays));
        end
        function test_constructor_raises_error_with_invalid_single_input(~)
            assertExceptionThrown(@()Experiment('something icorrect'),...
                'HORACE:Experiment:invalid_argument');
        end

        function test_constructor_raises_error_with_no_sample(~)
            assertExceptionThrown(@()Experiment(IX_detector_array, IX_inst_DGfermi, 'not-a-sample'),...
                'HORACE:Experiment:invalid_argument');
        end
        function test_constructor_raises_error_with_no_instrument(~)
            assertExceptionThrown(@()Experiment(IX_detector_array, 'not-an-inst', IX_sample),...
                'HORACE:Experiment:invalid_argument');
        end
        function test_constructor_raises_error_with_no_detectors(~)
            assertExceptionThrown(@()Experiment('not-a-da', IX_inst_DGfermi, IX_sample),...
                'HORACE:Experiment:invalid_argument');
        end

        function test_creates_object_with_array_object_arguments(~)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi();
            sample = IX_sample;
            expt = Experiment( ...
                [detector_array, detector_array], ...
                [instrument, instrument], ...
                [sample, sample]);

            assertEqual(expt.samples, {sample, sample});
            assertEqual(expt.instruments, {instrument, instrument});
            assertEqual(expt.detector_arrays, [detector_array, detector_array]);
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

            expt = Experiment(IX_detector_array, instruments, samples);

            save(tmpfile, 'expt');
            clear('expt');

            load(tmpfile, 'expt');
            assertEqual(expt.samples{1}.name, 'sample1')
            assertEqual(expt.samples{2}.name, 'sample2')
            assertTrue(isa(expt.instruments{1}, 'IX_inst_DGfermi'));
            assertTrue(isa(expt.instruments{2}, 'IX_inst_DGdisk'));
            assertEqual(expt.detector_arrays, IX_detector_array);
        end

        function test_load_save_default_object_creates_default_object(~)
            tmpfile = fullfile(tmp_dir(), 'loadsave_default.mat');
            clobR=onCleanup(@()delete(tmpfile));

            expt = Experiment();

            save(tmpfile, 'expt');
            clear('expt');

            load(tmpfile, 'expt');
            assertTrue( isempty(expt.instruments));
            assertTrue( isempty(expt.samples));
            assertEqual(expt.detector_arrays, []);
        end

        function test_instruments_setter_updates_value_for_valid_value(~)
            instruments = {IX_inst_DGfermi(),...
                IX_inst_DGdisk()};
            expt = Experiment();
            expt.instruments = instruments;

            assertEqual(expt.instruments, instruments);
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
            assertEqual(expt.samples,    {samples});
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


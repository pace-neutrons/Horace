classdef test_experiment < TestCaseWithSave

    methods
        function test_default_constructor_creates_object_of_empty_arrays(self)
            expt = Experiment();
            
            assertTrue(isempty(expt.samples));
            assertTrue(isempty(expt.instruments));
            assertTrue(isempty(expt.detector_arrays));
        end

        function test_creates_object_with_single_object_arguments(self)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi;
            sample = IX_sample;
            expt = Experiment(detector_array, instrument, sample);
            
            assertEqual(expt.samples, [sample]);
            assertEqual(expt.instruments, [instrument]);
            assertEqual(expt.detector_arrays, [detector_array]);
        end

        function test_creates_object_with_empty_object_arguments(self)
            expt = Experiment([], [], []);
            
            assertTrue(isempty(expt.samples));
            assertTrue(isempty(expt.instruments));
            assertTrue(isempty(expt.detector_arrays));
        end

        function test_creates_object_with_array_object_arguments(self)
            detector_array = IX_detector_array;
            instrument = IX_inst_DGfermi;
            sample = IX_sample;
            expt = Experiment( ...
                [detector_array, detector_array], ...
                [instrument, instrument], ...
                [sample, sample]);
            
            assertEqual(expt.samples, [sample, sample]);
            assertEqual(expt.instruments, [instrument, instrument]);
            assertEqual(expt.detector_arrays, [detector_array, detector_array]);
        end

        function test_load_save_object_creates_identical_object(self)
            tmpfile = fullfile([tempdir(), 'test_experiment', 'loadsave.mat']);
            clobR=onCleanup(@()self.delete_files(tmpfile));
            
            instruments = [IX_inst_DGfermi, IX_inst_DGdisk];
            sample1 = IX_sample;
            sample1.name = 'sample1';
            sample2 = IX_sample;
            sample2.name = 'sample2';
            samples = [sample1, sample2];
            
            expt = Experiment(IX_detector_array, instruments, samples);
            
            save(tmpfile, 'expt');
            clear('expt');
            
            load(tmpfile, 'expt');
            assertEqual(expt.samples(1).name, 'sample1')
            assertEqual(expt.samples(2).name, 'sample2')
            assertTrue(isa(expt.instruments(1), 'IX_inst_DGfermi'));
            assertTrue(isa(expt.instruments(2), 'IX_inst_DGdisk'));
            assertEqual(expt.detector_arrays, IX_detector_array);
        end

        function test_load_save_default_object_creates_default_object(self)  
            tmpfile = fullfile([tempdir(), 'test_experiment', 'loadsave_default.mat']);
            clobR=onCleanup(@()self.delete_files(tmpfile));
            
            expt = Experiment();
            
            save(tmpfile, 'expt');
            clear('expt');
            
            load(tmpfile, 'expt');
            assertEqual(expt.instruments, [])
            assertEqual(expt.samples, [])
            assertEqual(expt.detector_arrays, [])
        end
    end
end


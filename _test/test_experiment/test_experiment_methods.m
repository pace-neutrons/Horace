classdef test_experiment_methods < TestCase
    properties
        sample_exper;
    end

    methods
        function obj = test_experiment_methods(varargin)
            if nargin == 0
                name = 'test_experiment_methods';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            instruments = { IX_inst_DGfermi(), ...
                            IX_inst_DGdisk(),  ...
                            IX_inst_DGdisk()   };
            
            sample1 = IX_sample([1,2,3],[91,90,89]);
            sample1.name = 'sample1';
            sample2 = IX_sample([1.1,2.2,3.2],[90,91,92]);
            sample2.name = 'sample2';
            sample3  = IX_samp('sample3',[1.2,2.3,3.3],[89,92,91]);
            samples = {sample1,sample2,sample3};
            
            exp = repmat(IX_experiment,3,1);
            exp(1).run_id = 10;
            exp(1).filename = 'a1';
            exp(1).psi = 10;
            exp(1).angular_units = 'rad';            

            exp(2).run_id = 20;
            exp(2).filename = 'a2';
            exp(2).psi = 10;            
            exp(2).angular_units = 'rad';            

            exp(3).run_id = 30;
            exp(3).filename = 'a3';
            exp(3).psi = 10;            
            exp(3).angular_units = 'rad';                        
            
            detector = IX_detector_array();
            detector = repmat(detector,3,1);

            obj.sample_exper= Experiment(detector,instruments,samples,exp);
        end

        function test_samples_sets_keeps_lattice_with_no_lattice(obj)
            %
            exp = obj.sample_exper;

            sample = IX_sample();
            sample.name = 'ugly_sample';
            % Note that the 'GLOBAL_NAME_SAMPLES_CONTAINER' global container has NOT been cleared
            % here so this container refers to whatever is already in the
            % global container and so is also a test of keeping all
            % unique items of 'GLOBAL_NAME_SAMPLES_CONTAINER' regardless of where created.
            urc = unique_references_container('GLOBAL_NAME_SAMPLES_CONTAINER','IX_samp');
            urc = urc.add(sample);
            urc = urc.replicate_runs(3);
            clOwr =set_temporary_warning('off','HORACE:Experiment:lattice_changed');
            exp.samples = urc;

            ts = exp.samples(3);
            assertEqual(ts.alatt,[1.2,2.3,3.3]);
            assertEqual(ts.angdeg,[89,92,91]);
            assertEqual(ts.name,'ugly_sample');
        end

        function test_sample_sets_keeps_lattice_with_no_lattice(obj)
            %
            exp = obj.sample_exper;
            sample = IX_sample([2,3,4],[91,90,89]);
            sample.name = 'new_sample';

            exp.samples = sample;

            assertEqual(exp.samples(3),sample);

            sample = IX_sample();
            sample.name = 'ugly_sample';
            clOwr =set_temporary_warning('off','HORACE:Experiment:lattice_changed');
            exp.samples = sample;

            ts = exp.samples(3);
            assertEqual(ts.alatt,[2,3,4]);
            assertEqual(ts.angdeg,[91,90,89]);
            assertEqual(ts.name,'ugly_sample');
        end



        function test_single_sample_sets_up_array(obj)
            %
            exp = obj.sample_exper;
            sample = IX_sample([2,3,4],[91,90,89]);
            sample.name = 'new_sample';

            % this will turn the individual sample into 3 copies,
            % add to a unique_references_container, and the resulting
            % container will overwrite the old samples in exp
            exp.samples = sample;

            % test that there are still 3 samples in exp but they are now
            % identical copies of the inserted sample
            assertEqual(exp.samples.n_runs, 3);
            assertEqual(exp.samples(1),sample);
            assertEqual(exp.samples(2),sample);
            assertEqual(exp.samples(3),sample);
        end
        %
        function test_to_from_old_structure_nomangle(obj)
            exp = obj.sample_exper;
            exp.expdata(3).filename = 'ab';
            hdrs_cell = exp.convert_to_old_headers('-nomangle');

            assertEqual(hdrs_cell{1}.filename,'a1')

            reconstructed_exp = Experiment.build_from_binfile_headers(hdrs_cell);
            % here as the detectors weren't originally in the headers but in
            % a detpar in the parent sqw. As there is no parent sqw for
            % this test, the detectors are just reinserted.
            reconstructed_exp.detector_arrays = exp.detector_arrays;
            assertTrue(reconstructed_exp.runid_recalculated);
            assertTrue(isa(reconstructed_exp,'Experiment'));

            % runid_map is recalculated with runid-s from 1 to 3
            expd = exp.expdata;
            for i=1:3
                expd(i).run_id = i;
            end
            exp.expdata = expd;

            assertEqual(reconstructed_exp.expdata,exp.expdata);
            assertEqual(reconstructed_exp.runid_map.keys,exp.runid_map.keys);
            assertEqual(reconstructed_exp.runid_map.values,exp.runid_map.values);

            assertEqual(reconstructed_exp.samples,exp.samples);
            assertEqual(reconstructed_exp.instruments,exp.instruments);

        end
        function test_to_from_old_structure_single_head(obj)
            exp = obj.sample_exper;
            hdrs_cell = exp.convert_to_old_headers();

            assertEqual(hdrs_cell{2}.filename,'a2$id$20')

            hdrs_cell = hdrs_cell{2};
            rec_exp = Experiment.build_from_binfile_headers(hdrs_cell);
            assertFalse(rec_exp.runid_recalculated);
            assertTrue(isa(rec_exp,'Experiment'));
            assertEqual(rec_exp.n_runs, 1);

            assertEqual(rec_exp.expdata,exp.expdata(2));
            assertEqual(rec_exp.runid_map.keys,{20});
            assertEqual(rec_exp.runid_map.values,{1});
            
            assertEqual(rec_exp.detector_arrays.n_runs, 0);

            % properties are now recovered from old headers so we can 
            % compare reconstructed data for element 1 against 
            % the original element 2
            assertEqual(rec_exp.instruments{1},exp.instruments{2});
            assertEqual(rec_exp.samples{1},exp.samples{2});
            
            % note that detector detpars are not held in the headers so any
            % detectors in exp will not have been passed to rec_exp via
            % the reconstruction via hdrs_cell. To ensure that exp does
            % have the required detector_array data, do this test
            assertEqual(exp.detector_arrays.n_objects, 3);
            assertEqual(exp.detector_arrays.n_unique_objects, 1);
        end


        function test_to_from_old_structure(obj)
            exp = obj.sample_exper;
            hdrs_cell = exp.convert_to_old_headers();

            assertEqual(hdrs_cell{1}.filename,'a1$id$10')

            rec_exp = Experiment.build_from_binfile_headers(hdrs_cell);
            assertFalse(rec_exp.runid_recalculated);
            assertTrue(isa(rec_exp,'Experiment'));
            assertEqualToTol(rec_exp.expdata,exp.expdata);
            assertEqual(exp.runid_map.keys,rec_exp.runid_map.keys);
            assertEqual(exp.runid_map.values,rec_exp.runid_map.values);
            assertEqual(rec_exp.samples,exp.samples);

            % instruments are not recovered from old headers at all
            %exp.instruments = {IX_null_inst(),IX_null_inst(),IX_null_inst()};
            assertEqual(rec_exp.instruments,exp.instruments);
            
            %NB detectors are not stored in old headers and so
            %   have not been converted
        end
        function test_reset_runid_map_with_other_map(obj)
            exp = obj.sample_exper;
            exp.runid_map = containers.Map([20,30,40],[1,3,2]);

            assertEqual(exp.runid_map.keys,{20,30,40});
            assertEqual(exp.runid_map.values,{1,3,2});
            runid_s = exp.expdata.get_run_ids();
            assertEqual(runid_s,[20,40,30]);

        end

        function test_reset_runid_map_with_runid_array(obj)
            exp = obj.sample_exper;
            exp.runid_map = [20,30,40];

            assertEqual(exp.runid_map.keys, {20,30,40})
            assertEqual(exp.runid_map.values, {1,2,3});
            runid_s = exp.expdata.get_run_ids();
            assertEqual(runid_s,[20,30,40]);

        end
        %
        function test_get_subobj_by_runid_runid_recalculated(obj)
            exper = obj.sample_exper;
            assertFalse(exper.runid_recalculated);

            part = exper.get_subobj([2,3]);
            assertTrue(part.runid_recalculated);

            assertEqual(part.runid_map.keys,{2,3})
            assertEqual(part.runid_map.values,{1,2});

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGdisk'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            s1 = part.samples{1};
            s2 = part.samples{2};
            assertEqual(s1.name,'sample2')
            assertEqual(s2.name,'sample3')

            indo = part.expdata;
            assertEqual(indo(1).filename,'a2')
            assertEqual(indo(1).run_id,2)
            assertEqual(indo(2).filename,'a3')
            assertEqual(indo(2).run_id,3)

        end

        function test_get_subobj_by_runid_runid_kept(obj)
            exper = obj.sample_exper;
            inf = exper.expdata;
            run_id = [10,20,30];
            inf(1).run_id = run_id(2);
            inf(2).run_id = run_id(1);
            inf(3).run_id = run_id(3);
            exper.expdata = inf;
            %
            part = exper.get_subobj([20,30]);

            assertFalse(part.runid_recalculated);
            assertEqual(part.runid_map.keys,{20,30});
            assertEqual(part.runid_map.values,{1,2});

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGfermi'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            s1 = part.samples{1};
            s2 = part.samples{2};
            assertEqual(s1.name,'sample1')
            assertEqual(s2.name,'sample3')

            indo = part.expdata;
            assertEqual(indo(1).filename,'a1')
            assertEqual(indo(1).run_id,20)
            assertEqual(indo(2).filename,'a3')
            assertEqual(indo(2).run_id,30)
        end
        function test_get_subobj_by_runid_recalculated(obj)
            exper = obj.sample_exper;
            part = exper.get_subobj(2:3);
            assertTrue(part.runid_recalculated);

            assertEqual(part.runid_map.keys,{2,3})
            assertEqual(part.runid_map.values,{1,2})

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGdisk'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            s1 = part.samples{1};
            s2 = part.samples{2};
            assertEqual(s1.name,'sample2')
            assertEqual(s2.name,'sample3')

            assertEqual(part.expdata(1).filename,'a2')
            assertEqual(part.expdata(2).filename,'a3')
        end

        function test_get_subobj_by_ind(obj)
            exper = obj.sample_exper;
            part = exper.get_subobj(2:3,'-ind');
            assertFalse(part.runid_recalculated)

            assertEqual(part.runid_map.keys,{20,30})
            assertEqual(part.runid_map.values,{1,2})

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGdisk'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            s1 = part.samples{1};
            s2 = part.samples{2};
            assertEqual(s1.name,'sample2')
            assertEqual(s2.name,'sample3')

            assertEqual(part.expdata(1).filename,'a2')
            assertEqual(part.expdata(2).filename,'a3')
        end
        
        %-----------------------------------------------------------------------
        % Test get_experiment_idx
        %-----------------------------------------------------------------------
        
        function test_get_experiment_idx_fullLookup(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array of valid run_idx
            run_idx = [30,40,20,20,30];
            expt_idx = experiment.get_experiment_idx (run_idx);
            
            assertEqual(expt_idx, [3,2,1,1,3])
        end
        
        function test_get_experiment_idx_fullLookup_arrayRun_idx(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array of valid run_idx
            run_idx = [30,40,20; 20,30,40]; % 2x3 array
            sparse_lookup = false;
            expt_idx = experiment.get_experiment_idx (run_idx, sparse_lookup);
            
            assertEqual(expt_idx, [3,2,1; 1,3,2])
        end
        
        function test_get_experiment_idx_sparseLookup_arrayRun_idx(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array of valid run_idx
            run_idx = [30,40,20; 20,30,40]; % 2x3 array
            sparse_lookup = true;
            expt_idx = experiment.get_experiment_idx (run_idx, sparse_lookup);
            
            assertEqual(expt_idx, [3,2,1; 1,3,2])
        end
        
        function test_get_experiment_idx_fullLookup_emptyRun_idx(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array of valid run_idx
            run_idx = [];
            expt_idx = experiment.get_experiment_idx (run_idx);
            
            assertEqual(expt_idx, [])
        end
        
        function test_get_experiment_idx_fullLookup_outOfRangeRun_idx(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array with an invalid run_idx out of range
            run_idx = [30,20,50];   % 50 is out of range
            f = @() experiment.get_experiment_idx (run_idx);
            
            assertExceptionThrown(f, 'HORACE:Experiment:invalid_argument');
        end
        
        function test_get_experiment_idx_fullLookup_invalidRun_idx(obj)
            % Change to runid_map with non-ordered keys and values
            experiment = obj.sample_exper;
            experiment.runid_map = containers.Map([20,30,40],[1,3,2]);
            
            % Array with an invalid run_idx out of range
            run_idx = [30,25,20];   % 25 is not a valid key
            f = @() experiment.get_experiment_idx (run_idx);
            
            assertExceptionThrown(f, 'HORACE:Experiment:invalid_argument');
        end
        
    end
end


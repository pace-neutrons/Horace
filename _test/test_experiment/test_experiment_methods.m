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
            instruments = {IX_inst_DGfermi(), IX_inst_DGdisk(),IX_inst_DGdisk()};
            sample1 = IX_sample;
            sample1.name = 'sample1';
            sample2 = IX_sample;
            sample2.name = 'sample2';
            sample3  = IX_samp();
            sample3.name = 'sample3';
            samples = {sample1,sample2,sample3};
            exp = repmat(IX_experiment,3,1);
            exp(1).filename = 'a1';
            exp(2).filename = 'a2';
            exp(3).filename = 'a3';

            obj.sample_exper= Experiment(IX_detector_array,instruments,samples,exp);
        end
        function test_get_subobj_by_runid(obj)
            exper = obj.sample_exper;
            ind_map = containers.Map([10,20,30],[2,1,3]);
            [part,id_map] = exper.get_subobj([20,30],ind_map);

            assertEqual(id_map,containers.Map([20,30],[1,2]))            

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGfermi'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            assertEqual(part.samples{1}.name,'sample1')
            assertEqual(part.samples{2}.name,'sample3')

            assertEqual(part.expdata(1).filename,'a1')
            assertEqual(part.expdata(2).filename,'a3')

        end

        function test_get_subobj_by_ind(obj)
            exper = obj.sample_exper;
            [part,id_map] = exper.get_subobj(2:3);

            assertEqual(id_map,containers.Map([1,2],[1,2]))

            assertEqual(part.n_runs,2);
            assertTrue(isa(part.instruments{1},'IX_inst_DGdisk'));
            assertTrue(isa(part.instruments{2},'IX_inst_DGdisk'));

            assertEqual(part.samples{1}.name,'sample2')
            assertEqual(part.samples{2}.name,'sample3')

            assertEqual(part.expdata(1).filename,'a2')
            assertEqual(part.expdata(2).filename,'a3')

        end


    end
end


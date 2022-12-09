classdef test_data_block < TestCase
    properties
        sqw_obj_for_tests;
    end

    methods
        function obj = test_data_block(varargin)
            if nargin == 0
                name = varargin{1};
            else
                name = 'test_data_block';
            end
            obj = obj@TestCase(name);
            hc = horace_paths;
            en = -1:1:50;
            par_file = fullfile(hc.test_common,'gen_sqw_96dets.nxspe');            
            fsqw = dummy_sqw (en, par_file, '', 51, 1,[2.8,3.86,4.86], [120,80,90],...
                             [1,0,0],[0,1,0], 10, 1.,0.1, -0.1, 0.1, [50,50,50,50]);
            sample=IX_sample(true,[1,0,0],[0,1,0],'cuboid',[0.02,0.02,0.02]);
            fsqw = fsqw{1};
            sample.alatt = [4.2240 4.2240 4.2240];
            sample.angdeg = [90 90 90];            
            inst = maps_instrument(90,250,'s');
            fsqw.experiment_info.samples = sample;
            fsqw.experiment_info.instruments = inst;            
            obj.sqw_obj_for_tests = fsqw;
        end
        function test_get_set_proper_dnd_subobj_proj(obj)
            dp = data_block('data','proj');

            proj = ortho_proj([1,1,0],[1,-1,0]);
            dnd_mod = dp.set_subobj(obj.sqw_obj_for_tests.data,proj);
            assertEqual(dnd_mod.proj,proj);
        end        
        function test_get_set_proper_subobj_proj(obj)
            dp = data_block('data','proj');

            proj = ortho_proj([1,1,0],[1,-1,0]);
            sqw_mod = dp.set_subobj(obj.sqw_obj_for_tests.data,proj);

            assertEqual(sqw_mod.proj,proj);
        end        
        function test_get_set_proper_subobj_instr(obj)
            dp = data_block('experiment_info','instruments');

            inst = IX_null_inst();

            sqw_mod = dp.set_subobj(obj.sqw_obj_for_tests,inst);            

            assertEqual(sqw_mod.experiment_info.instruments(1),inst);
        end
        
        %------------------------------------------------------------------
        function test_get_proper_dnd_subobj_proj(obj)
            dp = data_block('data','proj');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests.data);
            assertEqual(obj.sqw_obj_for_tests.data.proj,subobj);
        end        
        function test_get_proper_subobj_proj(obj)
            dp = data_block('data','proj');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests);
            assertEqual(obj.sqw_obj_for_tests.data.proj,subobj);
        end        
        function test_get_proper_subobj_instr(obj)
            dp = data_block('experiment_info','instruments');

            subobj = dp.get_subobj(obj.sqw_obj_for_tests);
            assertEqual(obj.sqw_obj_for_tests.experiment_info.instruments,subobj);
        end

    end

end

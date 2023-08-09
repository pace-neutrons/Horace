classdef test_bash_operations < TestCase
    properties
        working_dir
    end
    methods
        
        function obj = test_bash_operations(name)
            if ~exist('name', 'var')
                name = 'test_bash_operations';
            end
            obj = obj@TestCase(name);
            obj.working_dir = tmp_dir;
        end
        function test_parse_bashrc_with_settings(obj)
            source_file = fullfile(fileparts(mfilename('fullpath')),'bash_profile_for_test');
            targ_file = fullfile(obj.working_dir,'bash_profile_for_test');
            
            [var_map,cont,var_pos] = extract_bash_exports(source_file);
            
            assertEqual(numel(cont),12);
            k1 = var_map.keys;
            k2 = var_pos.keys;
            assertEqual(k1,k2);
            
            assertEqual(var_map('MATLAB_PARALLEL_EXECUTOR'),'''matlab''')
            assertEqual(var_map('PARALLEL_WORKER'),'''worker_v4''')
            assertEqual(var_map('WORKER_CONTROL_STRING'),'''''')
            
            pos_val = var_pos.values;
            assertEqual([9,10,11],[pos_val{:}]);
            
            var_map('MATLAB_PARALLEL_EXECUTOR') = 'my_runner';
            var_map('PARALLEL_WORKER') = 'my_worker';
            var_map('WORKER_CONTROL_STRING') = 'my_control';
            cont = modify_contents(cont,var_pos,var_map);
            
            assertEqual(cont{9},'export MATLAB_PARALLEL_EXECUTOR=''my_runner''')
            assertEqual(cont{10},'export PARALLEL_WORKER=''my_worker''')
            assertEqual(cont{11},'export WORKER_CONTROL_STRING=''my_control''')
            
            clob = onCleanup(@()delete(targ_file));
            fh = fopen(targ_file,'w');
            assertTrue(fh>1)
            for i=1:numel(cont)
                fprintf(fh,'%s\n',cont{i});
            end
            fclose(fh);
            
            [new_map,new_cont] = extract_bash_exports(targ_file);
            
            assertEqual(new_map.keys,var_map.keys);
            assertEqual(new_cont,cont);            
        end
        %
        function test_modify_contents(~)
            cont= {'a','b','c'};
            var_map = containers.Map();
            var_map('MATLAB_PARALLEL_EXECUTOR') = 'my_runner';
            var_map('PARALLEL_WORKER') = 'my_worker';
            var_map('WORKER_CONTROL_STRING') = 'my_control';
            cont = modify_contents(cont,[],var_map);
            
            assertEqual(cont{4},'export MATLAB_PARALLEL_EXECUTOR=''my_runner''')
            assertEqual(cont{5},'export PARALLEL_WORKER=''my_worker''')
            assertEqual(cont{6},'export WORKER_CONTROL_STRING=''my_control''')
            
            assertEqual(numel(cont),7)
        end        
    end
end

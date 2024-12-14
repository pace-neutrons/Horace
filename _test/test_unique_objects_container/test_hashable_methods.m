classdef test_hashable_methods <  TestCase
    %Test class to test IX_experiment constructor and methods
    %

    properties
    end

    methods
        function obj=test_hashable_methods(varargin)
            if nargin == 0
                name = 'test_hashable_methods';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %==================================================================
        function test_exposing_hash_array(~)
            data = test_hashable_methods.build_IX_array(10);
            [data,hashes,is_new] = build_hash(data);
            assertTrue(iscell(hashes))
            assertTrue(is_new);


            hash_defined = arrayfun(@(x)~isempty(x.hash_value),data);
            assertTrue(all(hash_defined));

            S = data.to_struct();

            assertTrue(isfield(S,'hash_value'));
            assertTrue(isa(S.hash_value,'cell'));

            is_empty = cellfun(@(x)isempty(x),S.hash_value);
            assertFalse(any(is_empty));

            rec_data = hashable.from_struct(S);

            assertEqual(data,rec_data);
            hash_defined = arrayfun(@(x)~isempty(x.hash_value),rec_data);
            assertTrue(all(hash_defined));
        end
        function test_exposing_hash_value(~)
            data = test_hashable_methods.build_IX_array(1);
            [data,hash,is_new] = build_hash(data);
            assertTrue(ischar(hash))
            assertTrue(is_new);


            hash_defined = arrayfun(@(x)~isempty(x.hash_value),data);
            assertTrue(all(hash_defined));

            S = data.to_struct();

            assertTrue(isfield(S,'hash_value'));
            assertTrue(isa(S.hash_value,'cell'));

            is_empty = cellfun(@(x)isempty(x),S.hash_value);
            assertFalse(any(is_empty));

            rec_data = hashable.from_struct(S);

            assertEqual(data,rec_data);
            hash_defined = arrayfun(@(x)~isempty(x.hash_value),rec_data);
            assertTrue(all(hash_defined));

        end

        function test_exposing_empty_hash_array(~)
            data = test_hashable_methods.build_IX_array(10);

            hash_defined = arrayfun(@(x)~isempty(x.hash_value),data);
            assertFalse(any(hash_defined));

            S = data.to_struct();

            assertTrue(isfield(S,'hash_value'));
            assertTrue(isa(S.hash_value,'cell'));

            is_empty = cellfun(@(x)isempty(x),S.hash_value);
            assertTrue(all(is_empty));

            rec_data = hashable.from_struct(S);

            assertEqual(data,rec_data);
        end
        function test_exposing_empty_hash_value(~)
            data = test_hashable_methods.build_IX_array(1);

            hash_defined = arrayfun(@(x)~isempty(x.hash_value),data);
            assertFalse(any(hash_defined));

            S = data.to_struct();

            assertTrue(isfield(S,'hash_value'));
            assertTrue(isa(S.hash_value,'cell'));

            is_empty = cellfun(@(x)isempty(x),S.hash_value);
            assertTrue(all(is_empty));

            rec_data = hashable.from_struct(S);

            assertEqual(data,rec_data);
        end
    end
    methods(Static,Access=private)
        function [data,run_id] = build_IX_array(n_elements)
            par_names={...
                'filename', 'run_id', 'efix','en',...
                'psi','omega','dpsi','gl','gs'};
            par_val = {'my_file',6666,10,[1,2,4,8]',70,5,5,5,5};
            data = repmat(IX_experiment,1,n_elements);
            for i=1:n_elements
                expd = data(i);
                expd.do_check_combo_arg = false;
                for j=1:numel(par_names)
                    if ischar(par_val{j})
                        val = build_tmp_file_name('nxspe_file','');
                    elseif numel(par_val{j})>1
                        expd.efix = expd.efix+5;
                        val = sort(rand(size(par_val{j}))*expd.efix);
                    else
                        val = round(rand()*par_val{j});
                    end

                    expd.(par_names{j}) = val;
                end
                expd.filepath = 'some_file_path';
                expd.emode = 1;
                expd.do_check_combo_arg = true;
                data(i) = expd.check_combo_arg();
            end
            % ensure run_id are unique to avoid random tests failures
            run_id = arrayfun(@(x)x.run_id,data);
            uniq_id = unique(run_id);
            was_nonunique = false;
            while numel(uniq_id) ~= numel(run_id)
                was_nonunique = true;
                run_id  = round(rand(1,n_elements)*par_val{2});
                uniq_id = unique(run_id);
            end
            if was_nonunique
                for i=1:n_elements
                    data(i).run_id = run_id(i);
                end
            end
        end
    end
end

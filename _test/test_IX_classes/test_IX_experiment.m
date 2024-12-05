classdef test_IX_experiment <  TestCase
    %Test class to test IX_experiment constructor and methods
    %

    properties
    end

    methods
        function obj=test_IX_experiment(varargin)
            if nargin == 0
                name = 'test_IX_experiment';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_combine_multirun_with_changing_ID_works(~)
            [Input,fids] = test_IX_experiment.build_IX_array_blocks(10,3);

            [result,file_id_array,skipped_inputs,this_runid_map] = Input{1}.combine(Input(2:end),true,false);

            assertEqual([Input{:}],result);
            assertEqual(file_id_array,fids);
            assertTrue(iscell(skipped_inputs))
            skipped_inputs = [skipped_inputs{:}];
            assertEqual(numel(skipped_inputs),9);
            assertTrue(all(~skipped_inputs)); % nothing skipped

            keys = this_runid_map.keys();
            for i=1:numel(keys)
                id = this_runid_map(keys{i});
                assertEqual(result(id).run_id,keys{i});
            end
        end
        
        function test_combine_multirun_works(~)
            [Input,fids] = test_IX_experiment.build_IX_array_blocks(10,3);

            [result,file_id_array,skipped_inputs,this_runid_map] = Input{1}.combine(Input(2:end));

            cai = [Input{:}];
            assertEqual(cai,result);
            assertEqual(file_id_array,fids);
            assertTrue(iscell(skipped_inputs))
            assertEqual(numel(skipped_inputs),2);            
            skipped_inputs = [skipped_inputs{:}];
            assertEqual(numel(skipped_inputs),20);
            assertTrue(all(~skipped_inputs)); % nothing skipped

            keys = this_runid_map.keys();
            for i=1:numel(keys)
                id = this_runid_map(keys{i});
                assertEqual(result(id).run_id,keys{i});
            end
        end

        function test_combine_single_runs_eq_headers_works(~)
            [data,fids] = test_IX_experiment.build_IX_array(10);
            data(2) = data(7);
            fids(2) = data(7).run_id;
            Input = num2cell(data);

            [result,file_id_array,skipped_inputs,this_runid_map] = Input{1}.combine(Input(2:end),true,true);

            assertEqual([data(1:6),data(8:10)],result);
            assertEqual(file_id_array,fids);
            assertTrue(iscell(skipped_inputs))
            skipped_inputs = [skipped_inputs{:}];
            assertEqual(numel(skipped_inputs),9);
            assertTrue(skipped_inputs(6)); % 7th skipped
            assertFalse(all(skipped_inputs(1:5))); % left itact
            assertFalse(all(skipped_inputs(7:9))); % left itact

            keys = this_runid_map.keys();
            for i=1:numel(keys)
                id = this_runid_map(keys{i});
                assertEqual(result(id).run_id,keys{i});
            end
        end

        function test_combine_single_runs_throws_on_emode(~)
            data = test_IX_experiment.build_IX_array(10);
            data(2).emode = 2;
            Input = num2cell(data);
            assertExceptionThrown(@()combine(Input{1},Input(2:end)), ...
                'HORACE:IX_experiment:not_implemented');
        end

        function test_combine_single_runs_throws_on_same(~)
            data = test_IX_experiment.build_IX_array(10);
            data(2) = data(7);
            Input = num2cell(data);
            assertExceptionThrown(@()combine(Input{1},Input(2:end)), ...
                'HORACE:IX_experiment:invalid_argument');
        end
        function test_combine_single_runs_works(~)
            [data,fids] = test_IX_experiment.build_IX_array(10);
            Input = num2cell(data);

            [result,file_id_array,skipped_inputs,this_runid_map] = Input{1}.combine(Input(2:end));

            assertEqual(data,result);
            assertEqual(file_id_array,fids);
            assertTrue(iscell(skipped_inputs))
            skipped_inputs = [skipped_inputs{:}];
            assertEqual(numel(skipped_inputs),9);
            assertTrue(all(~skipped_inputs)); % nothing skipped

            keys = this_runid_map.keys();
            for i=1:numel(keys)
                id = this_runid_map(keys{i});
                assertEqual(result(id).run_id,keys{i});
            end
        end
        %------------------------------------------------------------------
        function test_comparison_hash_neq(~)
            exp1 = IX_experiment('my_file','my_path',1,20,1,'psi',10);
            exp2 = exp1;
            exp2.omega = 4;

            ch1 = exp1.get_neq_hash();
            ch2 = exp2.get_neq_hash();
            assertFalse(isequal(ch1,ch2));
        end
        function test_goniometer_key_construction(~)
            gon = Goniometer(10,[0,1,0],[1,0,0]);

            exp1 = IX_experiment('my_file','my_path',666,10,1,1:9, ...
                'goniometer',gon);

            assertEqual(exp1.psi,10)
            assertEqual(exp1.filename,'my_file')
            assertEqual(exp1.cu,[0,1,0])
            assertEqual(exp1.cv,[1,0,0])
            % in all practical cases offset here is 0. Leave offset field
            % but do not use it for all practical purposes
            assertEqual(exp1.uoffset,[0,0,0,0])
        end

        function test_goniometer_construction(~)
            gon = Goniometer(10,[0,1,0],[1,0,0]);
            exp1 = IX_experiment('my_file','my_path',666,10,1,1:9,gon);

            assertEqual(exp1.psi,10)
            assertEqual(exp1.filename,'my_file')
            assertEqual(exp1.cu,[0,1,0])
            assertEqual(exp1.cv,[1,0,0])
        end

        function test_comparison_hash_eq(~)
            exp1 = IX_experiment('my_file','my_path',1,20,1,'psi',10);
            exp2 = exp1;
            exp2.filepath = 'other_path';

            ch1 = exp1.get_neq_hash();
            ch2 = exp2.get_neq_hash();
            assertEqual(ch1,ch2);
        end

        function test_convert_to_and_from_old_binfile_headers(~)
            exp = IX_experiment();
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp.run_id = 10;
            exp.en = 1:10;
            exp.psi = 10;


            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);
            oh.filename = 'aa';

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            exp.run_id = NaN;
            % old headers are stored in radians
            exp.angular_units = 'rad';
            assertEqual(exp,exp_rec);
        end
        function test_get_runids(~)
            exp = [IX_experiment(),IX_experiment()];
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp(1).run_id = 10;
            exp(2).filename = 'bb';
            exp(2).filepath = 'de';
            exp(2).run_id = 20;

            ids = exp.get_run_ids();
            assertEqual(ids,[10,20]);

        end

        function test_convert_to_and_from_binfile_headers_empty_fn(~)
            exp = IX_experiment();
            exp(1).filename = '';
            exp(1).filepath = 'bc';
            exp.run_id = 10;
            exp.en = 1:10;
            exp.psi = 10;

            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            % old headers are stored in radians
            exp.angular_units = 'rad';

            assertEqual(exp,exp_rec);
        end


        function test_convert_to_and_from_binfile_headers(~)
            exp = IX_experiment();
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp.run_id = 10;
            exp.en = 1:10;
            exp.psi = 10;

            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            % old headers are stored in radians
            exp.angular_units = 'rad';
            assertEqual(exp,exp_rec);

        end

        function test_recover_from_v1_structure_array(~)
            exp = [IX_experiment(),IX_experiment()];
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp(2).filename = 'bb';
            exp(2).filepath = 'de';


            v1_struct = exp.to_struct(); % this is v2 structure
            % prepare v1 structure, not to bother with the file storage
            v1_struct.version = 1;
            v1_struct.array_dat = rmfield(v1_struct.array_dat,'run_id');

            exp_rec = serializable.from_struct(v1_struct);
            % old IX_experiment structures in all practical cases were storing
            % angular units in radian, so we restoring old versions as
            % radians
            for i=1:numel(exp)
                exp(i).angular_is_degree = false;
            end

            assertEqual(exp,exp_rec);
        end

        function test_recover_from_v1_structure_single(~)
            exp = IX_experiment();
            exp.filename = 'aa';
            exp.filepath = 'bc';

            v1_struct = exp.to_struct(); % this is v2 structure
            % prepare v1 structure, not to bother with the file storage
            v1_struct.version = 1;
            v1_struct = rmfield(v1_struct,'run_id');

            exp_rec = serializable.from_struct(v1_struct);

            % old IX_experiment structures in all practical cases were storing
            % angular units in radian, so we restoring old versions in
            % radians
            exp.angular_is_degree = false;


            assertEqual(exp,exp_rec);
        end

        function test_set_invalid_runid_throws(~)
            exp = IX_experiment();
            function setter(obj,val)
                obj.run_id = val;
            end

            assertExceptionThrown(@()setter(exp,'a'),...
                'HERBERT:IX_experiment:invalid_argument');

            assertExceptionThrown(@()setter(exp,[1,2]),...
                'HERBERT:IX_experiment:invalid_argument');
        end

        function test_set_get_single_runid(~)
            exp = IX_experiment();
            assertTrue(isnan(exp.run_id))
            exp.run_id = 10;
            assertEqual(exp.run_id,10);

            exp.run_id = NaN;
            assertTrue(isnan(exp.run_id))
        end

        function test_full_construnctor(~)
            par_names={'filename', 'filepath','run_id', 'efix','emode','en','psi','cu',...
                'cv','omega','dpsi','gl','gs','angular_units'};
            par_val = {'my_file','my_name',666,10,1,[1,2,4,8]',10,[1,0,0],[0,1,0],...
                1,2,3,4,'rad'};
            angular_val = {'psi','omega','dpsi','gl','gs'};
            % For debugging: Construction fields are defined as u,v
            %exp0 = IX_experiment();
            %assertEqual(par_names',exp0.constructionFields());
            pv_map = containers.Map(par_names,par_val);

            exp = IX_experiment(par_val{:});

            fn = exp.constructionFields();
            for i=1:numel(fn)
                prop_name = fn{i};
                if ismember(prop_name,angular_val)
                    expected_val = deg2rad(pv_map(prop_name));
                else
                    if strcmp(prop_name,'v')
                        expected_val = pv_map('cv');
                    elseif strcmp(prop_name,'u')
                        expected_val = pv_map('cu');
                    else
                        expected_val = pv_map(prop_name);
                    end
                end
                assertEqual(exp.(prop_name),expected_val, ...
                    sprintf('invalid value "%s" for field "%s"', ...
                    disp2str(exp.(prop_name)),fn{i}));
            end
        end
    end
    methods(Static,Access=private)
        function [data,run_id] = build_IX_array_blocks(n_elements,n_blocks)
            data = cell(n_blocks,1);
            ids  = cell(n_blocks,1);
            for i=1:n_blocks
                [data{i},ids{i}]=test_IX_experiment.build_IX_array(n_elements);
            end
            run_id = [ids{:}];
        end
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

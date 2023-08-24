classdef test_IX_experiment <  TestCase
    %Test class to test IX_experiment constructor and methods
    %

    properties
    end

    methods
        function this=test_IX_experiment(varargin)
            if nargin == 0
                name = 'test_IX_experiment';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_comparison_hash_neq(~)
            exp1 = IX_experiment('my_file','my_path',1,20,1,'psi',10);
            exp2 = exp1;
            exp2.omega = 4;

            ch1 = exp1.get_neq_hash();
            ch2 = exp2.get_neq_hash();
            assertFalse(isequal(ch1,ch2));
        end
        function test_goniometer_key_construction(~)
            gon = goniometer(10,[0,1,0],[1,0,0]);

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
            gon = goniometer(10,[0,1,0],[1,0,0]);
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
end

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

        function test_convert_to_and_from_old_binfile_headers(~)
            exp = IX_experiment();
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp.run_id = 10;
            exp.en = 1:10;

            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);
            oh.filename = 'aa';

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            exp.run_id = NaN;
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

            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            assertEqual(exp,exp_rec);

            % TODO: temporary, until IX_experiment is propertly build class
            clOb = set_temporary_warning('off','MATLAB:structOnObject');
            assertEqual(struct(exp),struct(exp_rec));
        end


        function test_convert_to_and_from_binfile_headers(~)
            exp = IX_experiment();
            exp(1).filename = 'aa';
            exp(1).filepath = 'bc';
            exp.run_id = 10;
            exp.en = 1:10;

            oh = exp.convert_to_binfile_header('-alatt_angdeg',[1,2,3],[90,90,90]);

            [exp_rec,alatt,angdeg] = IX_experiment.build_from_binfile_header(oh);

            assertEqual(alatt,[1,2,3]);
            assertEqual(angdeg,[90,90,90]);
            assertEqual(exp,exp_rec);


            % TODO: temporary, until IX_experiment is propertly build class
            clOb = set_temporary_warning('off','MATLAB:structOnObject');
            assertEqual(struct(exp),struct(exp_rec));
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
            par_names={'filename', 'filepath', 'efix','emode','cu',...
                'cv','psi','omega','dpsi','gl','gs','en','uoffset',...
                'u_to_rlu','ulen','ulabel','run_id'};
            par_val = {'my_file','my_name',10,1,[1,0,0],[0,1,0],...
                10,1,2,3,4,[1,2,4,8]',[0,0,0,0],eye(4),ones(4,1),...
                {'a','b','c','d'},100};

            pv_map = containers.Map(par_names,par_val);

            exp = IX_experiment(par_val{:});

            fn = exp.saveableFields();
            for i=1:numel(fn)
                assertEqual(exp.(fn{i}),pv_map(fn{i}), ...
                    sprintf('invalid field "%s" value',fn{i}));
            end
        end
    end
end

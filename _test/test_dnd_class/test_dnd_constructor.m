classdef test_dnd_constructor < TestCaseWithSave

    properties (Constant)
        DND_FILE_2D_NAME = 'dnd_2d.sqw';
        SQW_FILE_1D_NAME = 'sqw_1d_1.sqw';
        SQW_FILE_2D_NAME = 'sqw_2d_1.sqw';
        SQW_FILE_4D_NAME = 'sqw_4d.sqw';

    end

    properties
        test_dnd_2d_fullpath = '';
        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';

        test_data
        common_data;
    end

    methods(Static)
    end

    methods

        function obj = test_dnd_constructor(varargin)
            if nargin == 0
                argi = {'test_dnd_constructor'};
            else
                argi = {varargin{1},'test_dnd_constructor'};
            end

            obj = obj@TestCaseWithSave(argi{:});
            hp = horace_paths();
            obj.common_data = hp.test_common;
            obj.test_data=fullfile(hp.test,'test_combine');

            obj.test_sqw_1d_fullpath = fullfile(obj.common_data, obj.SQW_FILE_1D_NAME);
            obj.test_sqw_2d_fullpath = fullfile(obj.common_data, obj.SQW_FILE_2D_NAME);
            obj.test_sqw_4d_fullpath = fullfile(obj.common_data, obj.SQW_FILE_4D_NAME);

            obj.test_dnd_2d_fullpath = fullfile(obj.common_data, obj.DND_FILE_2D_NAME);
        end
        function obj = test_dnd_from_sqw_array(obj)
            % generate test data
            par_file = fullfile(obj.common_data,'96dets.par');
            S=ones(10,96);
            ERR=ones(10,96);
            en = 0:2:20;
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj1 = rd.calc_sqw([]);
            S=2*ones(10,96);
            ERR=2*ones(10,96);
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj2 = rd.calc_sqw([]);
            sqw_obj = [sqw_obj1,sqw_obj2];

            % check dnd array conversion
            dnd_obj = dnd(sqw_obj);
            assertEqual(size(sqw_obj),size(dnd_obj));
            assertEqual(sqw_obj(1).data.s,dnd_obj(1).s);
            assertEqual(sqw_obj(1).data.e,dnd_obj(1).e);
            assertEqual(sqw_obj(2).data.s,dnd_obj(2).s);
            assertEqual(sqw_obj(2).data.e,dnd_obj(2).e);

            % check d4d array conversion
            dnd_obj = d4d(sqw_obj);
            assertEqual(size(sqw_obj),size(dnd_obj));
            assertEqual(sqw_obj(1).data.s,dnd_obj(1).s);
            assertEqual(sqw_obj(1).data.e,dnd_obj(1).e);
            assertEqual(sqw_obj(2).data.s,dnd_obj(2).s);
            assertEqual(sqw_obj(2).data.e,dnd_obj(2).e);

            % check d4d->d2d conversion fails
            f = @()d2d(sqw_obj);
            assertExceptionThrown(f,'HORACE:d2d:invalid_argument');
        end

        function test_read_array_from_multifiles(obj)
            file = fullfile(obj.test_data,'w2d_qq_d2d.sqw');
            t2 = read_dnd({file,file});
            assertTrue(isa(t2,'d2d'))
            assertEqual(size(t2),[1,2]);
        end

        function this = test_dnd_from_sqw(this)
            par_file = fullfile(this.common_data,'96dets.par');
            S=ones(10,96);
            ERR=ones(10,96);
            en = 0:2:20;
            rd = gen_nxspe(S,ERR,en,par_file,'',20,1,2);
            sqw_obj = rd.calc_sqw([]);

            dnd_obj = dnd(sqw_obj);
            assertEqual(sqw_obj.data.s,dnd_obj.s);
            assertEqual(sqw_obj.data.e,dnd_obj.e);
        end


        function test_arg_constructor_from_file(obj)
            % TODO: This does not work any more. Should we recover this
            % constructor? #824
            %
            %Create empty object suitable for simulations:
            %  >> w = d2d (proj, p1_bin, p2_bin, p3_bin, p4_bin)
            %  >> w = d2d (lattice, proj,...)
            %
            %**Or** (old syntax, still available for legacy purposes)
            %  >> w = d2d (u1,p1,u2,p2)    % u1,u2 vectors define projection axes in rlu,
            %                                p1,p2 give start,step and finish for the axes
            %  >> w = d2d (u0,...)         % u0 is offset of origin of dataset,
            %  >> w = d2d (lattice,...)    % Give lattice parameters [a,b,c,alf,bet,gam]
            %  >> w = d2d (lattice,u0,...) % Give u0 and lattice parameters


            t2 = read_dnd(fullfile(obj.test_data,'w2d_qq_d2d.sqw'));
            assertTrue(isa(t2,'d2d'))
        end
        function test_arg_constructor_from_ax_and_proj(~)
            ax = axes_block([-2,0.05,2],[-2,0.05,2],[0,1],[0,1]);
            proj = ortho_proj('alatt',3.2,'offset',[0,1,1,0],'u',[1,0,0],'v',[0,1,0]);
            t2 = d2d(ax,proj,zeros(81,81),zeros(81,81),ones(81,81));
            assertTrue(isa(t2,'d2d'))
            assertEqual(t2.offset,[0,1,1,0]);
        end


        %% Copy
        function test_copy_constructor_clones_d2d_object(obj)
            dnd_obj = read_dnd(obj.test_dnd_2d_fullpath);
            dnd_copy = d2d(dnd_obj);

            assertTrue(isa(dnd_obj, 'd2d'));
            assertEqualToTol(dnd_copy, dnd_obj);
        end

        function test_copy_constructor_clones_d4d_object(~)
            dnd_obj = d4d();
            dnd_copy = d4d(dnd_obj);

            assertTrue(isa(dnd_obj, 'd4d'));
            assertEqualToTol(dnd_copy, dnd_obj);
        end

        function assert_constructor_returns_distinct_object(obj)
            dnd_obj = read_dnd(obj.test_dnd_2d_fullpath);
            dnd_copy = d2d(dnd_obj);

            dnd_copy.angdeg = [1, 25, 80];
            dnd_copy.title = 'test string';
            dnd_copy.s = ones(10);

            % changed data is not mirrored in initial
            assertFalse(equal_to_tol(dnd_copy.angdeg, dnd_obj.angdeg));
            assertFalse(equal_to_tol(dnd_copy.title, dnd_obj.title));
            assertFalse(equal_to_tol(dnd_copy.s , dnd_obj.s));

            assertFalse(equal_to_tol(dnd_copy, dnd_obj));
        end

        %% Filename
        function test_filename_constructor_returns_populated_class_from_dnd_file(obj)
            d2d_obj = read_dnd(obj.test_dnd_2d_fullpath);

            expected_ulen = [2.101896, 1.486265, 2.101896, 1.0000];
            expected_u_to_rlu = [1, 0, 1, 0; 1, 0, -1, 0; 0, 1, 0, 0; 0, 0, 0, 1];

            % expected data populated from instance of test object
            assertTrue(isa(d2d_obj, 'd2d'));
            assertEqual(d2d_obj.dax, [1, 2]);
            assertEqual(d2d_obj.iax, [3, 4]);
            assertEqual(size(d2d_obj.s), [16, 11]);
            assertEqualToTol(d2d_obj.axes.ulen, expected_ulen, 'tol', 1e-5);
            assertEqual(d2d_obj.proj.u_to_rlu, expected_u_to_rlu, 'tol', 1e-5);
        end

        function test_filename_constructor_returns_populated_class_from_sqw_file(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            expected_ulen = [2.101896, 1.486265, 2.101896, 1.0000];
            expected_u_to_rlu = [1, 0, 1, 0; 1, 0, -1, 0; 0, 1, 0, 0; 0, 0, 0, 1];

            % expected data populated from instance of test object
            assertTrue(isa(d2d_obj, 'd2d'));
            assertEqual(d2d_obj.dax, [1, 2]);
            assertEqual(d2d_obj.iax, [3, 4]);
            assertEqual(size(d2d_obj.s), [16, 11]);
            assertEqualToTol(d2d_obj.axes.ulen, expected_ulen, 'tol', 1e-5);
            assertEqual(d2d_obj.proj.u_to_rlu, expected_u_to_rlu, 'tol', 1e-5);
        end

        function test_fname_constr_returns_same_obj_as_sqw_constr_from_sqw_file(obj)
            sqw_obj = read_sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);

            d2d_from_sqw = d2d(sqw_obj);

            assertEqualToTol(d2d_from_sqw, d2d_obj,'ignore_str',true);
        end


        %% SQW and dimensions checks
        function test_d2d_sqw_constuctor_raises_error_from_1d_sqw_object(obj)
            sqw_obj = read_sqw(obj.test_sqw_1d_fullpath);
            f = @() d2d(sqw_obj);

            assertExceptionThrown(f, 'HORACE:d2d:invalid_argument');
        end

        function test_d1d_sqw_constuctor_creates_d1d_from_1d_sqw_object(obj)
            sqw_obj = read_sqw(obj.test_sqw_1d_fullpath);
            d1d_obj = d1d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d1d_obj);
        end

        function test_save_load_d2d(obj)
            sqw_obj = read_sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = d2d(sqw_obj);

            wkdir = tmp_dir();
            wk_file = fullfile(wkdir,'test_save_load_d2d.mat');
            clOb = onCleanup(@()delete(wk_file));
            save(wk_file,'d2d_obj');
            ld = load(wk_file);
            assertEqual(ld.d2d_obj,d2d_obj);
        end


        function test_d2d_sqw_constuctor_creates_d2d_from_2d_sqw_object(obj)
            sqw_obj = read_sqw(obj.test_sqw_2d_fullpath);
            d2d_obj = d2d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d2d_obj);
        end

        function test_d4d_sqw_constuctor_creates_d4d_from_4d_sqw_object(obj)
            sqw_obj = read_sqw(obj.test_sqw_4d_fullpath);
            d4d_obj = d4d(sqw_obj);

            obj.assert_dnd_sqw_constructor_creates_dnd_from_sqw(sqw_obj, d4d_obj);
        end

        function assert_dnd_sqw_constructor_creates_dnd_from_sqw(~, sqw_obj, dnd_obj)
            assertEqual(sqw_obj.data.s, dnd_obj.s);
            assertEqual(sqw_obj.data.e, dnd_obj.e);
            assertEqual(sqw_obj.data.p, dnd_obj.p);
            assertEqual(sqw_obj.data.npix, dnd_obj.npix)
            assertEqual(sqw_obj.data.label, dnd_obj.label);
        end
        %-------------------------------------------------------------------
        % Non-empty constructor
        function test_d0d_generator(~)
            input = {axes_block([0,1],[0,1],[0,1],[0,2]),ortho_proj(),...
                1,1,1};
            dnd_obj = DnDBase.dnd(input{:});
            assertTrue(isa(dnd_obj,'d0d'));

        end

        function test_d1d_generator(~)
            input = {axes_block([0,1],[0,1],[0,1],[0,0.2,2]),ortho_proj(),...
                ones(11,1),ones(11,1),ones(11,1)};
            dnd_obj = DnDBase.dnd(input{:});
            assertTrue(isa(dnd_obj,'d1d'));

        end

        function test_d2d_generator(~)
            input = {axes_block([0,0.1,1],[0,1],[0,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11),ones(11,11),ones(11,11)};
            dnd_obj = DnDBase.dnd(input{:});
            assertTrue(isa(dnd_obj,'d2d'));

        end

        function test_d3d_generator(~)
            input = {axes_block([0,0.1,1],[0,0.1,1],[0,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11,11),ones(11,11,11),ones(11,11,11)};
            dnd_obj = DnDBase.dnd(input{:});
            assertTrue(isa(dnd_obj,'d3d'));

        end

        function test_d4d_generator(~)
            input = {axes_block([0,0.1,1],[0,0.1,1],[0,0.1,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11,11,11),ones(11,11,11,11),ones(11,11,11,11)};
            dnd_obj = DnDBase.dnd(input{:});
            assertTrue(isa(dnd_obj,'d4d'));

        end
        function test_d4d_non_empty(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,0.1,1],[0,0.1,1],[0,0.1,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11,11,11),ones(11,11,11,11),ones(11,11,11,11)};
            assertExceptionThrown(@()d1d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d0d(input{:}),'MATLAB:class:mustReturnObject');
            obj = d4d(input{:});

            assertTrue(isa(obj,'d4d'));
        end

        function test_d3d_non_empty(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,0.1,1],[0,1],[0,0.1,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11,11),ones(11,11,11),ones(11,11,11)};
            assertExceptionThrown(@()d1d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d0d(input{:}),'MATLAB:class:mustReturnObject');
            assertExceptionThrown(@()d4d(input{:}),'HORACE:DnDBase:invalid_argument');
            obj = d3d(input{:});

            assertTrue(isa(obj,'d3d'));
        end
        function test_d2d_ax_and_projy(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,1],[0,1],[0,0.1,1],[0,0.2,2]),ortho_proj(),...
                };
            assertExceptionThrown(@()d1d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d0d(input{:}),'MATLAB:class:mustReturnObject');
            assertExceptionThrown(@()d3d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d4d(input{:}),'HORACE:DnDBase:invalid_argument');
            obj = d2d(input{:});

            assertTrue(isa(obj,'d2d'));
        end


        function test_d2d_non_empty(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,1],[0,1],[0,0.1,1],[0,0.2,2]),ortho_proj(),...
                ones(11,11),ones(11,11),ones(11,11)};
            assertExceptionThrown(@()d1d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d0d(input{:}),'MATLAB:class:mustReturnObject');
            assertExceptionThrown(@()d3d(input{:}),'HORACE:DnDBase:invalid_argument');
            assertExceptionThrown(@()d4d(input{:}),'HORACE:DnDBase:invalid_argument');
            obj = d2d(input{:});

            assertTrue(isa(obj,'d2d'));
        end
        function test_d1d_data_wrong_constructor_throws(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,1],[0,1],[0,0.1,1],[0,2]),ortho_proj(),...
                ones(1,11),ones(1,11),ones(1,11)};
            assertExceptionThrown(@()d2d(input{:}),'HORACE:DnDBase:invalid_argument');

        end

        function test_d1d_non_empty_constructor_works(~)
            %axis, proj, s,e,npix
            input = {axes_block([0,1],[0,1],[0,0.1,1],[0,2]),ortho_proj(),...
                ones(1,11),ones(1,11),ones(1,11)};

            obj = d1d(input{:});

            assertTrue(isa(obj,'d1d'));
            input{1}.label = {'\zeta'  '\xi'  '\eta'  'E'};
            assertEqual(obj.axes,input{1});
            assertEqual(obj.proj,input{2});
            assertEqual(obj.s,input{3}');
            assertEqual(obj.npix,input{5}');
        end

        function test_d0d_non_empty(~)
            % s,e,npix,axis, proj;
            input = {axes_block(0),ortho_proj(),1,1,1};
            obj = d0d(input{:});

            assertTrue(isa(obj,'d0d'));
        end
        %-------------------------------------------------------------------
        %% Dimension
        function test_d0d_constructor_returns_zero_d_instance(~)
            dnd_obj = d0d();

            assertEqual(numel(dnd_obj.pax), 0);
            assertEqual(dnd_obj.dimensions(), 0);
        end

        function test_d1d_constructor_returns_1d_instance(~)
            dnd_obj = d1d();

            assertEqual(numel(dnd_obj.pax), 1);
            assertEqual(dnd_obj.dimensions(), 1);
        end

        function test_d2d_constructor_returns_2d_instance(~)
            dnd_obj = d2d();

            assertEqual(numel(dnd_obj.pax), 2);
            assertEqual(dnd_obj.dimensions(), 2);
        end

        function test_d3d_constructor_returns_3d_instance(~)
            dnd_obj = d3d();

            assertEqual(numel(dnd_obj.pax), 3);
            assertEqual(dnd_obj.dimensions(), 3);
        end

        function test_d4d_constructor_returns_4d_instance(~)
            dnd_obj = d4d();

            assertEqual(numel(dnd_obj.pax), 4);
            assertEqual(dnd_obj.dimensions(), 4);
        end

        function test_default_constructor_returns_empty_instance(~)
            dnd_obj = d2d();

            assertEqualToTol(dnd_obj.s, 0, 1e-6);
            assertEqualToTol(dnd_obj.e, 0, 1e-6);
        end
        %-------------------------------------------------------------------
        function test_dnd_classes_follow_expected_class_heirarchy(~)
            dnd_objects = { d0d(), d1d(), d2d(), d3d(), d4d() };
            for idx = 1:numel(dnd_objects)
                dnd_obj = dnd_objects{idx};
                assertTrue(isa(dnd_obj, 'DnDBase'));
                assertTrue(isa(dnd_obj, 'SQWDnDBase'));
            end
        end
        %% getters/setters
        function test_d0d_get_returns_set_properties(obj)
            dnd_obj = d0d();
            obj.assert_dnd_get_returns_set_properties(dnd_obj,[]);
        end

        function test_d1d_get_returns_set_properties(obj)
            ab = axes_block('nbins_all_dims',[1,1,10,1]);
            dnd_obj = d1d(ab,ortho_proj());
            obj.assert_dnd_get_returns_set_properties(dnd_obj,[10,1]);
        end

        function test_d2d_get_returns_set_properties(obj)
            ab = axes_block('nbins_all_dims',[1,20,10,1]);
            dnd_obj = d2d(ab,ortho_proj());

            obj.assert_dnd_get_returns_set_properties(dnd_obj,[20,10]);
        end

        function test_d3d_get_returns_set_properties(obj)
            ab = axes_block('nbins_all_dims',[10,10,1,10]);
            dnd_obj = d3d(ab,ortho_proj());
            obj.assert_dnd_get_returns_set_properties(dnd_obj,[10,10,10]);
        end

        function test_d4d_get_returns_set_properties(obj)
            ab = axes_block('nbins_all_dims',[10,11,5,8]);
            dnd_obj = d4d(ab,ortho_proj());
            obj.assert_dnd_get_returns_set_properties(dnd_obj,[10,11,5,8]);
        end

        function assert_dnd_get_returns_set_properties(~, dnd_obj,box_size)
            class_props = fieldnames(dnd_obj);

            [sample_prop,dep_prop,const_prop]=dnd_object_sample_properties(box_size);
            test_prop = sample_prop.keys;

            % included all properties, forgot nothing
            assertTrue(all(ismember(class_props,[test_prop(:);dep_prop(:);const_prop(:)])))

            % properties are mapped to an internal data structure; verify the getters and
            % setters are correctly wired
            for idx = 1:numel(test_prop)
                prop_name = test_prop{idx};
                test_value = sample_prop(prop_name);
                %
                dnd_obj.do_check_combo_arg = false;
                dnd_obj.(prop_name) = test_value;
                assertEqual(dnd_obj.(prop_name), test_value, ...
                    sprintf('Value set to "%s" not returned', prop_name));
            end
            dnd_obj.do_check_combo_arg = true;
            dnd_obj = dnd_obj.check_combo_arg();

            function setter(obj,prop)
                val = obj.(prop);
                obj.(prop) = val;
            end
            for idx=1:numel(dep_prop)
                assertExceptionThrown(@()setter(dnd_obj,dep_prop{idx}), ...
                    'MATLAB:class:noSetMethod', ...
                    sprintf('Invalid exception for property: %s',dep_prop{idx}));
            end

        end
        %% Class properties
        function test_d4d_contains_expected_properties(obj)
            dnd_obj = d4d();
            assertEqual(dnd_obj.axes.dimensions,4)
            assertEqual(dnd_obj.dimensions,4)
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d3d_contains_expected_properties(obj)
            dnd_obj = d3d();
            assertEqual(dnd_obj.axes.dimensions,3)
            assertEqual(dnd_obj.dimensions,3)
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d2d_contains_expected_properties(obj)
            dnd_obj = d2d();
            assertEqual(dnd_obj.axes.dimensions,2)
            assertEqual(dnd_obj.dimensions,2)
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d1d_contains_expected_properties(obj)
            dnd_obj = d1d();
            assertEqual(dnd_obj.axes.dimensions,1)
            assertEqual(dnd_obj.dimensions,1)
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end

        function test_d0d_contains_expected_properties(obj)
            dnd_obj = d0d();
            assertEqual(dnd_obj.axes.dimensions,0)
            obj.assert_dnd_contains_expected_properties(dnd_obj);
        end
        function test_d0d_empty_constructor_contains_1D_array(~)
            dnd_obj = d0d();
            assertEqual(dnd_obj.dimensions,0)
            assertEqual(dnd_obj.s,0)
            assertEqual(dnd_obj.e,0)
            assertEqual(dnd_obj.npix,0)

            dnd_obj.npix = 1;
            assertEqual(dnd_obj.npix,1);
        end

        function assert_dnd_contains_expected_properties(~, dnd_obj)
            expected_props = { ...
                'filename', 'filepath', 'title', 'alatt', 'angdeg', ...
                'label', 'iax','offset' ...
                'iint', 'pax', 'p', 'dax', 's', 'e', 'npix',...
                'img_range','axes','proj','nbins','border_size','creation_date'};
            % moved elsewhere: 'uoffset', 'u_to_rlu', 'ulen',
            actual_props = fieldnames(dnd_obj);

            assertEqual(numel(actual_props), numel(expected_props));
            for idx = 1:numel(actual_props)
                assertTrue( ...
                    ismember(actual_props(idx),expected_props), ...
                    sprintf('Unrecognised DnD property "%s"', actual_props{idx}));
            end
        end
        function test_loadsave_works(obj)
            d2d_obj = read_dnd(obj.test_sqw_2d_fullpath);
            this_folder = fileparts(mfilename('fullpath'));
            if obj.save_output
                try
                    ver = d2d_obj.classVersion();
                catch
                    ver = 1;
                end
                test_file = fullfile(this_folder, ...
                    sprintf('loadsave_dnd_v%d.mat',ver));
                save(test_file,'d2d_obj');
            end
            rec_file = fullfile(this_folder , ...
                sprintf('loadsave_dnd_v%d.mat',1));
            ld = load(rec_file);
            assertEqualToTol(d2d_obj,ld.d2d_obj,'ignore_str',true)
        end


    end
end

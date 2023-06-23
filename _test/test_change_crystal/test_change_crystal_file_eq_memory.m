classdef test_change_crystal_file_eq_memory < TestCase
    % Perform tests of change_crystal functions and methods.
    %
    %
    % test_change_crystal_1 checks validity of crystal changes themselves
    % and this test ensures that change_crystal_sqw on a file is correct;
    % here we check that
    % all the permutations of object types and files are handled correctly.
    %
    % Author: T.G.Perring


    properties
        % We assume only that change_crystal_sqw(<filename>,rlu_corr) works, as tested in another routine
        rlu_corr =[...
            1.0817    0.0088   -0.2016;
            0.0247    1.0913    0.1802;
            0.1982   -0.1788    1.0555];

        alignmnent_info;
        tmpdir
        wref

        w2_1
        w2_2
    end
    methods
        %
        function obj = test_change_crystal_file_eq_memory(varargin)
            if nargin == 0
                name = 'test_change_crystal_file_eq_memory';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

            wref_file='wref.sqw';
            % First create initial sqw and dnd objects, and corresponding files
            wref_=read_sqw(wref_file);
            obj.wref = wref_;
            obj.w2_1=section(obj.wref, [0,1], [150,200]);
            obj.w2_2=section(obj.wref, [0,1], [200,250]);

            % Create file names
            % -----------------
            obj.tmpdir=tmp_dir;
            proj0 = wref_.data.proj;
            % let's assume that only reciprocal lattice vector length and
            % orientation have changed here. It is not true, but the
            % purpose of the test is to verify if the transformation works
            % on file and in memory, not if it is physiclly valid.
            % So it has to be just notinally valid
            b0_inf = wref_.header_average.u_to_rlu;
            scale = norm(obj.rlu_corr);
            rotmat = obj.rlu_corr/scale;
            rotvec = rotmat_to_rotvec2(rotmat);
            bm_modified = inv(b0_inf(1:3,1:3))/scale;
            lat_mod = 2*pi/bm_modified(1,1);
            obj.alignmnent_info = crystal_alignment_info( ...
                [lat_mod,lat_mod,lat_mod],proj0.angdeg,rotvec,eye(3));

        end
        function test_change_crystal_sqw_array_in_file_eq_change_in_memory(obj)
            %
            w2c_1_file=fullfile(obj.tmpdir,'w2c_1.sqw');
            w2c_2_file=fullfile(obj.tmpdir,'w2c_2.sqw');
            clOb = onCleanup(@()delete(w2c_1_file,w2c_2_file));

            save(obj.w2_1,w2c_1_file);
            save(obj.w2_2,w2c_2_file);
            w2arr = [obj.w2_1,obj.w2_2];

            
            ref_ans = change_crystal(w2arr,obj.alignmnent_info);

            change_crystal({w2c_1_file,w2c_2_file},obj.alignmnent_info);
            w2c_1=read_sqw(w2c_1_file);
            w2c_2=read_sqw(w2c_2_file);


            [ok, mess]=equal_to_tol(w2c_1, ref_ans(1),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');
            assertTrue(ok,mess)
            assertEqualToTol(w2c_2, ref_ans(2),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');

        end

        function test_change_crystal_sqw_in_file_eq_change_in_memory(obj)
            %
            w2c_1_file=fullfile(obj.tmpdir,'w2c_1.sqw');
            clOb = onCleanup(@()delete(w2c_1_file));
            save(obj.w2_1,w2c_1_file);

            ref_ans = change_crystal(obj.w2_1,obj.alignmnent_info);

            change_crystal_sqw(w2c_1_file,obj.alignmnent_info);
            w2c_1=read_sqw(w2c_1_file);

            assertEqualToTol(w2c_1, ref_ans,[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');
        end
        function test_change_crystal_d2darray_in_file_eq_change_in_memory(obj)
            %
            d2c_1_file=fullfile(obj.tmpdir,'d2c_1.sqw');
            d2c_2_file=fullfile(obj.tmpdir,'d2c_2.sqw');
            clOb = onCleanup(@()delete(d2c_1_file,d2c_2_file));
            d2_1=dnd(obj.w2_1);
            d2_2=dnd(obj.w2_1);
            save(d2_1,d2c_1_file);
            save(d2_2,d2c_2_file);
            d2arr = [d2_1,d2_2];

            ref_ans = change_crystal(d2arr,obj.alignmnent_info);

            change_crystal({d2c_1_file,d2c_2_file},obj.alignmnent_info);
            d2c_1=read_dnd(d2c_1_file);
            d2c_2=read_dnd(d2c_2_file);


            assertEqualToTol(d2c_1, ref_ans(1),[1.e-9,1e-9], ...
                'nan_equal',true,'ignore_str',true);

            assertEqualToTol(d2c_2, ref_ans(2),[1.e-9,1e-9], ...
                'nan_equal',true,'ignore_str',true);
        end

        function test_change_crystal_d2d_in_file_eq_change_in_memory(obj)
            %
            d2c_1_file=fullfile(obj.tmpdir,'d2c_1.sqw');
            clOb = onCleanup(@()delete(d2c_1_file));
            d2_1=dnd(obj.w2_1);
            save(d2_1,d2c_1_file);

            ref_ans = change_crystal(d2_1,obj.alignmnent_info);

            change_crystal(d2c_1_file,obj.alignmnent_info);
            d2c_1=read_dnd(d2c_1_file);

            assertEqualToTol(d2c_1, ref_ans,[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true);
        end
    end
end
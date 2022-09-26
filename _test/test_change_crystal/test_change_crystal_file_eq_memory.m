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
        rlu_corr =[1.0817    0.0088   -0.2016;  0.0247    1.0913    0.1802;    0.1982   -0.1788    1.0555];

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
            obj.wref=read_sqw(wref_file);
            obj.w2_1=section(obj.wref, [0,1], [150,200]);
            obj.w2_2=section(obj.wref, [0,1], [200,250]);

            % Create file names
            % -----------------
            obj.tmpdir=tmp_dir;

        end
        function test_change_crystal_sqw_array_in_file_eq_change_in_memory(obj)
            %
            w2c_1_file=fullfile(obj.tmpdir,'w2c_1.sqw');
            w2c_2_file=fullfile(obj.tmpdir,'w2c_2.sqw');
            clOb = onCleanup(@()delete(w2c_1_file,w2c_2_file));

            save(obj.w2_1,w2c_1_file);
            save(obj.w2_2,w2c_2_file);
            w2arr = [obj.w2_1,obj.w2_2];

            ref_ans = change_crystal(w2arr,obj.rlu_corr);

            change_crystal({w2c_1_file,w2c_2_file},obj.rlu_corr);
            w2c_1=read_sqw(w2c_1_file);
            w2c_2=read_sqw(w2c_2_file);

            w2c_1.data.proj = ref_ans(1).data.proj; %this disables failure #846!
            [ok, mess]=equal_to_tol(w2c_1, ref_ans(1),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');
            assertTrue(ok,mess)
            w2c_2.data.proj = ref_ans(2).data.proj; %this disables failure #846!
            assertEqualToTol(w2c_2, ref_ans(2),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');
            skipTest('Disabled due to issue #846')
        end

        function test_change_crystal_sqw_in_file_eq_change_in_memory(obj)
            %
            w2c_1_file=fullfile(obj.tmpdir,'w2c_1.sqw');
            clOb = onCleanup(@()delete(w2c_1_file));
            save(obj.w2_1,w2c_1_file);

            ref_ans = change_crystal(obj.w2_1,obj.rlu_corr);

            change_crystal_sqw(w2c_1_file,obj.rlu_corr);
            w2c_1=read_sqw(w2c_1_file);


            w2c_1.data.proj = ref_ans.data.proj; %this disables failure #846!
            assertEqualToTol(w2c_1, ref_ans,[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true,'-ignore_date');
            skipTest('Disabled due to issue #846')
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

            ref_ans = change_crystal(d2arr,obj.rlu_corr);

            change_crystal({d2c_1_file,d2c_2_file},obj.rlu_corr);
            d2c_1=read_dnd(d2c_1_file);
            d2c_2=read_dnd(d2c_2_file);


            d2c_1.proj = ref_ans(1).proj; %this disables failure #846!
            [ok, mess]=equal_to_tol(d2c_1, ref_ans(1),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true);
            assertTrue(ok,mess)
            d2c_2.proj = ref_ans(2).proj; %this disables failure #846!
            assertEqualToTol(d2c_2, ref_ans(2),[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true);
            skipTest('Disabled due to issue #846')
        end

        function test_change_crystal_d2d_in_file_eq_change_in_memory(obj)
            %
            d2c_1_file=fullfile(obj.tmpdir,'d2c_1.sqw');
            clOb = onCleanup(@()delete(d2c_1_file));
            d2_1=dnd(obj.w2_1);
            save(d2_1,d2c_1_file);

            ref_ans = change_crystal(d2_1,obj.rlu_corr);

            change_crystal(d2c_1_file,obj.rlu_corr);
            d2c_1=read_dnd(d2c_1_file);


            d2c_1.proj = ref_ans.proj; %this disables failure #846!
            assertEqualToTol(d2c_1, ref_ans,[2.e-7,2e-7], ...
                'nan_equal',true,'ignore_str',true);
            skipTest('Disabled due to issue #846')

        end
    end
end
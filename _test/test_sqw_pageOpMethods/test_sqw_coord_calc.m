classdef test_sqw_coord_calc < TestCaseWithSave

    properties
        sqw_1d
        sqw_2d
        sqw_1d_path
        sqw_2d_path
    end


    methods
        function obj = test_sqw_coord_calc(varargin)
            this_dir = fileparts(mfilename('fullpath'));
            argi = [varargin,{fullfile(this_dir,'test_sqw_coord_calc.mat')}];
            obj = obj@TestCaseWithSave(argi{:});

            hp = horace_paths;
            sqw_file_1d_name = 'sqw_1d_1.sqw';
            sqw_file_2d_name = 'sqw_2d_1.sqw';

            obj.sqw_1d_path = fullfile(hp.test_common, sqw_file_1d_name);
            obj.sqw_2d_path = fullfile(hp.test_common, sqw_file_2d_name);

            obj.sqw_1d = read_sqw(obj.sqw_1d_path);
            obj.sqw_2d = read_sqw(obj.sqw_2d_path);
            obj.save();
        end

        function test_signal_fb(obj)

            w1modE = coordinates_calc(obj.sqw_2d, 'E');

            clObj = set_temporary_config_options(hor_config, ...
                'mem_chunk_size', 4000,'fb_scale_factor',4);

            fb_sqw = sqw(obj.sqw_2d_path);
            assertTrue(fb_sqw.pix.is_filebacked);

            w1modE_fb = coordinates_calc(fb_sqw, 'E');

            assertEqualToTol(w1modE.data, w1modE_fb.data, ...
                'tol',2*eps('single'),'ignore_str', true);
            assertEqualToTol(w1modE.pix, w1modE_fb.pix, ...
                'tol', 2*eps('single'), 'ignore_str', true);

        end

        function test_w2E_option(obj)
            w1modE = coordinates_calc(obj.sqw_2d,'E');

            assertEqualToTolWithSave(obj,w1modE,'ignore_str',true, ...
                'tol',[1.e-9,1.e-9],'-ignore_date');

        end

        function test_w2Q_option(obj)
            w1modQ = coordinates_calc(obj.sqw_2d,'Q');

            assertEqualToTolWithSave(obj,w1modQ,'ignore_str',true, ...
                'tol',[3.e-7,3.e-7],'-ignore_date');

        end

        function test_w2l_option(obj)
            w2modL = coordinates_calc(obj.sqw_2d,'l');

            assertEqualToTolWithSave(obj,w2modL,'ignore_str',true, ...
                'tol',[1.e-9,1.e-9],'-ignore_date');

        end
        function test_w2d2_option(obj)
            w2modD2 = coordinates_calc(obj.sqw_2d,'d2');

            assertEqualToTolWithSave(obj,w2modD2,'ignore_str',true, ...
                'tol',[1.e-9,1.e-9],'-ignore_date');

        end

        function test_w1d2_throws(obj)
            assertExceptionThrown(@()coordinates_calc(obj.sqw_1d,'d2'),...
                'HORACE:sqw:invalid_argument');
        end

        function test_w1d1_option(obj)
            w1modP1 = coordinates_calc(obj.sqw_1d,'d1');

            assertEqualToTolWithSave(obj,w1modP1,'ignore_str',true, ...
                'tol',[1.e-9,1.e-9],'-ignore_date');
        end

    end
end

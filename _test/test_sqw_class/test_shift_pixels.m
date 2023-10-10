classdef test_shift_pixels < TestCase

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
    end


    methods
        function obj = test_shift_pixels(varargin)
            if nargin == 0
                name = 'test_shift_pixels';
            else
                name = varargin{1};
            end

            obj = obj@TestCase(name,ref_data);
            pths = horace_paths;

            obj.test_sqw_1d_fullpath = fullfile(pths.test_common, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(pths.test_common, obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = fullfile(pths.test_common, obj.sqw_file_4d_name);
            obj.save();
        end

            %% shifts
        function test_shift_energy_bins(obj)
            skipTest("Incorrect test data for shift");
            params = {'scale', 14};
            sqw_4d_obj = sqw(obj.test_sqw_1d_fullpath);
            wout = sqw_4d_obj.shift_energy_bins(@test_shift_pixels.disp_rln, params);
        end

        function test_shift_pixels_1(obj)
            skipTest("Incorrect test data for shift");
            params = {}; % no parameters required by test shift_rln function
            sqw_4d_obj = sqw(obj.test_sqw_4d_fullpath);
            wout = shift_pixels(sqw_4d_obj, @test_shift_pixels.shift_rln, params);

            assertEqual(sqw_4d_obj.npixels, wout.npixels);
        end

    end
    methods(Static)
        function val = disp_rln(qh, qk, ql, varargin)
            % simple function to testing; uses the first keyword argument
            scale = varargin{2};
            val = qh .* qk .* ql .* scale;
        end
        

        function val = shift_rln(qh, qk, qw, ~)
            % discard any function parameters that are passed by shift_pixels call
            val = qw .* qk .* qh;
        end
    end    
end
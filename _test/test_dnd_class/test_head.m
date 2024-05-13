classdef test_head < TestCaseWithSave
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';


        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
        d1d_obj
    end



    methods
        function obj = test_head(varargin)
            test_data = fullfile(fileparts(mfilename('fullpath')),'test_head.mat');
            if nargin == 0
                argi = {test_data};
            else
                argi = {varargin{1},test_data};
            end
            obj = obj@TestCaseWithSave(argi{:});
            hc = horace_paths;

            obj.test_sqw_1d_fullpath = fullfile(hc.test_common, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(hc.test_common, obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = fullfile(hc.test_common, obj.sqw_file_4d_name);
            obj.d1d_obj = read_dnd(obj.test_sqw_1d_fullpath);
            % old object, creation date is not defined.
            % assign creation date to avoid uncertainty
            obj.d1d_obj.creation_date = datetime('now');
            obj.save();
        end
        function test_head_no_arg_full_works(obj)
            % Header:

            % Head without return argument works
            works = false;
            try
                head(obj.d1d_obj,'-full');
            catch ME
                assertTrue(works,ME.message);
            end
        end

        function test_head_no_arg_works(obj)
            % Header:
            % ---------
            % First on object:

            % Head without return argument works
            works = false;
            try
                head(obj.d1d_obj);
            catch ME
                assertTrue(works,ME.message);
            end
        end

        function test_head_1d_multi(obj)
            obj_arr = [obj.d1d_obj,obj.d1d_obj];
            [hd1,hd2] = head(obj_arr);
            assertEqual(hd1,hd2);

            assertEqualToTolWithSave(obj,hd1,4.e-7,'ignore_str',true);
        end

        function test_head_1d_full(obj)
            hd = head(obj.d1d_obj,'-full');


            assertEqualToTolWithSave(obj,hd,4.e-7,'ignore_str',true);
        end

        function test_head_1d(obj)
            hd = head(obj.d1d_obj);

            assertEqualToTolWithSave(obj,hd,4.e-7,'ignore_str',true);
        end
    end
end

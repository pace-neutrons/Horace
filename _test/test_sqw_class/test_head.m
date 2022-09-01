classdef test_head < TestCaseWithSave
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_2d_name = 'sqw_2d_1.sqw';
        sqw_file_4d_name = 'sqw_4d.sqw';

        common_data

        test_sqw_1d_fullpath = '';
        test_sqw_2d_fullpath = '';
        test_sqw_4d_fullpath = '';
        sq1d_obj
    end



    methods
        function obj = test_head(varargin)
            %hor_root = horace_root();
            this_data_path = fileparts(mfilename('fullpath'));
            test_data = fullfile(this_data_path,'test_head.mat');
            if nargin == 0
                argi = {test_data};
            else
                argi = {varargin{1},test_data};
            end
            obj = obj@TestCaseWithSave(argi{:});
            obj.common_data = fullfile(fileparts(this_data_path),'common_data');

            obj.test_sqw_1d_fullpath = fullfile(obj.common_data, obj.sqw_file_1d_name);
            obj.test_sqw_2d_fullpath = fullfile(obj.common_data, obj.sqw_file_2d_name);
            obj.test_sqw_4d_fullpath = fullfile(obj.common_data, obj.sqw_file_4d_name);
            obj.sq1d_obj = read_sqw(obj.test_sqw_1d_fullpath);
            obj.save();
        end
        function test_head_no_arg_full_works(obj)
            % Header:

            % Head without return argument works
            try
                head(obj.sq1d_obj,'-full');
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
                head(obj.sq1d_obj);
            catch ME
                assertTrue(works,ME.message);
            end
        end

        function test_head_1d_multi(obj)
            obj_arr = [obj.sq1d_obj,obj.sq1d_obj];
            [hd1,hd2] = head(obj_arr);
            assertEqual(hd1,hd2);

            assertEqualToTolWithSave(obj,hd1,4.e-9,'ignore_str',true);
        end

        function test_head_1d_full(obj)
            hd = head(obj.sq1d_obj,'-full');
            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end
        function test_head_dnd_1d(obj)
            hd = head(obj.sq1d_obj.data);

            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end


        function test_head_sqw_1d(obj)
            hd = head(obj.sq1d_obj);

            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end
    end
end

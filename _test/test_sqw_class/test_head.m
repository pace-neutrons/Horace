classdef test_head < TestCaseWithSave
    % Collection of placeholder tests to simple run the migrated API functions: these MUST be replaced
    % with more comprehensive tests as soon as possible

    properties
        dnd_file_1d_name = 'w1d_d1d.sqw';
        sqw_file_1d_name = 'sqw_1d_1.sqw';
        sqw_file_v4_name = 'faccess_sqw_v4_sample.sqw'

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
            horp = horace_paths;

            obj.dnd_file_1d_name = fullfile(horp.test_common, obj.dnd_file_1d_name);
            obj.sqw_file_1d_name = fullfile(horp.test_common, obj.sqw_file_1d_name);
            obj.sqw_file_v4_name = fullfile(horp.test, ...
                'test_sqw_file',obj.sqw_file_v4_name);

            obj.sq1d_obj = read_sqw(obj.sqw_file_1d_name);
            obj.save();
        end
        function test_head_no_arg_full_works(obj)
            % Header:

            % Head without return argument works
            works = false;
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
        function test_head_sqw_new_file_full(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.sqw_file_v4_name);
            hd = ldr.head('-full');
            sqw_obj = ldr.get_sqw('-verbatim');
            ldr.delete();
            hdd = sqw_obj.head('-full');

            assertEqualToTol(hd,hdd)
        end
        function test_head_sqw_new_file(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.sqw_file_v4_name);
            hd = ldr.head();
            sqw_obj = ldr.get_sqw('-verbatim');
            ldr.delete();
            hdd = sqw_obj.head();

            assertEqualToTol(hd,hdd)
        end


        function test_head_sqw_old_file_full(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.sqw_file_1d_name);
            hd = ldr.head('-full');
            sqw_obj = ldr.get_sqw('-verbatim');
            ldr.delete();
            hdd = sqw_obj.head('-full');

            % no creation date in old files
            hdd.creation_date = hd.creation_date;
            % old format contains all headers, but only some contributed to
            % pixels. loader ignores those headers, so nfiles change
            hdd.nfiles = hd.nfiles;
            % old file format does not contain data range
            hd.data_range = hdd.data_range;
            assertEqualToTol(hd,hdd,1.e-8)
        end

        function test_head_sqw_old_file(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.sqw_file_1d_name);
            hd = ldr.head();
            sqw_obj = ldr.get_sqw('-verbatim');
            ldr.delete();
            hdd = sqw_obj.head();

            % no creation date in old files
            hdd.creation_date = hd.creation_date;
            % old format contains all headers, but only some contributed to
            % pixels. loader ignores those headers, so nfiles change
            hdd.nfiles = hd.nfiles;
            % old file format does not contain data range
            hd.data_range = hdd.data_range;
            %
            %Re #825 head from loader returs legacy u_to_rlu and head from 
            % loader return different u_to_rlu matrix (one -- legacy, other
            % -- from current transformation
            % which one is correct is the question
            % 
            hd.u_to_rlu = hdd.u_to_rlu;

            assertEqualToTol(hd,hdd,1.e-8)
        end
        function test_head_dnd_old_file_full(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.dnd_file_1d_name);
            hd = ldr.head('-full');
            dnd_obj = ldr.get_dnd('-verbatim');
            ldr.delete();
            hdd = head(dnd_obj,'-full');           

            % no creation date in old files
            hdd.creation_date = hd.creation_date;
            assertEqualToTol(hd,hdd,1.e-7)
        end


        function test_head_dnd_old_file(obj)
            ldr = sqw_formats_factory.instance().get_loader(obj.dnd_file_1d_name);
            hd = ldr.head();
            dnd_obj = ldr.get_dnd('-verbatim');
            ldr.delete();
            hdd = head(dnd_obj);
            %Re #825  see test head_sqw_1d for details
            u_to_rlu_legacy = dnd_obj.proj.u_to_rlu_legacy;
            hdd.u_to_rlu = u_to_rlu_legacy;
            

            % no creation date in old files
            hdd.creation_date = hd.creation_date;
            assertEqualToTol(hd,hdd,1.e-7)
        end

        function test_head_1d_multi(obj)
            obj_arr = [obj.sq1d_obj,obj.sq1d_obj];
            [hd1,hd2] = head(obj_arr);
            assertEqual(hd1,hd2);
            %Re #825  see test head_sqw_1d for details
            u_to_rlu_legacy = obj.sq1d_obj.data.proj.u_to_rlu_legacy;
            hd1.u_to_rlu = u_to_rlu_legacy;

            assertEqualToTolWithSave(obj,hd1,4.e-9,'ignore_str',true);
        end

        function test_head_1d_full(obj)
            hd = head(obj.sq1d_obj,'-full');
            %Re #825  see test head_sqw_1d for details
            u_to_rlu_legacy = obj.sq1d_obj.data.proj.u_to_rlu_legacy;
            hd.u_to_rlu = u_to_rlu_legacy;
            
            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end
        function test_head_dnd_1d(obj)
            hd = head(obj.sq1d_obj.data);
            %Re #825  see test head_sqw_1d for details
            u_to_rlu_legacy = obj.sq1d_obj.data.proj.u_to_rlu_legacy;
            hd.u_to_rlu = u_to_rlu_legacy;
            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end


        function test_head_sqw_1d(obj)
            hd = head(obj.sq1d_obj);
            u_to_rlu_legacy = obj.sq1d_obj.data.proj.u_to_rlu_legacy;
            %Re #825  h_to_rlu_legacy ==
            %[ 1.0000    0.0000    1.0000         0;...
            %  1.0000    0.0000   -1.0000         0;...
            %  0.0000    1.0000    0.0000         0;...
            %   0         0         0    1.0000];
            % and new u_to_rlu is
            %[0.7071   -0.0000    0.7071         0
            % 0.7071    0.0000   -0.7071         0
            % 0         1.0000    0.0000         0
            % 0         0         0         1.0000]
            % let's assume that new is correct, but keep legacy for references
            hd.u_to_rlu = u_to_rlu_legacy;
            assertEqualToTolWithSave(obj,hd,4.e-9,'ignore_str',true);
        end
    end
end

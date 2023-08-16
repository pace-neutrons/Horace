classdef test_upgrade_file_format< TestCase

    properties
        source_mat = 'testsqw_w3_small_v1.mat'
        source_sqw1 = 'sqw_2d_2.sqw'
        ff_source_mat;
        ff_source_sqw;
        working_dir
        test_common;
    end
    methods
        %
        function obj=test_upgrade_file_format(name)
            if nargin<1
                name = 'test_upgrade_file_format';
            end
            obj = obj@TestCase(name);
            hc = horace_paths;
            obj.test_common = hc.test_common;
            obj.ff_source_mat = fullfile(obj.test_common,obj.source_mat);
            obj.ff_source_sqw = fullfile(obj.test_common,obj.source_sqw1);
            obj.working_dir = tmp_dir();
        end
        function test_no_upgrade_for_legacy_alignment(obj)
            % legacy aligned file
            laf = fullfile(obj.test_common,'sqw_4d.sqw');
            clWarn = set_temporary_warning('off', 'HORACE:legacy_alignment');            
            fl = upgrade_file_format(laf);
            assertEqual(fl{1},laf);
        end
        function test_upgrade_single_sqw_filebacked(obj)
            [clFile,targ_f] = obj.copy_my_file(obj.ff_source_sqw);
            clConf = set_temporary_config_options(hor_config, ...
                'mem_chunk_size',10000,'fb_scale_factor',3); % should give 3 pages
            clWarn = set_temporary_warning('off', 'TESTS:my_warning');
            warning('TESTS:my_warning','This should become the last warning as no other waning were issued on the way');

            upgrade_file_format(targ_f);
            w2  = sqw(targ_f{1});

            [~,e] = lastwarn;
            assertEqual(e,'TESTS:my_warning');
            assertTrue(any(w2.pix.data_range(:) ~= PixelData.EMPTY_RANGE(:)) )
        end


        function test_upgrade_single_sqw_membased(obj)
            [clOb,targ_f] = obj.copy_my_file(obj.ff_source_sqw);
            upgrade_file_format(targ_f{1});
            w2  = read_sqw(targ_f{1});
            assertTrue(any(w2.pix.data_range(:) ~= PixelData.EMPTY_RANGE(:)) )
        end

        function test_upgrade_single_mat(obj)

            [clOb,targ_f] = obj.copy_my_file(obj.ff_source_mat);
            clWarn = set_temporary_warning('off', ...
                'MATLAB:load:classNotFound','TESTS:my_warning');
            upgrade_file_format(targ_f);
            [~,e] = lastwarn;
            assertEqual(e,'MATLAB:load:classNotFound'); % old file format
            % contains reference to the missing class, so we can identify
            % that this is old file format

            warning('TESTS:my_warning','This should become the last warning');
            ld = load(targ_f{1});
            [~,e] = lastwarn;
            assertEqual(e,'TESTS:my_warning');
            w3  = ld.w3_small_v1;
            assertTrue(any(w3.pix.data_range(:) ~= PixelData.EMPTY_RANGE(:)) )
        end
    end
    methods(Access=private)
        function [clOb,targ_f] = copy_my_file(obj,flilelist)
            if istext(flilelist)
                filelist = cellstr(flilelist);
            end
            targ_f = cell(numel(filelist),1);
            for i=1:numel(filelist)
                source = filelist{i};
                [~,fn,fe] = fileparts(source);
                target = fullfile(obj.working_dir,[fn,fe]);
                copyfile(source,target,"f");
                targ_f{i} = target;
            end
            clOb = onCleanup(@()del_memmapfile_files(targ_f));
        end
    end
end


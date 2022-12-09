classdef test_sqw_formats_factory <  TestCase %WithSave
    %Testing sqw-read-write factory
    %
    properties
        test_folder
        test_data_folder
    end

    methods
        function obj = test_sqw_formats_factory(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
            hc = horace_paths;
            obj.test_data_folder  = hc.test_common;
        end
        %-----------------------------------------------------------------
        function test_selection_v3_3(obj)

            file_v3_3 = fullfile(obj.test_folder,...
                'test_sqw_file_read_write_v3_3.sqw');

            loader = sqw_formats_factory.instance().get_loader(file_v3_3 );
            assertTrue(isa(loader,'faccess_sqw_v3_3'));
            assertEqual(loader.faccess_version,3.3);
            assertEqual(loader.filename,'test_sqw_file_read_write_v3_3.sqw')
            assertEqual(loader.npixels,7680)
        end

        function obj = test_selection_v2(obj)


            file_v2 = fullfile(obj.test_data_folder,'w1d_sqw.sqw');

            loader = sqw_formats_factory.instance().get_loader(file_v2);

            assertTrue(isa(loader,'faccess_sqw_v2'));
            assertEqual(loader.faccess_version,2);
            assertEqual(loader.filename,'w1d_sqw.sqw')
            assertEqual(loader.npixels,8031)
        end
        %
        function test_selection_v3_old(obj)

            warning('off','SQW_FILE_IO:legacy_data')
            clob = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));
            file_v3_old = fullfile(obj.test_folder,...
                'test_sqw_file_read_write_v3.sqw');

            loader = sqw_formats_factory.instance().get_loader(file_v3_old);
            assertTrue(isa(loader,'faccess_sqw_v2'));
            assertEqual(loader.faccess_version,2);
            assertEqual(loader.filename,'test_sqw_file_read_write_v3.sqw')
            assertEqual(loader.npixels,7680)
        end
        %
        function test_selection_v3(obj)

            file_v3 = fullfile(obj.test_folder,...
                'test_sqw_file_read_write_v3_1.sqw');

            loader = sqw_formats_factory.instance().get_loader(file_v3);
            assertTrue(isa(loader,'faccess_sqw_v3'));
            assertEqual(loader.faccess_version,3.1);
            assertEqual(loader.filename,'test_sqw_file_read_write_v3_1.sqw')
            assertEqual(loader.npixels,7680)
        end
        function test_wrong_selection_wrong_format(obj)
            % not an sqw file
            file_nonHor = fullfile(obj.test_folder,...
                'pos_to_test.mat');
            fl = @()(sqw_formats_factory.instance().get_loader(file_nonHor));
            ME = assertExceptionThrown(fl,'HORACE:horace_binfile_interface:runtime_error');

            err_message = sprintf( ...
                'File: %s  is not recognized as Horace binary file',file_nonHor);
            assertEqual(ME.message,err_message )
        end
        function test_selection_v0(obj)
            file_v0 = fullfile(obj.test_folder,...
                'test_sqw_read_write_v0_t.sqw');
            warning('off','SQW_FILE_IO:legacy_data')
            clob = onCleanup(@()warning('on','SQW_FILE_IO:legacy_data'));

            loader = sqw_formats_factory.instance().get_loader(file_v0);
            assertTrue(isa(loader,'faccess_sqw_prototype'));
            assertEqual(loader.faccess_version,0);
            assertEqual(loader.filename,'test_sqw_read_write_v0_t.sqw')
            assertEqual(loader.npixels,16)
        end
        function test_selection_dnd(obj)
            file_dndv2 = fullfile(obj.test_data_folder,...
                'w2d_qe_d2d.sqw');
            loader = sqw_formats_factory.instance().get_loader(file_dndv2);
            assertTrue(isa(loader,'faccess_dnd_v2'));
            assertEqual(loader.faccess_version,2);
            assertFalse(loader.sqw_type);
            assertEqual(loader.filename,'w2d_qe_d2d.sqw')
            assertEqual(loader.data_type,'b+')
            assertEqual(loader.num_dim,2)
            assertEqual(loader.dnd_dimensions,[81,72])
        end
        function test_wrong_selection_wrong_version(obj)
            file_ficVer = fullfile(fileparts(obj.test_folder),...
                'test_sqw_file','test_sqw_file_fictional_ver.sqw');
            fl = @()(sqw_formats_factory.instance().get_loader(file_ficVer));
            assertExceptionThrown(fl,'HORACE:file_io:runtime_error');
        end
        %
        function test_selection_v1(obj)
            file_v1 = fullfile(obj.test_folder,...
                'w2_small_v1.sqw');
            loader = sqw_formats_factory.instance().get_loader(file_v1);

            assertTrue(isa(loader,'faccess_sqw_v2'));
            assertEqual(loader.faccess_version,2);
            assertEqual(loader.filename,'w2_small_v1.sqw')
            assertEqual(loader.npixels,179024)

        end
        %
        function obj= test_pref_access(obj)
            dob = sqw();
            ld1 = sqw_formats_factory.instance().get_pref_access(dob);
            assertTrue(isa(ld1,'faccess_sqw_v3_3'));

            dob = d1d();
            ld2 = sqw_formats_factory.instance().get_pref_access(dob);
            assertTrue(isa(ld2,'faccess_dnd_v2'));

        end
        function obj= test_load_range(obj)
            file_v2 = fullfile(obj.test_data_folder,...
                'w1d_sqw.sqw');
            file_v3 = fullfile(fileparts(obj.test_folder),...
                'test_sqw_file','test_sqw_file_read_write_v3_1.sqw');
            files = {file_v2,file_v3};

            ldrs = sqw_formats_factory.instance().get_loader(files);

            assertTrue(isa(ldrs{1},'faccess_sqw_v2'));
            assertTrue(isa(ldrs{2},'faccess_sqw_v3'));
        end
        function test_serialize_deserialise_emtpy_accessors(~)

            ldrs = sqw_formats_factory.instance().supported_accessors;
            for i=1:numel(ldrs)
                fo = ldrs{i};
                by = hlp_serialize(fo);
                fr = hlp_deserialize(by);
                assertEqual(fo,fr);
            end
        end

    end

end


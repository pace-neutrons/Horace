classdef test_binfile_v2_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxiliary methods, available on this class
    %

    properties
        test_data_folder
    end

    methods
        function obj = test_binfile_v2_common(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            hp = horace_paths;
            obj.test_data_folder=hp.test_common;
        end
        %-----------------------------------------------------------------
        function test_serialize_deserialize(~)
            to = binfile_v2_common_tester();

            struc = to.to_struct();

            to_r = serializable.from_struct(struc);

            assertEqual(to,to_r);
        end
        function test_get_version_invalid_throws(obj)
            to = binfile_v2_common_tester();
            wrong_source = fullfile(obj.test_data_folder,'96dets.par');

            f = @()(to.get_file_header('non-existing_file.sqw'));
            assertExceptionThrown(f,'HORACE:horace_binfile_interface:io_error');

            f = @()to.get_file_header(wrong_source);
            assertExceptionThrown(f,'HORACE:horace_binfile_interface:runtime_error');

        end
        function obj = test_get_version(obj)
            to = binfile_v2_common_tester();
            source = fullfile(obj.test_data_folder,'w1d_d1d.sqw');

            [stream,fid1] = to.get_file_header(source);
            co1 = onCleanup(@()fclose(fid1));

            assertTrue(fid1>0)
            assertTrue(isstruct(stream));
            assertEqual(stream.version,2);
            assertEqual(stream.name,'horace');
            assertEqual(stream.typestart,int32(18));
            assertEqual(stream.uncertain,false);

            assertEqual(stream.sqw_type,false);
            assertEqual(stream.num_dim,int32(1));
        end
        %
        function obj = test_get_data_form(obj)
            tob = binfile_v2_common_tester();

            form = tob.get_dnd_form();
            fn = fieldnames(form);

            assertEqual(numel(fn),19);

            tob = tob.set_datatype('a');
            form = tob.get_dnd_form('-head');
            fn = fieldnames(form);
            assertEqual(numel(fn),16);

            form = tob.get_dnd_form('-const');
            fn = fieldnames(form);
            assertEqual(numel(fn),16);

            form = tob.get_dnd_form('-const','-head');
            fn = fieldnames(form);
            assertEqual(numel(fn),13);

        end
        %
        function obj= test_extract_field_range(obj)
            range = 1:20;
            base_fields = arrayfun(@form_str,range,'UniformOutput',false);

            base_str = struct(base_fields{:});

            filter1 = struct('f1','','f2','','f3','');

            [f1,f2,is_last] = binfile_v2_common.extract_field_range(base_str,filter1);
            assertFalse(is_last)
            assertEqual(f1,'f1_pos_');
            assertEqual(f2,'f4_pos_');


            filter2 = struct('f3','','f4','','f7','');

            [f1,f2,is_last] = binfile_v2_common.extract_field_range(base_str,filter2);
            assertFalse(is_last)
            assertEqual(f1,'f3_pos_');
            assertEqual(f2,'f8_pos_');


            filter3 =struct('f4','','f7','','f10','');

            [f1,f2,is_last] = binfile_v2_common.extract_field_range(base_str,filter3);
            assertTrue(is_last)
            assertEqual(f1,'f4_pos_');
            assertEqual(f2,'f10_pos_');


            function str = form_str(x)
                if mod(x+1,2) == 0
                    str = ['f',num2str((x+1)/2),'_pos_'];
                else
                    str  = '';
                end
            end
        end
        function test_call_set_file_to_update_without_arguments_throws(obj)
            tob = binfile_v2_common_tester();

            samp = fullfile(obj.test_data_folder,'w1d_sqw.sqw');
            f=@()(tob.set_file_to_update(samp));
            assertExceptionThrown(f,'HORACE:horace_binfile_interface:invalid_argument');

        end
        %
        function obj = test_set_file_to_update_opens_in_rb_plus(obj)
            tob = binfile_v2_common_tester();

            samp = fullfile(obj.test_data_folder,'w1d_sqw.sqw');

            tob=tob.set_file_to_update(samp);

            assertTrue(tob.sqw_type)
            assertEqual(tob.num_dim,1)
            assertTrue(isa(tob,'faccess_sqw_v2'));

            tob = tob.delete();
            assertTrue(tob.sqw_type) % its still sqw reader, you know...
            assertEqual(tob.num_dim,'undefined')

        end
        %
        function obj = test_set_missing_file_to_update_opens_in_wb_plus(obj)
            tob = binfile_v2_common_tester();

            test_f = fullfile(tmp_dir,'test_change_file_to_write.sqw');
            clob = onCleanup(@()delete(test_f));

            tob=tob.set_file_to_update(test_f);
            assertTrue(exist(test_f,'file')==2);
            assertEqual(tob.get_faccess_mode(),'wb+')

            tob=tob.delete();
            assertFalse(tob.sqw_type) % its still sqw reader, you know...
            assertEqual(tob.num_dim,'undefined')

        end
        %
        function obj = test_copy_constructor(obj)

            samp = fullfile(obj.test_data_folder,'w1d_d1d.sqw');
            tob = binfile_v2_common_tester(samp);


            cob = binfile_v2_common_tester(tob);

            d0 = tob.get_sqw();
            d1 = cob.get_sqw();

            assertEqual(d0,d1);

        end
        function obj = test_copy_constructor_write_perm(obj)

            samp = fullfile(obj.test_data_folder,'w1d_d1d.sqw');
            ttob = binfile_v2_common_tester(samp);
            sq_obj = ttob.get_sqw();
            assertTrue(isa(sq_obj,'d1d'));

            test_f = fullfile(tmp_dir,'test_dnd_copy_constructor_write_perm.sqw');
            clob = onCleanup(@()delete(test_f));

            tob =  binfile_v2_common_tester(sq_obj,test_f);
            cob = binfile_v2_common_tester(tob);

            cob  = cob.put_sqw();
            cob.delete();

            chob = binfile_v2_common_tester(test_f);

            tsq_obj = chob.get_sqw();
            tsq0_obj = tob.get_sqw();
            chob.delete();
            tob.delete();

            assertEqualToTol(sq_obj,tsq_obj,'ignore_str',true);
            assertEqualToTol(tsq0_obj,tsq_obj,'ignore_str',true);
        end
        %
        function obj = test_reopen_to_write(obj)

            samp = fullfile(obj.test_data_folder,'w1d_d1d.sqw');
            test_f = fullfile(tmp_dir,'test_dnd_reopen_to_write.sqw');
            copyfile(samp,test_f,"f");
            clob = onCleanup(@()delete(test_f));

            ttob = binfile_v2_common_tester(test_f);
            % important! -verbatim is critical here!, as it returns filenames
            % as they were stored on file, so we can write everyting exactly
            % at the same places as before. Without it we should
            % reinitialize object to write
            sq_obj = ttob.get_sqw('-verbatim');
            assertTrue(isa(sq_obj,'d1d'));

            % using already initialized object to write new data.
            % its better to initialize object again as with this form
            % object bas to be exactly the same as the one read before.
            ttob =  ttob.reopen_to_write(test_f);
            ttob = ttob.put_sqw(sq_obj);
            ttob.delete();

            %assertEqual(exist(test_f,'file'),2);

            chob = binfile_v2_common_tester(test_f);

            tsq_obj = chob.get_sqw();
            chob.delete();

            [ok,mess]=equal_to_tol(sq_obj,tsq_obj,'ignore_str',true);
            assertTrue(ok,mess)

        end

        function test_activate_reopens_file_in_rb_if_read_given(obj)
            file_path = fullfile(obj.test_data_folder, 'w1d_d1d.sqw');
            bin_file = binfile_v2_common_tester(file_path);
            cleanup = onCleanup(@() bin_file.delete());
            bin_file.deactivate();
            assertFalse(bin_file.is_activated('read'));
            assertFalse(bin_file.is_activated('write'));

            bin_file.activate('read');

            assertTrue(bin_file.is_activated('read'));
            assertFalse(bin_file.is_activated('write'));

            permission = obj.get_opened_file_permission(file_path);
            assertEqual(permission, 'rb');
        end

        function test_activate_reopens_file_in_rbplus_if_write_given(obj)
            file_path = fullfile(obj.test_data_folder,'w1d_d1d.sqw');
            bin_file = binfile_v2_common_tester(file_path);
            cleanup = onCleanup(@() bin_file.delete());
            bin_file.deactivate();
            assertFalse(bin_file.is_activated('read'));
            assertFalse(bin_file.is_activated('write'));

            bin_file.activate('write');

            assertTrue(bin_file.is_activated('read'));
            assertTrue(bin_file.is_activated('write'));

            permission = obj.get_opened_file_permission(file_path);
            assertEqual(permission, 'rb+');

        end

        function test_error_raised_if_activating_file_with_bad_permission(obj)
            file_path = fullfile(obj.test_data_folder, 'w1d_d1d.sqw');
            bin_file = binfile_v2_common_tester(file_path);
            cleanup = onCleanup(@() bin_file.delete());
            bin_file.deactivate();

            f = @() bin_file.activate('not-a-permission');
            assertExceptionThrown(f, 'HORACE:horace_binfile_interface:invalid_argument');
        end

    end

    methods (Static)
        function permission = get_opened_file_permission(file_path)
            % Get the permission of an open file from its path
            %   If the file is not open the permission will be empty
            permission = '';

            if matlab_version_num() < 24.01
                file_ids = fopen('all');
            else
                file_ids = openFiles();
            end
            for i = 1:numel(file_ids)
                [open_file_path, open_permission] = fopen(file_ids(i));
                if strcmp(open_file_path, file_path)
                    permission = open_permission;
                    return;
                end
            end
        end
        %
    end % Methods
end

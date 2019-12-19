classdef test_dnd_binfile_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxiliary methods, available on this class
    %
    
    properties
        test_folder
    end
    
    methods
        function obj = test_dnd_binfile_common(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
        end
        %-----------------------------------------------------------------
        function obj = test_get_version(obj)
            to = dnd_binfile_common_tester();
            source = fullfile(fileparts(obj.test_folder),'test_symmetrisation','w1d_d1d.sqw');
            wrong_source = fullfile(fileparts(obj.test_folder),'common_data','96dets.par');
            
            
            f = @()(to.get_file_header('non-existing_file.sqw'));
            assertExceptionThrown(f,'SQW_FILE_IO:io_error');
            
            f = @()to.get_file_header(wrong_source);
            assertExceptionThrown(f,'SQW_FILE_IO:runtime_error');
            
            
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
            tob = dnd_binfile_common_tester();
            
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
            
            [f1,f2,is_last] = dnd_binfile_common.extract_field_range(base_str,filter1);
            assertFalse(is_last)
            assertEqual(f1,'f1_pos_');
            assertEqual(f2,'f4_pos_');
            
            
            filter2 = struct('f3','','f4','','f7','');
            
            [f1,f2,is_last] = dnd_binfile_common.extract_field_range(base_str,filter2);
            assertFalse(is_last)
            assertEqual(f1,'f3_pos_');
            assertEqual(f2,'f8_pos_');
            
            
            filter3 =struct('f4','','f7','','f10','');
            
            [f1,f2,is_last] = dnd_binfile_common.extract_field_range(base_str,filter3);
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
        %
        function obj = test_change_file_to_write(obj)
            tob = dnd_binfile_common();
            
            samp = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_sqw.sqw');
            f=@()(tob.set_file_to_update(samp));
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
            
            tob=tob.set_file_to_update(samp);
            
            assertTrue(tob.sqw_type)
            assertEqual(tob.num_dim,1)
            assertTrue(isa(tob,'faccess_sqw_v2'));
            
            
            test_f = fullfile(tmp_dir,'test_change_file_to_write.sqw');
            clob = onCleanup(@()delete(test_f));
            
            tob=tob.set_file_to_update(test_f);
            assertTrue(exist(test_f,'file')==2);
            
            tob=tob.delete();
            assertTrue(tob.sqw_type) % its still sqw reader, you know...
            assertEqual(tob.num_dim,'undefined')
            
        end
        %
        function obj = test_copy_constructor(obj)
            
            samp = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_d1d.sqw');
            tob = dnd_binfile_common_tester(samp);
            
            
            cob = dnd_binfile_common_tester(tob);
            
            d0 = tob.get_sqw();
            d1 = cob.get_sqw();
            
            assertEqual(d0,d1);
            
        end
        function obj = test_copy_constructor_write_perm(obj)
            
            samp = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_d1d.sqw');
            ttob = dnd_binfile_common_tester(samp);
            sq_obj = ttob.get_sqw();
            assertTrue(isa(sq_obj,'d1d'));
            
            test_f = fullfile(tmp_dir,'test_dnd_copy_constructor_write_perm.sqw');
            clob = onCleanup(@()delete(test_f));
            
            tob =  dnd_binfile_common_tester(sq_obj,test_f);
            cob = dnd_binfile_common_tester(tob);
            
            cob  = cob.put_sqw();
            cob.delete();
            
            chob = dnd_binfile_common_tester(test_f);
            
            tsq_obj = chob.get_sqw();
            tsq0_obj = tob.get_sqw();
            
            [ok,mess]=equal_to_tol(sq_obj,tsq_obj,'ignore_str',true);
            assertTrue(ok,mess)
            [ok,mess]=equal_to_tol(tsq0_obj,tsq_obj,'ignore_str',true);
            assertTrue(ok,mess)
            chob.delete();
            tob.delete();
        end
        %
        function obj = test_reopen_to_wrire(obj)
            
            samp = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_d1d.sqw');
            ttob = dnd_binfile_common_tester(samp);
            % important! -verbatim is critical here! without it we should 
            % reinitialize object to write!
            sq_obj = ttob.get_sqw('-verbatim');
            assertTrue(isa(sq_obj,'d1d'));
            
            test_f = fullfile(tmp_dir,'test_dnd_reopen_to_wrire.sqw');
            clob = onCleanup(@()delete(test_f));
            
            % using already initialized object to write new data.
            % its better to initialize object again as with this form
            % object bas to be exactly the same as the one read before.
            ttob =  ttob.reopen_to_write(test_f);
            ttob = ttob.put_sqw(sq_obj);
            ttob.delete();
            
            assertEqual(exist(test_f,'file'),2);
            
            chob = dnd_binfile_common_tester(test_f);
            
            tsq_obj = chob.get_sqw();
            chob.delete();
            
            [ok,mess]=equal_to_tol(sq_obj,tsq_obj,'ignore_str',true);
            assertTrue(ok,mess)
            
        end
        
        
    end
    
end


classdef test_dnd_binfile_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxliary methods, availble on this class
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
            f=@()(tob.set_file_to_write(samp));
            assertExceptionThrown(f,'SQW_FILE_IO:invalid_argument');
            
            tob=tob.set_file_to_write(samp);
            
            assertTrue(tob.sqw_type)
            assertEqual(tob.num_dim,1)
            assertTrue(isa(tob,'faccess_sqw_v2'));
            
            
            test_f = fullfile(tempdir,'test_set_file_to_write.sqw');
            clob = onCleanup(@()delete(test_f));
            
            tob=tob.set_file_to_write(test_f);
            assertTrue(exist(test_f,'file')==2);
            
            tob=tob.delete();
            assertTrue(tob.sqw_type) % its still sqw reader, you know...
            assertEqual(tob.num_dim,'undefined')
            
        end
        %

        
    end
    
end


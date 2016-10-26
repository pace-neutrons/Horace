classdef test_sqw_binfile_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    %
    
    
    properties
        test_folder
    end
    
    methods
        function obj = test_sqw_binfile_common(varargin)
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
            to = sqw_binfile_common_tester();
            source = fullfile(fileparts(obj.test_folder),'test_symmetrisation','w1d_d1d.sqw');
            wrong_source = fullfile(fileparts(obj.test_folder),'common_data','96dets.par');
            
            
            f = @()(to.get_header('non-existing_file.sqw'));
            assertExceptionThrown(f,'SQW_FILE_INTERFACE:io_error');
            
            [stream,fid] = to.get_header(wrong_source);
            co = onCleanup(@()fclose(fid));
            
            assertTrue(fid>0)
            assertEqual(numel(stream),1044);
            assertEqual(stream(1),uint8(57))
            fclose(fid);
            
            
            [stream,fid1] = to.get_header(source);
            co1 = onCleanup(@()fclose(fid1));
            
            assertTrue(fid1>0)
            assertEqual(numel(stream),1044);
            assertEqual(stream(1),uint8(6));
            assertEqual(stream(2),uint8(0));
            assertEqual(stream(3),uint8(0));
            assertEqual(stream(4),uint8(0));
            
        end
    end
    
end


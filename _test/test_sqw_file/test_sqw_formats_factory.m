classdef test_sqw_formats_factory <  TestCase %WithSave
    %Testing sqw-read-write factory
    %
    
    
    properties
        test_folder
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
        end
        %-----------------------------------------------------------------
        function obj = test_selection(obj)
            file_v2 = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_sqw.sqw');
            loader = sqw_formats_factory.instance().get_loader(file_v2);
            
            assertEqual(loader.file_version,'-v2');
            assertEqual(loader.filename,'w1d_sqw.sqw')
            assertEqual(loader.npixels,8031)
            
            
            file_v3 = fullfile(fileparts(obj.test_folder),...
                'test_sqw_file','test_sqw_file_read_write_v3.sqw');
            
            loader = sqw_formats_factory.instance().get_loader(file_v3);
            assertEqual(loader.file_version,'-v3');
            assertEqual(loader.filename,'test_sqw_file_read_write_v3.sqw')
            assertEqual(loader.npixels,7680)
            
            file_nonHor = fullfile(fileparts(obj.test_folder),...
                'test_sqw_file','testdata_base_objects.mat');
            fl = @()(sqw_formats_factory.instance().get_loader(file_nonHor));
            assertExceptionThrown(fl,'SQW_FORMATS_FACTORY:runtime_error')
            
            file_v0 = fullfile(fileparts(obj.test_folder),...
                'test_sqw_file','test_sqw_read_write_v0.sqw');
            loader = sqw_formats_factory.instance().get_loader(file_v0);
            assertEqual(loader.file_version,'-v0');
            assertEqual(loader.filename,'test_sqw_read_write_v0.sqw')
            assertEqual(loader.npixels,7680)
            
            file_dndv2 = fullfile(fileparts(obj.test_folder),...
                'test_symmetrisation','w1d_sqw.sqw');                
            loader = sqw_formats_factory.instance().get_loader(file_dndv2);
            assertEqual(loader.file_version,'-v2');
            assertEqual(loader.file_version,'-v2');            
            assertEqual(loader.filename,'test_sqw_read_write_v0.sqw')
            assertEqual(loader.npixels,7680)

            
        end
    end
    
end


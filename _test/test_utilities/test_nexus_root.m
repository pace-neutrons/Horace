classdef test_nexus_root< TestCase
    properties
        common_data_folder
    end
    methods
        function obj=test_nexus_root(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.common_data_folder = fullfile(herbert_root(),'_test','common_data');
        end
        
        function test_find_root(obj)
            test_file = fullfile(obj.common_data_folder,'MAP11014.nxspe');
            
            [root_nx_path,data_version,data_structure] = find_root_nexus_dir(test_file);
            
            assertEqual(root_nx_path,'/11014.spe');
            assertEqual(data_version,'1.1');            
        end
        %
        function test_two_groups_fails(obj)
            test_file = fullfile(obj.common_data_folder,'currently_not_supported_NXSPE.nxspe');
            
            try
                find_root_nexus_dir(test_file);
            catch Err
                assertEqual(Err.identifier,'ISIS_UTILITES:invalid_argument');
            end
        end
        %
        function test_two_groups_tested(obj)
            test_file = fullfile(obj.common_data_folder,'currently_not_supported_NXSPE.nxspe');
            
            [root_nx_path,data_version,data_structure] =...
                find_root_nexus_dir(test_file,'NXSPE','test_mode');  
            assertEqual(numel(root_nx_path),2);
            assertEqual(numel(data_version),2);            
            assertEqual(root_nx_path{1},'/11014.spe');
            assertEqual(data_version{1},'1.1');            

            assertEqual(root_nx_path{2},'/testNXSPEgroup');
            assertEqual(data_version{2},'1.');            
            
        end
        %
        function test_not_nexust_hdf(obj)
            test_file = fullfile(obj.common_data_folder,'group_search_tester.h5');            
            try
                find_root_nexus_dir(test_file);
            catch Err
                assertEqual(Err.identifier,'ISIS_UTILITES:invalid_argument');
            end
        end
        

    end
end


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
            pths = horace_paths;
            obj.common_data_folder = pths.test_common;
        end
        function test_dataset_info_file(obj)
            test_file = fullfile(obj.common_data_folder,'MAP11014.nxspe');

            [root_nx_path,data_version,data_struc] = find_root_nexus_dir(test_file);

            assertEqual(root_nx_path,'/11014.spe');
            assertEqual(data_version,'1.1');

            [dsi_struc,data_path] = find_dataset_info(test_file,'11014.spe');
            assertEqual(data_path,'/11014.spe');
            assertEqual(data_struc.Groups,dsi_struc);

        end


        function test_dataset_info_all(obj)
            test_file = fullfile(obj.common_data_folder,'MAP11014.nxspe');

            [root_nx_path,data_version,data_struc] = find_root_nexus_dir(test_file);

            assertEqual(root_nx_path,'/11014.spe');
            assertEqual(data_version,'1.1');

            [dataset_structure,ds_grouppath] = find_dataset_info(data_struc,'11014.spe');
            assertEqual(ds_grouppath,'/11014.spe');
            assertEqual(numel(dataset_structure.Groups),4)
            assertEqual(numel(dataset_structure.Datasets),2)
            assertEqual(numel(dataset_structure.Attributes),1)
        end
        %
        function test_dataset_info(obj)
            test_file = fullfile(obj.common_data_folder,'MAP11014.nxspe');

            [root_nx_path,data_version,data_struc] = find_root_nexus_dir(test_file);

            assertEqual(root_nx_path,'/11014.spe');
            assertEqual(data_version,'1.1');

            [dataset_structure,ds_grouppath] = find_dataset_info(data_struc,'11014.spe');
            assertEqual(ds_grouppath,'/11014.spe');
            [dataset_info,ds_grouppath] = find_dataset_info(dataset_structure,'data','data');
            assertEqual(ds_grouppath,'/11014.spe/data/data');
            assertEqual(dataset_info.Name,'data');
            assertEqual(dataset_info.Dataspace.Size,[30 28160]);

            [dataset_info,ds_grouppath] = find_dataset_info(dataset_structure,'data','polar');
            assertEqual(ds_grouppath,'/11014.spe/data/polar');
            assertEqual(dataset_info.Name,'polar');
            assertEqual(dataset_info.Dataspace.Size,28160);


            [dataset_info,ds_grouppath] = find_dataset_info(dataset_structure,'fermi','energy');
            assertEqual(ds_grouppath,'/11014.spe/instrument/fermi/energy');
            assertEqual(dataset_info.Name,'energy');
            assertEqual(dataset_info.Dataspace.Size,1);

            [dataset_info,ds_grouppath] = find_dataset_info(dataset_structure,'fermi','non_existing');
            assertTrue(isempty(ds_grouppath));
            assertEqual(dataset_info,dataset_structure);

            [dataset_info,ds_grouppath] = find_dataset_info(dataset_structure,'non_existing','energy');
            assertTrue(isempty(ds_grouppath));
            assertEqual(dataset_info,dataset_structure);

        end
        %
        function test_find_root(obj)
            test_file = fullfile(obj.common_data_folder,'MAP11014.nxspe');

            [root_nx_path,data_version] = find_root_nexus_dir(test_file);

            assertEqual(root_nx_path,'/11014.spe');
            assertEqual(data_version,'1.1');
        end
        %
        function test_two_groups_fails(obj)
            test_file = fullfile(obj.common_data_folder,'currently_not_supported_NXSPE.nxspe');

            f = @()find_root_nexus_dir(test_file);

            assertExceptionThrown(f,'HERBERT:isis_utilities:invalid_argument');
        end
        %
        function test_two_groups_tested(obj)
            test_file = fullfile(obj.common_data_folder,'currently_not_supported_NXSPE.nxspe');

            [root_nx_path,data_version] =...
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
            f = @()find_root_nexus_dir(test_file);
            assertExceptionThrown(f,'HERBERT:isis_utilities:invalid_argument');
        end


    end
end

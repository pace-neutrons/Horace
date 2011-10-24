classdef test_spe_hdf_filestructure< TestCase
% this test fixes spe_hdf_filestructure of current versions and should be ammended as 
% future versions become valid
    properties 
    end
    methods       
        % 
        function this=test_spe_hdf_filestructure(name)
            this = this@TestCase(name);
        end
        function setUp(this)
            [rez,version]=spe_hdf_filestructure();
            if version~=1
                error('TEST_HDF_FILESTRUCTURE:set_up','filestructure version have changed but the test has not');
            end
        end
          % tests themself
        function test_default_fs(this)       
            % two versions are currently supported;
            assertEqual(numel(spe_hdf_filestructure()),2);          
        end
       function test_hdf_filestructure_v1(this)       
            % two versions are currently supported;
            struct=spe_hdf_filestructure(1);
            assertEqual(struct.spe_hdf_version,2);
            assertEqual(struct.spe_hdf_file_ext,'.spe_h5');
            data_field_names={'Ei'  'En_Bin_Bndrs'  'S(Phi,w)'  'Err'  'spe_hdf_version'};
            assertEqual(data_field_names,struct.data_field_names);
            assertEqual({},struct.data_attrib_names);
       end
       function test_hdf_filestructure_v2(this)       
            % two versions are currently supported;
            struct=spe_hdf_filestructure(2);
            assertEqual(struct.spe_hdf_version,3);
            assertEqual(struct.spe_hdf_file_ext,'.nxspe');
            data_field_names={...
             'NXSPE_info/fixed_energy','data/energy', 'data/data', 'data/error', ...
             'definition','NXSPE_info/psi',...
             'data/polar','data/azimuthal','data/polar_width','data/azimuthal_width','data/distance'};
            assertEqual(data_field_names,struct.data_field_names);
            data_attrib_names= {'units'  'units'  ''  ''  'version'  'units'  ''  ''  ''  ''};
            assertEqual(data_attrib_names,struct.data_attrib_names);
        end
        
    end
end
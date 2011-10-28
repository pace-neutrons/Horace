classdef test_loader_utilites< TestCase
    properties 
    end
    methods       
        % 
        function this=test_loader_utilites(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_FormatCurrentlyNotSupported(this)               
            f = @()find_root_nexus_dir('currently_not_supported_NXSPE.nxspe','NXSPE');            
            % more then one nxspe folder is not supported at the moment
            assertExceptionThrown(f,'ISIS_UTILITES:invalid_argument');
        end               
        function test_CorrectHeader(this)       
            [result,version] = find_root_nexus_dir('MAP11014.nxspe','NXSPE'); % file name has loose relation to the result
            assertEqual(result,'/11014.spe');
            assertEqual(version,'1.1');            
        end               
        function test_parse_par_arg_wrong(this)
            f=@()parse_par_arg('file_name',1);
            assertExceptionThrown(f,'PARSE_PAR_ARG:invalid_argument');            
        end
         function test_parse_par_2arg(this)
            [f_name,key]=parse_par_arg('file_name','-hor');
            assertEqual(f_name,'file_name');
            assertEqual(key,'-hor');            
         end        
         function test_parse_par_3arg(this)
            [f_name,key]=parse_par_arg('file_name','other_file_name','-hor');
            assertEqual(f_name,'other_file_name');
            assertEqual(key,'-hor');            
        end        
         function test_parse_par_Warnarg(this)
            [f_name,key]=parse_par_arg('file_name','other_file_name',20);
            assertEqual(f_name,'other_file_name');
            assertEqual(key,'-hor');            
         end   
% FIND_DATASET_INFO
         function test_correct_rootDS(this)       
             [DS_info,ds_path] = find_dataset_info('MAP11020.spe_h5','',''); 
             assertTrue(all(ismember(fieldnames(DS_info),...
             {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
             assertEqual(ds_path,'/');            
         end         
        function test_correct_hdf_srtuct(this)
            finf = hdf5info('MAP11020.spe_h5');
            [DS_info,ds_path] = find_dataset_info(finf,'',''); 
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/');            
        end            
       function test_correct_root_srtuct(this)
            finf = hdf5info('MAP11020.spe_h5');
            [DS_info,ds_path] = find_dataset_info(finf.GroupHierarchy,'',''); 
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/');            
       end          
       function test_correct_DS_found(this)
            [DS_info,ds_path] = find_dataset_info('MAP11020.spe_h5','','S(Phi,w)'); 
            assertEqual(DS_info.Dims,[30,28160]);
            assertEqual(ds_path,'/S(Phi,w)');                              
       end     
       function test_correct_Folder_found(this)
            [DS_info,ds_path] = find_dataset_info('MAP11014.nxspe','data',''); 
            
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/11014.spe/data');                              
       end
       function test_correct_DSinCorrectFolder_found(this)
            [DS_info,ds_path] = find_dataset_info('MAP11014.nxspe','data','data'); 
            
            assertEqual(DS_info.Dims,[30,28160]);
            assertEqual(ds_path,'/11014.spe/data/data');                              
       end           
       function test_correct_DSinCorrect2Folder_found(this)
            [DS_info,ds_path] = find_dataset_info('MAP11014.nxspe','data','azimuthal'); 
            
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
       end     
      function test_correct_DS2_found(this)
            [DS_info,ds_path] = find_dataset_info('MAP11014.nxspe','','azimuthal'); 
            
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
      end            
       function test_correct_DS3_found(this)
            [DS_info,ds_path] = find_dataset_info('group_search_tester.h5','','dsa1cgI4'); 
            
            assertEqual(DS_info.Dims,[2,2]);
            assertEqual(ds_path,'/a1/cg/dsa1cgI4');                              
       end           
       function test_correct_Folder2_found(this)
            [DS_info,ds_path] = find_dataset_info('group_search_tester.h5','a3',''); 
            
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/a3');                              
       end            
       function test_correct_FolderInSubstr_found(this)       
            [result,version,data_struct] = find_root_nexus_dir('MAP11014.nxspe','NXSPE'); % file name has loose relation to the result
            assertEqual(result,'/11014.spe');
            [DS_info,ds_path] = find_dataset_info(data_struct,'data','azimuthal');       
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
       end   
    end
end


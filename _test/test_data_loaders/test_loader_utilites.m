classdef test_loader_utilites< TestCase
    properties 
          test_data_path;        
    end
    methods       
        % 
        function fn=f_name(this,short_filename)
            fn = fullfile(this.test_data_path,short_filename);
        end
        
        function this=test_loader_utilites(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');                                            
        end
        % tests themself
        function test_FormatCurrentlyNotSupported(this)               
            f = @()find_root_nexus_dir(f_name(this,'currently_not_supported_NXSPE.nxspe'),'NXSPE');        
            % more then one nxspe folder is not supported at the moment
            assertExceptionThrown(f,'ISIS_UTILITES:invalid_argument');
        end               
        function test_CorrectHeader(this)       
            [result,version] = find_root_nexus_dir(f_name(this,'MAP11014.nxspe'),'NXSPE'); % file name has loose relation to the result
            assertEqual(result,'/11014.spe');
            assertEqual(version,'1.1');            
        end               
        function test_parse_par_arg_wrong(this)
            absl = a_loader();
            f=@()check_par_file(absl,'.spe','file_name',1);
            assertExceptionThrown(f,'CHECK_FILE_EXIST:wrong_argument');            
        end
         function test_parse_par_2arg(this)
            absl = a_loader();
            [absl,key,file_name]=check_par_file(absl,'.par',f_name(this,'demo_par.PAR'),'-hor');
            assertEqual(file_name,f_name(this,'demo_par.PAR'));
            assertEqual(key,true);            
            if ispc
                assertEqual(absl.par_file_name,f_name(this,'demo_par.par'));                        
            else
                assertEqual(absl.par_file_name,f_name(this,'demo_par.PAR'));                                        
            end
         end        
         function test_parse_par_3arg(this)
            absl = a_loader();
            absl.par_file_name = f_name(this,'demo_par.PAR');
            [absl,key,file_name]=check_par_file(absl,'.par',f_name(this,'map_4to1_jul09.par'),'-hor');             
            assertEqual(file_name,f_name(this,'map_4to1_jul09.par'));
            assertEqual(absl.par_file_name,f_name(this,'map_4to1_jul09.par'));                                    
            assertEqual(key,true);
        end        
         function test_parse_par_Warnarg(this)
            absl = a_loader();
            absl.par_file_name = f_name(this,'demo_par.PAR');            
            [absl,key,file_name]=check_par_file(absl,'.par',f_name(this,'map_4to1_jul09.par'),20);                          
            assertEqual(file_name,f_name(this,'map_4to1_jul09.par'));
            assertEqual(absl.par_file_name,f_name(this,'map_4to1_jul09.par'));                                    
            assertEqual(key,true);
         end   
% FIND_DATASET_INFO
         function test_correct_rootDS(this)       
             [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11020.spe_h5'),'',''); 
             assertTrue(all(ismember(fieldnames(DS_info),...
             {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
             assertEqual(ds_path,'/');            
         end         
        function test_correct_hdf_srtuct(this)
            finf = hdf5info(f_name(this,'MAP11020.spe_h5'));
            [DS_info,ds_path] = find_dataset_info(finf,'',''); 
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/');            
        end            
       function test_correct_root_srtuct(this)
            finf = hdf5info(f_name(this,'MAP11020.spe_h5'));
            [DS_info,ds_path] = find_dataset_info(finf.GroupHierarchy,'',''); 
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/');            
       end          
       function test_correct_DS_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11020.spe_h5'),'','S(Phi,w)'); 
            assertEqual(DS_info.Dims,[30,28160]);
            assertEqual(ds_path,'/S(Phi,w)');                              
       end     
       function test_correct_Folder_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11014.nxspe'),'data',''); 
            
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/11014.spe/data');                              
       end
       function test_correct_DSinCorrectFolder_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11014.nxspe'),'data','data'); 
            
            assertEqual(DS_info.Dims,[30,28160]);
            assertEqual(ds_path,'/11014.spe/data/data');                              
       end           
       function test_correct_DSinCorrect2Folder_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11014.nxspe'),'data','azimuthal'); 
            
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
       end     
      function test_correct_DS2_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'MAP11014.nxspe'),'','azimuthal'); 
            
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
      end            
       function test_correct_DS3_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'group_search_tester.h5'),'','dsa1cgI4'); 
            
            assertEqual(DS_info.Dims,[2,2]);
            assertEqual(ds_path,'/a1/cg/dsa1cgI4');                              
       end           
       function test_correct_Folder2_found(this)
            [DS_info,ds_path] = find_dataset_info(f_name(this,'group_search_tester.h5'),'a3',''); 
            
            assertTrue(all(ismember(fieldnames(DS_info),...
            {'Filename' 'Name' 'Groups' 'Datasets' 'Datatypes' 'Links' 'Attributes'})));
            assertEqual(ds_path,'/a3');                              
       end            
       function test_correct_FolderInSubstr_found(this)       
            [result,version,data_struct] = find_root_nexus_dir(f_name(this,'MAP11014.nxspe'),'NXSPE'); % file name has loose relation to the result
            assertEqual(result,'/11014.spe');
            [DS_info,ds_path] = find_dataset_info(data_struct,'data','azimuthal');       
            assertEqual(DS_info.Dims,28160);
            assertEqual(ds_path,'/11014.spe/data/azimuthal');                              
       end   
    end
end


classdef test_a_loader< TestCase
    properties 
       test_data_path;        
    end
    methods       
        % 
        function this=test_a_loader(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');           
        end
        
        function test_abstract_methods(this)
            al=a_loader_tester();
            
            f = @()al.can_load('some_file_name');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');
            
            %f = @()al.get_file_extension();
            %assertExceptionThrown(f,'A_LOADER:abstract_method_called');            
            
            f = @()al.load_data('new_fileName');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');                        
        %
            
            f = @()al.get_data_info();
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');
            
            f = @()al.init('data_file_name');
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');            

        end
        function test_constructors(this)
            def_fields = {'aaa','bbb','c'};
            al=a_loader_tester();
            al.loader_defines = def_fields;
            for i=1:numel(def_fields)
                assertEqual(al.loader_defines{i},def_fields{i});
            end
            
            def_fields ={'cc'};
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al1=a_loader_tester(par_file);
            al1.loader_defines=def_fields;
            
            [fp,fn,fext]=fileparts(al1.par_file_name);
            assertEqual('demo_par',fn);
            assertEqual('.par',fext);
            for i=1:numel(def_fields)
                assertEqual(al1.loader_defines{i},def_fields{i});
            end
            
            [par,al1]=al1.load_par();
            
            al2 = a_loader_tester(al1);
            
            assertEqual(par,al2.det_par);
           
        end
        function test_set_par_file(this)
            par_file = fullfile(this.test_data_path,'map_4to1_jul09.par');
            %
            al=a_loader_tester();
            al.par_file_name = par_file;
            
            [fp,fn,fext]=fileparts(al.par_file_name);
            assertEqual('map_4to1_jul09',fn);
            assertEqual('.par',fext);
            
            
            assertEqual(36864,al.n_detectors);
        end
        
        function test_load_par_fails_no_file(this)            
            al=a_loader_tester();            
            f = @()al.load_par();
            assertExceptionThrown(f,'A_LOADER:load_par');                      
        end
        
        function test_load_ASCII_par_binary(this)             
            al=a_loader_tester();
            par_file = fullfile(this.test_data_path,'demo_par.par');
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',1,'-buffer');
            [par,al] = al.load_par(par_file,'-horace');
            set(herbert_config,'use_mex',old_state,'-buffer');

            [fpath,fname,fext]= fileparts(al.par_file_name);                        
            if ispc
                assertEqual([fname,fext],'demo_par.par');  
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))
            assertEqual(28160,al.n_detectors)
            
            set(herbert_config,'use_mex',old_state,'-buffer');                       
        end
        
        function test_load_ASCII_par_matlab(this)             
            al=a_loader_tester();
            par_file = fullfile(this.test_data_path,'demo_par.par');            
            
            old_state=get(herbert_config,'use_mex');
            set(herbert_config,'use_mex',0,'-buffer');
            [par,al] = al.load_par(par_file,'-hor');
            set(herbert_config,'use_mex',old_state,'-buffer');

            [fpath,fname,fext] = fileparts(al.par_file_name);     
            if ispc
                assertEqual([fname,fext],'demo_par.par');  
            else
                assertEqual([fname,fext],'demo_par.PAR');
            end
            
            assertTrue(all(ismember({'filename','filepath','x2','phi','azim','width','height','group'},fields(par))));
            assertTrue(all(ismember(fields(par),{'filename','filepath','x2','phi','azim','width','height','group'})));            
            assertEqual(28160,numel(par.x2))  
            assertEqual(28160,al.n_detectors)
        end
% LOAD PAR forcing mex files     
        function test_wrong_n_columns_fails(this)               
            al=a_loader_tester();
            par_file = fullfile(this.test_data_path,'wrong_demo_par_7Col.PAR');            

            f = @()al.load_par(par_file,'-hor');          
            use_mex=get(herbert_config,'use_mex_C');
            force_mex_if_use_mex=get(herbert_config,'force_mex_if_use_mex');   
            set(herbert_config,'use_mex_C',true,'force_mex_if_use_mex',true,'-buffer');            
            % should throw; par file has 7 columns
            assertExceptionThrown(f,'A_LOADER:get_par');
            set(herbert_config,'use_mex_C',use_mex,'force_mex_if_use_mex',force_mex_if_use_mex,'-buffer');                        

        end        
        function test_mslice_par(this)
           al=a_loader_tester();
           par_file = fullfile(this.test_data_path,'demo_par.par');

           [par,al]=al.load_par(par_file);          
           assertEqual([6,28160],size(par));
            
           [fpath,fname,fext] = fileparts(al.par_file_name);            
           if ispc
                assertEqual([fname,fext],'demo_par.par'); 
            else
                assertEqual([fname,fext],'demo_par.PAR');            
            end
        end 
        function test_get_par_info(this)
            
            par_file = fullfile(this.test_data_path,'demo_par.par');
            ndet = a_loader_tester.get_par_info(par_file);
            assertEqual(28160,ndet)
            
            f=@()a_loader_tester.get_par_info('non_existing_file');
            assertExceptionThrown(f,'A_LOADER:io_error');
            
            other_file_name = fullfile(this.test_data_path,'MAP11014.nxspe');
            f=@()a_loader_tester.get_par_info(other_file_name);
            assertExceptionThrown(f,'A_LOADER:invalid_par_file');
            
        end
        function test_delete(this)             
            al=a_loader_tester();
            par_file = fullfile(this.test_data_path,'demo_par.par');
           [par,al] = al.load_par(par_file,'-hor');
           al.S = zeros(10,100);
           al.ERR = zeros(10,100);
           al.en=1:100;
           
           al=al.delete();
           assertTrue(isempty(al.S));
           assertTrue(isempty(al.ERR));
           assertTrue(isempty(al.det_par));           
        end
       function test_get_run_info_binary_par(this)

            wrong_par_file = fullfile(this.test_data_path,'wrong_bin_par.par');
            
            f = @()a_loader_tester(wrong_par_file);
                               
            %f = @()get_run_info(loader);
            assertExceptionThrown(f,'A_LOADER:invalid_par_file');
       end            

       function test_is_loader_defined(this)


            lt = a_loader_tester();
                               
            %f = @()get_run_info(loader);
            [ok,mess]=lt.is_loader_valid();
            assertEqual(-1,ok);
            assertEqual('loader undefined',mess);            
            lt.S = ones(5,3);
            
            [ok,mess]=lt.is_loader_valid();            
            assertEqual(0,ok);
            assertEqual('size(S) ~= size(ERR)',mess);            
            

            lt.ERR = zeros(5,3);
            [ok,mess]=lt.is_loader_valid();            
            assertEqual(0,ok);
            assertEqual('size(S,1)+1 ~= size(en)',mess);            

            lt.en = ones(6,1);
            [ok,mess]=lt.is_loader_valid();            
            assertEqual(-1,ok);
            assertEqual('loader undefined',mess);            

            par_file = fullfile(this.test_data_path,'demo_par.par');            
            lt.par_file_name = par_file;
            [ok,mess]=lt.is_loader_valid();
            
            assertEqual(0,ok);
            assertTrue(strncmp('inconsistent data and par file',mess,30));

            lt.S = ones(5,28160);            
            lt.ERR = zeros(5,28160);
            [ok,mess]=lt.is_loader_valid();            
            assertEqual(1,ok);
            assertTrue(isempty(mess));

       end 
       
       function test_is_loader_defined_on_file(this)
            spe_file  = fullfile(tempdir(),'abstract_test_file.altf');
            f = fopen(spe_file,'w');
            fclose(f);
            
            lt = a_loader_tester();    
            lt.file_name = spe_file;
            
            f = @()lt.is_loader_valid();
            assertExceptionThrown(f,'A_LOADER:abstract_method_called');
            
            delete(spe_file);
       end
       function test_set_par(this)
            par_file = fullfile(this.test_data_path,'demo_par.par');           
            al=a_loader_tester(par_file);
           
            assertEqual(28160,al.n_detectors);
            assertTrue(isempty(al.det_par));
           
            al.par_file_name = '';
            assertTrue(isempty(al.n_detectors));

            al.par_file_name = par_file;
            assertEqual(28160,al.n_detectors);
            
            [par,al] = al.load_par();
            assertEqual(par,al.det_par);            
            
            al.det_par = ones(6,10);
            assertEqual(10,al.n_detectors);
            assertTrue(isempty(al.par_file_name));
            
            al.det_par = [];
            assertTrue(isempty(al.n_detectors));
            assertTrue(isempty(al.par_file_name));
       end
       function test_defined_fields(this)
          al=a_loader_tester();           
          assertTrue(isempty(al.defined_fields()));
       end
       
       function test_get_run_info(this)
            al=a_loader_tester();
            f = @()al.get_run_info();
            assertExceptionThrown(f,'A_LOADER:get_run_info');
            
            par_file = fullfile(this.test_data_path,'demo_par.par');
            al.par_file_name = par_file;
            f = @()al.get_run_info();
            assertExceptionThrown(f,'A_LOADER:get_run_info');
            
       end
        
    end
end


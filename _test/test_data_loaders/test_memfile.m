classdef test_memfile< TestCase
    %
    %     $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    properties
        test_data_path;
    end
    methods
        function this=test_memfile(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
            
        end
        
        function test_memfile_work(this)
            
            mf=memfile();
            assertTrue(isempty(mf.S));
            assertTrue(isempty(mf.ERR));
            assertTrue(isempty(mf.file_name));
            
            
            mf.S=ones(10,20);
            assertTrue(is_string(mf.S));
            assertEqual(20,mf.n_detectors);
            assertTrue(isempty(mf.ERR));
            
            mf.ERR=zeros(10,20);
            assertTrue(is_string(mf.S));
            assertTrue(is_string(mf.ERR));
            assertEqual(20,mf.n_detectors);
            
            mf.en=1:11;
            assertEqual(20,mf.n_detectors);
            assertEqual(mf.S,ones(10,20));
            assertEqual(mf.ERR,zeros(10,20));
            
            [ok,mess,ndet,en]=mf.is_loader_valid();
            assertEqual(1,ok)
            assertTrue(isempty(mess));
            assertEqual(20,ndet);
            assertEqual((1:11)',en);
            
            df=mf.loader_can_define();
            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors'},df);
            
            really=mf.defined_fields();
            assertEqual({'S','ERR','en','n_detectors'},really);
            
            mf=mf.save('first_memfile');
            
            mf1=memfile();
            assertTrue(mf1.can_load('first_memfile'));
            
            mf1=memfile('first_memfile');
            assertTrue(isempty(mf1.S));
            assertTrue(isempty(mf1.ERR));
            assertEqual(20,mf1.n_detectors);
            assertEqual(mf.en,mf1.en);
            
            mf1=mf1.load();
            
            assertEqual(mf1,mf);
            % clear all stored memfiles from memory
            mem_file_fs.instance().format();
        end
        function test_memfile_constr1(this)
            % clear all stored memfiles from memory
            mem_file_fs.instance().format();
            
            
            f=@()memfile('some_memfile.mem');
            assertExceptionThrown(f,'MEMFILE_FS:load_file');
            
            mf=memfile();
            mf.S=ones(10,20);
            mf.ERR=zeros(10,20);
            mf.en =(0:1.1:11);
            mf.det_par = ones(6,20);
            mf.efix = 11;
            mf.psi  = 10;
            assertEqual(ones(10,20),mf.S);
            assertEqual(zeros(10,20),mf.ERR);
            
            mf.save('some_memfile.mem');
            
            % other file does not exist;
            %mf.file_name = 'other_file.memfile';
            ws=warning('off','MATLAB:subsasgnMustHaveOutput');            
            f=@()subsasgn(mf,struct('type','.','subs','file_name'),'other_file.mem');
            assertExceptionThrown(f,'A_LOADER:set_file_name');
            warning(ws);
            
            
            mf1=memfile();
            mf1.file_name='some_memfile.mem';
            mf1=mf1.load_data();
            assertEqual(ones(10,20),mf.S);
            assertEqual(zeros(10,20),mf.ERR);
            
            really=mf1.defined_fields();
            assertEqual({'S','ERR','en','efix','psi','n_detectors'},really);
            
            [det,mf1]=mf1.load_par();
            really=mf1.defined_fields();
            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors'},really);
            
            
            [ok,mess,ndet,en]=mf1.is_loader_valid();
            assertEqual(1,ok)
            assertTrue(isempty(mess));
            assertEqual(20,ndet);
            assertEqual((0:1.1:11)',en);
            
            % clear all stored memfiles from memory
            mem_file_fs.instance().format();
        end
        function test_memfile_det_par(this)
            
            par_file = fullfile(this.test_data_path,'demo_par.par');
            mf=memfile();
            mf.S=ones(10,28160);
            mf.ERR=zeros(10,28160);
            mf.en =(0:1.1:11);
            mf.efix = 11;
            mf.psi  = 10;
            mf.save('some_memfile.mem');
            clear mf;
            
            mf=memfile('some_memfile.mem',par_file);
            assertTrue(isempty(mf.S));
            assertTrue(isempty(mf.ERR));
            
            
            mf=mf.load_data();
            assertEqual(ones(10,28160),mf.S);
            assertEqual(zeros(10,28160),mf.ERR);
            
            really=mf.defined_fields();
            assertEqual({'S','ERR','en','efix','psi','n_detectors'},really);
            
            [det,mf]=mf.load_par();
            really=mf.defined_fields();
            assertEqual({'S','ERR','en','efix','psi','det_par','n_detectors'},really);
            
            det1=get_par(par_file);
            ok=equal_to_tol(det,det1,1.e-5);
            assertTrue(ok);
            
            [ok,mess,ndet,en]=mf.is_loader_valid();
            assertEqual(1,ok)
            assertTrue(isempty(mess));
            assertEqual(28160,ndet);
            assertEqual((0:1.1:11)',en);
            % clear all stored memfiles from memory
            mem_file_fs.instance().format();
            
        end
        
    end
end

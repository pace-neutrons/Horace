classdef test_mem_file_fs< TestCase
    %
    %     $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
    %
    properties
        test_data_path;
    end
    methods
        function this=test_mem_file_fs(name)
            this = this@TestCase(name);
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
            
            
        end
        
        function this=setUp(this)
            mem_file_fs.instance().format();
        end
        
        function this=tearDown(this)
            mem_file_fs.instance().format();
        end
        
        function test_mem_file_fs_work(this)
            n_files = mem_file_fs.instance().get_numfiles();
            assertEqual(0,n_files)
            
            files = mem_file_fs.instance().ls();
            assertTrue(isempty(files));
            
            f=@()mem_file_fs.instance().save_file('test_file','arbitrary_contents');
            assertExceptionThrown(f,'MEMFILE_FS:save_file')
            
            
            mf1=memfile();
            mf2=memfile();
            
            mf1.S=ones(10,3);
            mf1.ERR=ones(10,3);
            
            mem_file_fs.instance().save_file('test_file1',mf1);
            mem_file_fs.instance().save_file('test_file2',mf2);
            
            n_files = mem_file_fs.instance().get_numfiles();
            assertEqual(2,n_files)
            files = mem_file_fs.instance().ls();
            assertTrue(all(ismember({'test_file1','test_file2'},files)));
            
            f = @()mem_file_fs.instance().load_file('missing_file');
            assertExceptionThrown(f,'MEMFILE_FS:load_file')
            
            %
            exist=mem_file_fs.instance().file_exist('missing_file');
            assertFalse(exist);
            exist=mem_file_fs.instance().file_exist('test_file2');
            assertTrue(exist);
            
            
            mfl=mem_file_fs.instance().load_file('test_file1');
            assertEqual(mf1,mfl);
            
            mem_file_fs.instance().format();
            n_files = mem_file_fs.instance().get_numfiles();
            assertEqual(0,n_files)
            
            files = mem_file_fs.instance().ls();
            assertTrue(isempty(files));
            
        end
        
    end
end

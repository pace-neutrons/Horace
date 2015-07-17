classdef test_sqw_main < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tempdir();
        tests_dir;
    end
    
    methods
        function this=test_sqw_main(name)
            this = this@TestCase(name);
            class_dir = fileparts(which('test_sqw_main.m'));
            this.tests_dir = fileparts(class_dir);
        end
        
        function this=test_sqw_constructor (name)
            %
            data=data_sqw_dnd();
            sqw_obj=sqw(data);
            assertTrue(sqw_obj.data.dnd_type)
            
        end
        function this = test_read_sqw(this)
            test_data = fullfile(this.tests_dir,'test_change_crystal','wref.sqw');
            out_dnd_file = fullfile(this.out_dir,'test_sqw_main_test_read_sqw_dnd.sqw');
            cleanup_obj=onCleanup(@()delete(out_dnd_file));
            
            sqw_data = read_sqw(test_data);
            assertTrue(isa(sqw_data,'sqw'))
            
            assertElementsAlmostEqual(sqw_data.data.alatt,[2.8700 2.8700 2.8700],'absolute',1.e-4);
            assertElementsAlmostEqual(size(sqw_data.data.npix),[21,20]);
            assertElementsAlmostEqual(sqw_data.data.pax,[2,4]);
            assertElementsAlmostEqual(sqw_data.data.iax,[1,3]);
            
            
            test_dnd = d2d(sqw_data);
            [targ_path,targ_file,fext] = fileparts(out_dnd_file);
            save(test_dnd,out_dnd_file)
            loaded_dnd = read_dnd(out_dnd_file);
            assertTrue(isa(loaded_dnd,'d2d'))
            %
            test_dnd.filename = [targ_file,fext];
            test_dnd.filepath = [targ_path,filesep];
            
            [ok,mess]=equal_to_tol(loaded_dnd,test_dnd);
            assertTrue(ok,mess)
        end
    end
end
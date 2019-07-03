classdef test_mfit_settings < TestCase
    properties
    end
    methods
        %
        function this=test_mfit_settings(name)
            if nargin < 1
                name = 'test_mfit_settings';
            end
            this = this@TestCase(name);
        end
        
        function test_set_multifun(this)
            ds1 = IX_dataset_1d();
            ds2 = IX_dataset_1d();            
            mfc=mfclass(ds1,ds2);
            funs = {@(x,p)(1+p*x),@(x,p)(p+x.^2)};
            par = {1,1};
            free = {1,1};            
            mfc = mfc.set_fun(funs,par,free);
            assertTrue(mfc.local_foreground);
        end
   
           
    end
    
end


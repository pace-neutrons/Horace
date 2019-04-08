classdef test_rundata_rm_masked< TestCase
    %
    % $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_rundata_rm_masked(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_throws_on_empty_rundata(this)
            f = @()rm_masked(rundata());
            assertExceptionThrown(f,'RUNDATA:rm_masked');
        end
        function test_throws_on_inconsisten_rundata(this)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.det_par=ones(6,3);
            f = @()rm_masked(run);
            assertExceptionThrown(f,'RUNDATA:rm_masked');
        end
        function test_works_do_nothing(this)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=ones(6,5);
            [s,err,det]=rm_masked(run);
            
            assertEqual(run.S,s);
            assertEqual(run.ERR,err);
            assertEqual(run.det_par,det);
        end
        function test_works_removesNAN(this)
            run=rundata();
            run.S=ones(3,5);
            run.ERR=ones(3,5);
            run.en = 1:4;
            run.det_par=get_hor_format(ones(6,5),'fffff');
            
            run.S(1,1)=NaN;
            
            [s,err,det]=rm_masked(run);
            
            assertEqual(size(s),[3,4]);
            assertEqual(size(err),size(s));
            assertEqual(numel(det.width),4);
        end
        
    end
end


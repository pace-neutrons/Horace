classdef testDetectorsConstructor0Par < TestCase
    properties 
        det
    end
    methods       
        % 
        function this=testDetectorsConstructor0Par(name)
            this = this@TestCase(name);
        end
        function setUp(this)         
            par=ones(5,10);
            this.det=detectors_par(par);
        end  
        function teadDown(this)
            delete(this.det);
        end
        % tests themself
        function test0ParNumel(this)       
            assertEqual(numel(this.det.phi),10);
        end
        function testDefaultPhiSetRight(this)
            assertEqual(min(this.det.phi),1);            
            assertEqual(max(this.det.phi),1);                        
        end
        function testWrongParFile(this)
            f  = @()detectors_par([1,2]);
            % constructor throws on wrong par-array
            assertExceptionThrown(f,'DETECTORS_PAR:constructor');
        end
        function testLoadParThrowNonexistent(this)
            f = @()load_par(this.det);
            % constructor throws on undefined par-file
            assertExceptionThrown(f,'DETECTORS_PAR:load_par');            
        end
    end
end
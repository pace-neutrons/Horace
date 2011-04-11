classdef testDetectorsConstructor3Par < TestCase
    properties 
        det
    end
    methods       
        % 
        function this=testDetectorsConstructor3Par(name)
            this = this@TestCase(name);
        end
        function setUp(this)
            this.det = detectors_par(100,-60,20);
        end  
        function teadDown(this)
            delete(this.det);
        end
        % tests themself
        function testDefaultConstructorNumel(this)       
            assertEqual(numel(this.det.phi),100);
        end
        function testDefaultPhiSetRight(this)
            assertEqual(min(this.det.phi),-60);            
            assertEqual(max(this.det.phi),20);                        
        end
    end
end
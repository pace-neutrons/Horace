classdef testDetectorsMethods < TestCase
    properties 
        det
    end
    methods       
        % 
        function this=testDetectorsMethods(name)
            this = this@TestCase(name);
        end
        function setUp(this)
             this.det = detectors_par(100,-20,20);
        end  
        function teadDown(this)
            delete(this.det);
        end
     %--------------------------------------------------------------------------
        function testNDetectors(this)       
            assertEqual(getNDetectors(this.det),100);
        end
        %
        function test_getDetStruct(this)
            det_str=getDetStruct(this.det);
            field_names = fields(det_str);
           % load par throws on undefined new par-file
            assertEqual(ISMEMBER({'filename','filepath','x2','group','phi','azim','width','height'},...
                                             field_names),logical(ones(1,numel(field_names))))
        end
        function test_getDetPar(this)
            par=getDetPar(this.det);
            assertEqual(size(par),[5,100]);
        end
       function testSighnAzimChange(this)
            par=getDetPar(this.det);
            ps = getDetStruct(this.det);
            assertElementsAlmostEqual(par(3,:),-ps.azim,'absolute',1e-6);
        end
  
        
    end
end
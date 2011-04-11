classdef testDetectorsConstructorFile < TestCase
    properties 
        det
    end
    methods       
        % 
        function this=testDetectorsConstructorFile(name)
            this = this@TestCase(name);
        end
        function setUp(this)
            file = fullfile(pwd,'demo_par.par');
            this.det = detectors_par(file);
        end  
        function teadDown(this)
            delete(this.det);
        end
        % tests themself
        function testRightFileName(this)       
            assertEqual(this.det.filename,'demo_par.par');
        end
        %
        function tetLoadParNonExistentFile(this)
            f = @()load_par(this.det,'non_existent_file');
           % load par throws on undefined new par-file
            assertExceptionThrown(f,'DETECTORS_PAR:load_par');            
        end
        function testLoadParWorks(this)
            this.det=load_par(this.det);
            assertEqual(numel(this.det.phi),28160);
        end
       function testDetectorConstructorLoadsWrongKey(this)
            file = fullfile(pwd,'demo_par.par');            
            f=@()detectors_par(file,'load');
            assertExceptionThrown(f,'DETECTORS_PAR:constructor');            
        end                
        function this=testDetectorConstructorLoadsData(this)
            file = fullfile(pwd,'demo_par.par');            
            this.det = detectors_par(file,'-load');
            assertEqual(numel(this.det.phi),28160);
        end        
    end
end
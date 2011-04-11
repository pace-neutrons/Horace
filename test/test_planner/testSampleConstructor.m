classdef testSampleConstructor < TestCase
 % testing the constructor for sample case   
    properties 
       
    end
    methods       
        % 
        function this=testSampleConstructor(name)
            this = this@TestCase(name);
        end
       
        function testSampleConstrThrowsNon3VectPar1(this)
            f=@()sample([2.87,3],[30,40,50]);
            assertExceptionThrown(f,'SAMPLE:constructor');
        end
        function testSampleConstrThrowsNon3VectPar2(this)
            f=@()sample([2.87,2.5,3],[30,40]);
            assertExceptionThrown(f,'SAMPLE:constructor');
        end
       function testSampleConstrThrowsAngle180(this)
           % angles have to be in range >0 <180           
            f=@()sample([1,2,3],[180,40,10]);
            assertExceptionThrown(f,'SAMPLE:constructor');
        end
       function testSampleConstrThrowsAngle0(this)
           % angles have to be in range >0 <180
            f=@()sample([1,2,3],[18,40,0]);
            assertExceptionThrown(f,'SAMPLE:constructor');
        end
      function testSampleConstrThrowsNegativeEdge(this)
        % edges length have to be positive
            f=@()sample([1,-2,3],[18,40,10]);
            assertExceptionThrown(f,'SAMPLE:constructor');
        end

        
    end
end


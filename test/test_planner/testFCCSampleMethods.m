classdef testFCCSampleMethods < TestCase
    properties 
        sampl
    end
    methods       
        % Service 
        function this=testFCCSampleMethods(name)
            this = this@TestCase(name);
        end
        function setUp(this)
            this.sampl = sample([2.87,2.87,2.87],[90,90,90],true);
        end  
        function teadDown(this)
            delete(this.sampl);
        end
        %
        function testBmatrixRight(this)
            [b, arlu, angrlu]=bmat(this.sampl);
            assertElementsAlmostEqual(arlu,[2*pi/2.87,2*pi/2.87,2*pi/2.87],'absolute',0.0001);
            assertElementsAlmostEqual(angrlu,[90,90,90],'absolute',0.0001);            
            assertElementsAlmostEqual(b,[2*pi/2.87,0,0;0,2*pi/2.87,0;0,0,2*pi/2.87],'absolute',0.0001);            
        end

       function testUBmatrixWrong(this)
           % u,v two vecrtors expressed in RLU, parallel
           u=[1,0,0];
           v=[1,0,0];
           f = @()ubmat(this.sampl,u,v);
           assertExceptionThrown(f,'SAMPLE:ubmat');
       end
       
           function testUBmatrixRight(this)
           % u,v two vecrtors expressed in RLU, parallel
           u=[1,0,0];
           v=[0,1,0];
           ub=ubmat(this.sampl,u,v);
           assertElementsAlmostEqual(ub,[2*pi/2.87,0,0;0,2*pi/2.87,0;0,0,2*pi/2.87],'absolute',0.0001);            
           end
           function testGetReciprocalLatticeDefaultSize(this)
               % this is all dodgy FCC reciprocal lattice
               latt = get_reciprocal_lattice(this.sampl);
               assertEqual(size(latt,1),floor(3*3*3/2));
           end
          function testGetReciprocalLatticeSize7x7x7(this)
               % this is all dodgy FCC reciprocal lattice              
               latt = get_reciprocal_lattice(this.sampl,3);
               assertEqual(size(latt,1),floor(7*7*7/2));
          end           
          function testGetReciprocalLatticeZlim(this)
               % this is all dodgy FCC reciprocal lattice              
               latt = get_reciprocal_lattice(this.sampl,3,{[-0.1,0.1]});
               assertElementsAlmostEqual(latt(:,3),zeros(numel(latt(:,3)),1),'absolute',0.1);
          end           
          function testGetReciprocalLatticeYlim(this)
               % this is all dodgy FCC reciprocal lattice              
               latt = get_reciprocal_lattice(this.sampl,3,{[-10,10],[-0.1,0.1]});
               assertElementsAlmostEqual(latt(:,2),zeros(numel(latt(:,2)),1),'absolute',0.1);
          end           
          function testGetReciprocalLatticeXlim(this)
               % this is all dodgy FCC reciprocal lattice              
               latt = get_reciprocal_lattice(this.sampl,3,{[-10,10],[-10,10],[-0.1,0.1]});
               assertElementsAlmostEqual(latt(:,1),zeros(numel(latt(:,1)),1),'absolute',0.1);
           end           
                      
    end
end


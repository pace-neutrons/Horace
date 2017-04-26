classdef test_aProjection<TestCase
    % The test class to verify how projection works
    %
    properties
    end
    
    methods
        function this=test_aProjection(varargin)
            if nargin == 0
                name = 'test_aProjection';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        function test_constructor(this)
            %
            proj = aProjectionTester();
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            
            proj = aProjectionTester(1,[-1,1;-2,2;-3,3;-10,10],{'q1','q2','q3','E'});
            lab = proj.labels;
            assertTrue(all(ismember({'q1','q2','q3','E'},lab)));
            assertElementsAlmostEqual(proj.urange,proj.iax_range);
            assertElementsAlmostEqual(proj.iax,[1,2,3,4]);
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[1,1,1,1]);
            
            proj = aProjectionTester([1,2,2,1],[-1,1;-2,2;-3,3;-10,10]);
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            assertElementsAlmostEqual(proj.iax_range,[-1,1;-10,10]');
            assertElementsAlmostEqual(proj.iax,[1,4]);
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[1,2,2,1]);
            assertElementsAlmostEqual(proj.p{1},proj.iax_range(:,1));
            assertElementsAlmostEqual(proj.p{4},proj.iax_range(:,2));
            
            
            proj = aProjectionTester([10,10,10,10]',[-1,1;-2,2;-3,3;-10,10]);
            lab = proj.labels;
            assertTrue(all(ismember({'Q_\zeta','Q_\xi','Q_\eta','E'},lab)));
            assertTrue(isempty(proj.iax_range));
            assertTrue(isempty(proj.iax));
            assertElementsAlmostEqual(proj.urange,[-1,1;-2,2;-3,3;-10,10]');
            assertElementsAlmostEqual(proj.data_binning,[10,10,10,10]);
            
            p2_range = [proj.p{2}(1);proj.p{2}(end)];
            assertElementsAlmostEqual(proj.urange(:,2),p2_range);
            
        end
        
    end
end

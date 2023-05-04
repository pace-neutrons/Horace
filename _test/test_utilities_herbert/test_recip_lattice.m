classdef test_recip_lattice < TestCase
    properties
    end
    methods
        function obj = test_recip_lattice(varargin)
            if nargin<1
                name = 'test_recip_lattice';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end

        function test_tricl_sharp(~)
            alatt = [1,2,3];
            angdeg = [80,70,90];            

            bb = direct2recip(alatt,angdeg);

            [bm,arlu,angrlu] = bmatrix(alatt,angdeg);

            b1 = norm(bb(:,1));
            b2 = norm(bb(:,2));            
            b3 = norm(bb(:,3));
            
            a1 = acosd(bb(:,1)'*bb(:,2)/b1/b2);
            a2 = acosd(bb(:,1)'*bb(:,3)/b1/b3);            
            a3 = acosd(bb(:,2)'*bb(:,3)/b2/b3);                        

            assertEqual(angrlu(1),a1);
            assertEqual(angrlu(2),a2);            
            assertEqual(angrlu(3),a3);            

            assertEqualToTol(b1,arlu(1));
            assertEqualToTol(b2,arlu(2));            
            assertEqualToTol(b3,arlu(3));                        

        end
        

        function test_ortho_recip(~)
            bb = direct2recip([1,2,3],[90,90,90]);

            assertElementsAlmostEqual(bb(:,1),[2*pi;0;0]);
            assertElementsAlmostEqual(bb(:,2),[0;2*pi/2;0]);
            assertElementsAlmostEqual(bb(:,3),[0;0;2*pi/3]);
        end

    end
end
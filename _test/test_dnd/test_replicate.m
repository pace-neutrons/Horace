classdef test_replicate< TestCase
    %
    % Validate dnd objects replication
    
    
    properties
    end
    
    methods
        
        %The above can now be read into the test routine directly.
        function this=test_replicate(name)
            if ~exist('name','var')
                name = 'test_replicate';
            end
            this=this@TestCase(name);
        end
        
        % tests
        function test_replicate_0Dto4D(~)  
            pr = projaxes([1,0,0],[0,1,0]);
            ol = oriented_lattice([1,2,4],[90,90,90]);
            d4 = d4d(ol,pr,[-0.1,0.01,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            assertTrue(isa(d4,'d4d'))
            d0 = d0d(ol,pr,[-0.1,0.1],[-2,-1],[0,1],[-2,2]);
            assertTrue(isa(d0,'d0d'))

            d4r = replicate(d0,d4);

            assertEqual(d4,d4r);
        end
        
        function test_replicate_1Dto4D(~)  
            pr = projaxes([1,0,0],[0,1,0]);
            ol = oriented_lattice([1,2,4],[90,90,90]);
            d4 = d4d(ol,pr,[-0.1,0.01,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            assertTrue(isa(d4,'d4d'))
            d1 = d1d(ol,pr,[-0.1,0.1],[-2,-1],[0,1],[-2,0.05,2]);
            assertTrue(isa(d1,'d1d'))

            d4r = replicate(d1,d4);

            assertEqual(d4,d4r);
        end
        
        function test_replicate_1Dto3D(~)  
            pr = projaxes([1,0,0],[0,1,0]);
            ol = oriented_lattice([1,2,4],[90,90,90]);
            d3 = d3d(ol,pr,[-0.1,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            assertTrue(isa(d3,'d3d'))
            d1 = d1d(ol,pr,[-0.1,0.1],[-2,-1],[0,1],[-2,0.05,2]);
            assertTrue(isa(d1,'d1d'))

            d3r = replicate(d1,d3);

            assertEqual(d3,d3r);
        end
        
        function test_replicate_1Dto2D(~)  
            pr = projaxes([1,0,0],[0,1,0]);
            ol = oriented_lattice([1,2,4],[90,90,90]);
            d2 = d2d(ol,pr,[-0.1,0.1],[-2,0.05,2],[0,1],[-2,0.05,2]);
            assertTrue(isa(d2,'d2d'))
            d1 = d1d(ol,pr,[-0.1,0.1],[-2,-1],[0,1],[-2,0.05,2]);
            assertTrue(isa(d1,'d1d'))

            d2r = replicate(d1,d2);

            assertEqual(d2,d2r);
        end
        
        
    end
end



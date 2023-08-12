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
        function test_replicate_2Dto4D(~)
            pr = line_proj([1,0,0],[0,1,0],'alatt',[1,2,4],'angdeg',90);
            ax = line_axes([-0.1,0.01,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            d4 = d4d(ax,pr);
            assertTrue(isa(d4,'d4d'))
            ax = line_axes([-0.1,0.1],[-2,0.05,2],[0,0.1,1],[-2,2]);
            d2 = d2d(ax,pr);
            assertTrue(isa(d2,'d2d'))

            d4r = replicate(d2,d4);

            assertEqual(d4,d4r);
        end

        function test_replicate_0Dto4D(~)
            pr = line_proj([1,0,0],[0,1,0],'alatt',[1,2,4],'angdeg',90);
            ax = line_axes([-0.1,0.01,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            d4 = d4d(ax,pr);
            assertTrue(isa(d4,'d4d'))
            ax = line_axes([-0.1,0.1],[-2,-1],[0,1],[-2,2]);
            d0 = d0d(ax,pr);
            assertTrue(isa(d0,'d0d'))

            d4r = replicate(d0,d4);

            assertEqual(d4,d4r);
        end

        function test_replicate_1Dto4D(~)
            pr = line_proj([1,0,0],[0,1,0],'alatt',[1,2,4],'angdeg',90);
            ax = line_axes([-0.1,0.02,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            d4 = d4d(ax,pr);
            assertTrue(isa(d4,'d4d'))
            ax = line_axes([-0.1,0.1],[-2,-1],[0,1],[-2,0.05,2]);
            d1 = d1d(ax,pr);
            assertTrue(isa(d1,'d1d'))

            d4r = replicate(d1,d4);

            assertEqual(d4,d4r);
        end

        function test_replicate_1Dto3D(~)
            pr = line_proj([1,0,0],[0,1,0],'alatt',[1,2,4],'angdeg',90);
            ax = line_axes([-0.1,0.1],[-2,0.05,2],[0,0.1,1],[-2,0.05,2]);
            d3 = d3d(ax,pr);
            assertTrue(isa(d3,'d3d'))
            ax = line_axes([-0.1,0.1],[-2,-1],[0,1],[-2,0.05,2]);
            d1 = d1d(ax,pr);
            assertTrue(isa(d1,'d1d'))

            d3r = replicate(d1,d3);

            assertEqual(d3,d3r);
        end

        function test_replicate_1Dto2D(~)
            pr = line_proj([1,0,0],[0,1,0],'alatt',[1,2,4],'angdeg',90);
            ax = line_axes([-0.1,0.1],[-2,0.1,2],[0,1],[-2,0.05,2]);
            d2 = d2d(ax,pr);
            assertTrue(isa(d2,'d2d'))
            ax = line_axes([-0.1,0.1],[-2,0.1,2],[0,1],[-2,-1]);
            d1 = d1d(ax,pr);
            assertTrue(isa(d1,'d1d'))

            d2r = replicate(d1,d2);

            assertEqual(d2,d2r);
        end
    end
end



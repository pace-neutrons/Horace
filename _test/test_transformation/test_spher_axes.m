classdef test_spher_axes < TestCase
    % Tests for main operations of the test_spher_axes

    properties
        out_dir=tmp_dir();
    end

    methods
        function obj=test_spher_axes(varargin)
            if nargin<1
                name = 'test_spher_axes';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end
        %
        %------------------------------------------------------------------
        function test_axes_ranges_at_limits(~)
            dbr = [0,-90,-180,-10;10,90,180,50];
            bin0 = {[dbr(1,1),0.5,dbr(2,1)];[dbr(1,2),1,dbr(2,2)];...
                [dbr(1,3),1,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});
            range = ab.get_binning_range();
            ac_range = {[0.25,0.5,10.25];[-89.5,1,89.5];[-179.5,1,179.5];[dbr(1,4),1,dbr(2,4)]};
            assertEqual(ac_range,range');
        end

        function test_axes_ranges_within(~)
            dbr = [0.25,-45,-90,-10;10.25,45,80,50];
            bin0 = {[dbr(1,1),0.5,dbr(2,1)];[dbr(1,2),1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});
            range = ab.get_binning_range();
            assertEqual(bin0,range');
        end
        %         %------------------------------------------------------------------
        %         function test_default_binning_2D_cross_proj(~)
        %             dbr = [-1,-1.05,-3,0;1,1.05,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
        %                 [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
        %             ab = spher_axes(bin0{:});
        %
        %             proj1 = ortho_proj([1,0,0],[0,1,0]);
        %             proj2 = ortho_proj([1,1,0],[1,-1,0]);
        %
        %             bin = ab.get_binning_range(proj1,proj2);
        %
        %             % characteristic size of the block, transformed into proj2
        %             % coordinate system. This is absolutely unclear why does this
        %             % happen and why does it look lie this.
        %             nb = ab.nbins_all_dims;
        %             transformed_block_size = 2;
        %             step = transformed_block_size/(nb(1)-1);
        %             int_range = [-0.5*(transformed_block_size+step),0.5*(transformed_block_size+step)];
        %             bin_range = [int_range(1)+0.5*step,step,int_range(2)-0.5*step];
        %
        %             assertEqualToTol(bin_range,bin{1},'abstol',1.e-12);
        %             assertEqualToTol(int_range,bin{2},'abstol',1.e-12);
        %             assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
        %             assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        %         end
        %         %
        %         function test_default_binning_4D_cross_proj(~)
        %             dbr = [-1,-1,-3,0;1,1,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
        %                 [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
        %             ab = spher_axes(bin0{:});
        %
        %             proj1 = ortho_proj([1,0,0],[0,1,0]);
        %             proj2 = ortho_proj([1,1,0],[1,-1,0]);
        %
        %             bin = ab.get_binning_range(proj1,proj2);
        %
        %             %proj1.targ_proj = proj2;
        %
        %             assertEqualToTol([-1,0.1,1],bin{1},'abstol',1.e-12);
        %             assertEqualToTol([-1,0.1,1],bin{2},'abstol',1.e-12);
        %             assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
        %             assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        %         end
        %         %
        %         function test_default_binning_4D_ortho_proj(~)
        %             dbr = [-1,-2,-3,0;1,2,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
        %                 [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
        %             ab = spher_axes(bin0{:});
        %
        %             proj1 = ortho_proj([1,0,0],[0,1,0]);
        %             proj2 = ortho_proj([1,0,0],[0,0,1]);
        %
        %             bin = ab.get_binning_range(proj1,proj2);
        %
        %             assertEqualToTol(bin0{1},bin{1},'abstol',1.e-12);
        %             assertEqualToTol(bin0{2},bin{3},'abstol',1.e-12);
        %             assertEqualToTol(bin0{3},bin{2},'abstol',1.e-12);
        %             assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        %         end
        %         %
        %         function test_default_binning_2D_same_proj(~)
        %             dbr = [-1,-2,-3,0;1,2,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),dbr(2,2)],...
        %                 [dbr(1,3),0.3,dbr(2,3)],[dbr(1,4),dbr(2,4)]};
        %
        %             ab = spher_axes(bin0{:});
        %             assertEqual(ab.pax,[1,3]);
        %             assertEqual(ab.dax,[1,2]);
        %             assertEqual(ab.iax,[2,4]);
        %             assertEqual(ab.iint,[-2,0;2,10]);
        %
        %             proj1 = ortho_proj([1,0,0],[0,1,0]);
        %
        %             bin = ab.get_binning_range(proj1,proj1);
        %
        %             assertEqualToTol(bin0,bin,'abstol',1.e-12);
        %         end

        %------------------------------------------------------------------
        %         function test_get_bin_nodes_2D_2d(~)
        %             dbr = [-1,-2,-3,0;1,2,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
        %                 [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
        %             ab = spher_axes(bin0{:});
        %
        %             [nodes,en] = ab.get_bin_nodes('-3D');
        %             assertEqual(size(nodes,1),3);
        %
        %             nd = ab.dimensions;
        %             sz = ab.dims_as_ssize();
        %             sz = sz+1;
        %
        %             assertEqual(numel(en),sz(end));
        %
        %             ni = 4-nd;
        %             the_size = ni*2*prod(sz(1:nd-1));
        %             assertEqual(size(nodes,2),the_size);
        %         end
        %         %
        %         function test_get_bin_nodes_4D_4d(~)
        %             dbr = [-1,-2,-3,0;1,2,3,10];
        %             bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
        %                 [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
        %             ab = spher_axes(bin0{:});
        %
        %             nodes = ab.get_bin_nodes();
        %             assertEqual(size(nodes,1),4);
        %
        %             sz = ab.dims_as_ssize();
        %             sz = sz+1;
        %
        %             the_size = prod(sz);
        %             assertEqual(size(nodes,2),the_size);
        %         end
        %         %
        function test_get_bin_nodes_2D_4d_deg(~)
            dbr = [0,-90,-180,0;1,90,180,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),1,dbr(2,2)];...
                [dbr(1,3),1,dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = spher_axes(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            nd = ab.dimensions;
            sz = ab.dims_as_ssize();
            ni = 4-nd;
            %sz = sz+1;
            the_size = ni*2*prod(sz+1);
            assertEqual(size(nodes,2),the_size);
        end
        
        function test_get_bin_nodes_2D_4d(~)
            dbr = [0,-90,-180,0;1,90,180,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            nd = ab.dimensions;
            sz = ab.dims_as_ssize();
            ni = 4-nd;
            %sz = sz+1;
            the_size = ni*2*prod(sz+1);
            assertEqual(size(nodes,2),the_size);
        end
        %------------------------------------------------------------------
        function test_angular_is_rad_in_constructor(~)
            dbr = [0,-pi/2,-pi,-10;10,pi/2,pi,50];
            bin0 = {[dbr(1,1),0.05,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:},'angular_unit_is_rad','r');
            assertEqual(ab.img_range, ...
                [0,-pi/2,-pi,-10.5; ...
                10.05,pi/2,pi,50.5])
            assertTrue(all(ab.angular_unit_is_rad));
            ab.angular_unit_is_rad = [false,true];
            assertEqual(ab.img_range, ...
                [0,-90,-pi,-10.5; ...
                10.05,90,pi,50.5])

        end
        %------------------------------------------------------------------
        function test_build_from_input_binning_more_infs(~)
            default_binning = {[0,0.1,1],[-45,1,45],[-180,1,180],[0,1,10]};
            pbin = {[-inf,inf],[inf,1,45],[-180,1,inf],[-inf,0.1,inf]};
            block = AxesBlockBase.build_from_input_binning('spher_axes',default_binning,pbin);
            assertTrue(isa(block,'spher_axes'));
            assertElementsAlmostEqual(block.img_range,...
                [0,-45.5,-180,-0.05;...
                1 ,45.5,180,10.05])
            assertEqual(block.nbins_all_dims,[1,91,360,101]);
            assertEqual(block.iax,1)
            assertEqual(block.iint,[0;1])
            assertEqual(block.pax,[2,3,4])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},-45.5:1:45.5,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-180:1:180,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.05:0.1:10.05,'absolute',1.e-12)
        end
        %
        function test_build_from_input_binning(~)
            default_binning = {[0,0.1,1],[-45,1,45],[-180,1,180],[0,1,10]};
            pbin = {[],[-45,45],[-90,1,90],[-inf,0,inf]};
            block = AxesBlockBase.build_from_input_binning('spher_axes',default_binning,pbin);
            assertTrue(isa(block,'spher_axes'));
            assertElementsAlmostEqual(block.img_range,[0,-45,-90.5,-0.5;1.1,45,90.5,10.5]);
            assertEqual(block.nbins_all_dims,[11,1,181,11]);
            assertEqual(block.dax,[1,2,3]);
            assertEqual(block.iax,2)
            assertEqual(block.pax,[1,3,4])
            assertEqual(block.iint,[-45;45])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},0:0.1:1.1,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-90.5:1:90.5,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.5:1:10.5,'absolute',1.e-12)
        end
        %------------------------------------------------------------------
        function test_bin_edges_provided_4D(~)
            dbr = [0,-90,-180,-10;10,90,180,50];
            bin0 = {[dbr(1,1),0.5,dbr(2,1)];[dbr(1,2),1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:},'single_bin_defines_iax',[true,false,false,true]);

            assertEqual(ab.img_range,[0,-90,-180,-10-0.5;10+0.5,90,180,50+0.5])
            assertEqual(ab.dimensions(),4)

        end
        function test_wrong_bin_edges_throw(~)
            dbr = [0,-90,-180,-10;10,90,180,50];
            sap = spher_axes(4);
            function setter(sap,val)
                sap.img_range  = val;
            end
            dbr_set = dbr;
            dbr_set(1,1) = -1;
            assertExceptionThrown(@()setter(sap,dbr_set), ...
                'HORACE:spher_axes:invalid_argument');
            dbr_set = dbr;
            dbr_set(1,2) = -100;
            assertExceptionThrown(@()setter(sap,dbr_set), ...
                'HORACE:spher_axes:invalid_argument');

            dbr_set = dbr;
            dbr_set(2,2) = 100;
            assertExceptionThrown(@()setter(sap,dbr_set), ...
                'HORACE:spher_axes:invalid_argument');

            dbr_set = dbr;
            dbr_set(1,3) = -200;
            assertExceptionThrown(@()setter(sap,dbr_set), ...
                'HORACE:spher_axes:invalid_argument');

            dbr_set = dbr;
            dbr_set(2,3) = 200;
            assertExceptionThrown(@()setter(sap,dbr_set), ...
                'HORACE:spher_axes:invalid_argument');

        end

        function test_spher_axes_change_angular_range_in_parts_text(~)
            ab = spher_axes(4);
            assertEqual(ab.dimensions,4);
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,1])
            ab.angular_unit_is_rad = 'rd';
            assertEqual(ab.angular_unit_is_rad,[true,false]);
            assertEqual(ab.img_range,[0,-pi/2,-180,0;1,pi/2,180,1])
            ab.angular_unit_is_rad = "dr";
            assertEqual(ab.angular_unit_is_rad,[false,true]);
            assertEqual(ab.img_range,[0,-90,-pi,0;1,90,pi,1])
            ab.angular_unit_is_rad = 'rr';
            assertEqual(ab.img_range,[0,-pi/2,-pi,0;1,pi/2,pi,1])
            ab.angular_unit_is_rad = "dd";
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,1])

        end

        function test_spher_axes_change_angular_range_in_parts_logical(~)
            ab = spher_axes(4);
            assertEqual(ab.dimensions,4);
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,1])
            ab.angular_unit_is_rad = [true,false];
            assertEqual(ab.angular_unit_is_rad,[true,false]);
            assertEqual(ab.img_range,[0,-pi/2,-180,0;1,pi/2,180,1])
            ab.angular_unit_is_rad = [false,true];
            assertEqual(ab.angular_unit_is_rad,[false,true]);
            assertEqual(ab.img_range,[0,-90,-pi,0;1,90,pi,1])
            ab.angular_unit_is_rad = [true,true];
            assertEqual(ab.img_range,[0,-pi/2,-pi,0;1,pi/2,pi,1])
        end

        function test_spher_axes_change_angular_range(~)
            ab = spher_axes(3);
            assertEqual(ab.dimensions,3);
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,0])
            ab.angular_unit_is_rad = 'd';
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,0])
            ab.angular_unit_is_rad = 'r';
            assertEqual(ab.angular_unit_is_rad,[true,true]);
            assertEqual(ab.img_range,[0,-pi/2,-pi,0;1,pi/2,pi,0])
        end
        %
        function test_spher_axes_0D_explicit(~)
            ab = spher_axes(0);
            assertEqual(ab.dimensions,0);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_spher_axes_1D_explicit(~)
            ab = spher_axes(1);
            assertEqual(ab.dimensions,1);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = true(1,4);
            iiax(1) = false;
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_spher_axes_2D_explicit(~)
            ab = spher_axes(2);
            assertEqual(ab.dimensions,2);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(3) = true;
            iiax(4) = true;
            assertEqual(ab.single_bin_defines_iax,iiax)
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,0,0;1,90,0,0])

        end
        %
        function test_spher_axes_3D_explicit(~)
            ab = spher_axes(3);
            assertEqual(ab.dimensions,3);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(4) = true;
            assertEqual(ab.single_bin_defines_iax,iiax)
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,0])

        end
        %
        function test_spher_axes_4D_explicit(~)
            ab = spher_axes(4);
            assertEqual(ab.dimensions,4);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            assertEqual(ab.single_bin_defines_iax,false(1,4))
            assertEqual(ab.angular_unit_is_rad,[false,false]);
            assertEqual(ab.img_range,[0,-90,-180,0;1,90,180,1])

        end
        %

    end
end

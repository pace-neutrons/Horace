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
        function test_get_bin_nodes_2D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            [nodes,en] = ab.get_bin_nodes('-3D');
            assertEqual(size(nodes,1),3);

            nd = ab.dimensions;
            sz = ab.dims_as_ssize();
            sz = sz+1;

            assertEqual(numel(en),sz(end));

            ni = 4-nd;
            the_size = ni*2*prod(sz(1:nd-1));
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_4D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);

            sz = ab.dims_as_ssize();
            sz = sz+1;

            the_size = prod(sz);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_2d_char_size(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            new_step = [0.05;4;6;0.1];
            r0 = [-1;-2;-3;0];
            r1 = r0+new_step;
            char_block =[r0,r1];
            [nodes,en,nbins] = ab.get_bin_nodes(char_block);
            assertEqual(numel(en),nbins(4));
            assertEqual(size(nodes,1),4);
            node_range = [min(nodes,[],2)';max(nodes,[],2)'];
            assertEqual(ab.img_range,node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;
            nns = [42,2,2,111];
            assertEqual(nns,nbins);
            the_size = prod(nns);
            assertEqual(size(nodes,2),the_size);
        end
        %
        function test_get_bin_nodes_2D_4d_char_size(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            new_step = [0.05;0.1;0.15;0.1];
            r0 = [-1;-2;-3;0];
            r1 = r0+new_step;
            char_block =[r0,r1];
            [nodes3D,dEgrid,npoints_in_axes] = ab.get_bin_nodes(char_block,'-3D');
            assertEqual(size(nodes3D,1),3);
            node_range = [min(nodes3D,[],2)';max(nodes3D,[],2)'];
            assertEqual(ab.img_range(:,1:3),node_range);

            %nns = floor((ab.img_range(2,:)-ab.img_range(1,:))'./(0.5*new_step))+1;

            nns = [42    40    41   111];
            assertEqual(nns,npoints_in_axes);
            q_size = prod(nns(1:3));
            assertEqual(numel(dEgrid),nns(4))
            assertEqual(size(nodes3D,2),q_size);
        end
        %
        function test_get_bin_nodes_2D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
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
        function test_axes_ranges(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),dbr(2,2)],...
                [dbr(1,3),0.3,dbr(2,3)],[dbr(1,4),dbr(2,4)]};
            ab = spher_axes(bin0{:});
            range = ab.get_binning_range();
            assertEqual(bin0,range);
        end
        %------------------------------------------------------------------
        function test_default_binning_2D_cross_proj(~)
            dbr = [-1,-1.05,-3,0;1,1.05,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            bin = ab.get_binning_range(proj1,proj2);

            % characteristic size of the block, transformed into proj2
            % coordinate system. This is absolutely unclear why does this
            % happen and why does it look lie this.
            nb = ab.nbins_all_dims;
            transformed_block_size = 2;
            step = transformed_block_size/(nb(1)-1);
            int_range = [-0.5*(transformed_block_size+step),0.5*(transformed_block_size+step)];
            bin_range = [int_range(1)+0.5*step,step,int_range(2)-0.5*step];

            assertEqualToTol(bin_range,bin{1},'abstol',1.e-12);
            assertEqualToTol(int_range,bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_4D_cross_proj(~)
            dbr = [-1,-1,-3,0;1,1,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);

            bin = ab.get_binning_range(proj1,proj2);

            %proj1.targ_proj = proj2;

            assertEqualToTol([-1,0.1,1],bin{1},'abstol',1.e-12);
            assertEqualToTol([-1,0.1,1],bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_4D_ortho_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:});

            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,0,0],[0,0,1]);

            bin = ab.get_binning_range(proj1,proj2);

            assertEqualToTol(bin0{1},bin{1},'abstol',1.e-12);
            assertEqualToTol(bin0{2},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        %
        function test_default_binning_2D_same_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),dbr(2,2)],...
                [dbr(1,3),0.3,dbr(2,3)],[dbr(1,4),dbr(2,4)]};

            ab = spher_axes(bin0{:});
            assertEqual(ab.pax,[1,3]);
            assertEqual(ab.dax,[1,2]);
            assertEqual(ab.iax,[2,4]);
            assertEqual(ab.iint,[-2,0;2,10]);

            proj1 = ortho_proj([1,0,0],[0,1,0]);

            bin = ab.get_binning_range(proj1,proj1);

            assertEqualToTol(bin0,bin,'abstol',1.e-12);
        end
        %------------------------------------------------------------------       
        function test_build_from_input_binning_more_infs(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10.05]};
            pbin = {[-inf,inf],[inf,0.1,1],[-2,0.1,inf],[-inf,0.1,inf]};
            block = AxesBlockBase.build_from_input_binning('spher_axes',default_binning,pbin);
            assertTrue(isa(block,'spher_axes'));
            assertElementsAlmostEqual(block.img_range,...
                [-1.,-2.05,-2.05,-0.05;...
                1, 1.05,3.05,10.15]);
            assertEqual(block.nbins_all_dims,[1,31,51,102]);
            assertEqual(block.iax,1)
            assertEqual(block.iint,[-1;1])
            assertEqual(block.pax,[2,3,4])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},-2.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:3.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.05:0.1:10.15,'absolute',1.e-12)
        end
        %
        function test_build_from_input_binning(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10]};
            pbin = {[],[-1,1],[-2,0.1,2],[-inf,0,inf]};
            block = AxesBlockBase.build_from_input_binning('spher_axes',default_binning,pbin);
            assertTrue(isa(block,'spher_axes'));
            assertElementsAlmostEqual(block.img_range,[-1.05,-1,-2.05,-0.5;1.05,1,2.05,10.5]);
            assertEqual(block.nbins_all_dims,[21,1,41,11]);
            assertEqual(block.dax,[1,2,3]);
            assertEqual(block.iax,2)
            assertEqual(block.pax,[1,3,4])
            assertEqual(block.iint,[-1;1])
            assertEqual(block.dax,[1,2,3])
            assertElementsAlmostEqual(block.p{1},-1.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:2.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},-0.5:1:10.5,'absolute',1.e-12)
        end
        %------------------------------------------------------------------
        function test_bin_edges_provided_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab = spher_axes(bin0{:},'single_bin_defines_iax',[true,false,false,true]);

            assertEqual(ab.img_range,[-1,-2,-3,0;1,2,3,10])
            assertEqual(ab.dimensions(),2)
            
        end
        %
        function test_bin_edges_provided_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = spher_axes(bin0{:},'single_bin_defines_iax',[true,false,false,true]);

            assertEqual(ab.img_range,[-1-0.05,-2,-3,0-0.5;1+0.05,2,3,10+0.5])
            assertEqual(ab.dimensions(),4)

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
        end
        %
        function test_spher_axes_3D_explicit(~)
            ab = spher_axes(3);
            assertEqual(ab.dimensions,3);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            iiax = false(1,4);
            iiax(4) = true;
            assertEqual(ab.single_bin_defines_iax,iiax)
        end
        %
        function test_spher_axes_4D_explicit(~)
            ab = spher_axes(4);
            assertEqual(ab.dimensions,4);
            assertEqual(ab.nbins_all_dims,ones(1,4))
            assertEqual(ab.single_bin_defines_iax,false(1,4))
        end
        %

    end
end

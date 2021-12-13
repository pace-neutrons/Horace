classdef test_axes_block < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tmp_dir();
    end
    
    methods
        function obj=test_axes_block(varargin)
            if nargin<1
                name = 'test_axes_block';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            
        end
        function test_axes_scales_2D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            [cube,step]  = ab.get_axes_scales();
            assertEqual(size(cube,2),16)
            assertEqual(dbr(1,:)',cube(:,1))
            assertEqual(dbr(1,:)'+step,cube(:,16))
        end
        
        function test_axes_scales_4D(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            [cube,step]  = ab.get_axes_scales();
            assertEqual(size(cube,2),16)
            assertEqual(dbr(1,:)',cube(:,1))
            assertEqual(dbr(1,:)'+step,cube(:,16))
        end
        function test_get_bin_nodes_4D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            [nodes,en] = ab.get_bin_nodes();
            assertEqual(size(nodes,1),3);
            [~,sz] = ab.data_dims();
            sz = sz+1;
            
            assertEqual(numel(en),sz(4));
            
            the_size = prod(sz(1:3));
            assertEqual(size(nodes,2),the_size);
        end
        
        function test_get_bin_nodes_2D_2d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            [nodes,en] = ab.get_bin_nodes();
            assertEqual(size(nodes,1),3);
            
            [nd,sz] = ab.data_dims();
            sz = sz+1;
            
            assertEqual(numel(en),sz(end));
            
            ni = 4-nd;
            the_size = ni*2*prod(sz(1:nd-1));
            assertEqual(size(nodes,2),the_size);
        end
        
        function test_get_bin_nodes_4D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);
            [~,sz] = ab.data_dims();
            sz = sz+1;
            the_size = prod(sz);
            assertEqual(size(nodes,2),the_size);
        end
        
        function test_get_bin_nodes_2D_4d(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            nodes = ab.get_bin_nodes();
            assertEqual(size(nodes,1),4);
            [nd,sz] = ab.data_dims();
            ni = 4-nd;
            sz = sz+1;
            the_size = ni*2*prod(sz);
            assertEqual(size(nodes,2),the_size);
        end
        
        function test_default_binning_2D_cross_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);
            
            bin = ab.get_default_binning_range(dbr,proj1,proj2);
            
            assertEqualToTol([-1.5,0.15,1.5],bin{1},'abstol',1.e-12);
            assertEqualToTol([-1.5,1.5],bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        
        function test_default_binning_4D_cross_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,1,0],[1,-1,0]);
            
            bin = ab.get_default_binning_range(dbr,proj1,proj2);
            
            assertEqualToTol([-1.5,0.15, 1.5],bin{1},'abstol',1.e-12);
            assertEqualToTol([-1.5,0.075,1.5],bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        
        function test_default_binning_4D_ortho_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab = axes_block(bin0{:});
            
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            proj2 = ortho_proj([1,0,0],[0,0,1]);
            
            bin = ab.get_default_binning_range(dbr,proj1,proj2);
            
            assertEqualToTol(bin0{1},bin{1},'abstol',1.e-12);
            assertEqualToTol(bin0{2},bin{3},'abstol',1.e-12);
            assertEqualToTol(bin0{3},bin{2},'abstol',1.e-12);
            assertEqualToTol(bin0{4},bin{4},'abstol',1.e-12);
        end
        
        function test_default_binning_2D_same_proj(~)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            
            ab = axes_block(bin0{:});
            assertEqual(ab.dax,[1,2]);
            assertEqual(ab.pax,[1,3]);
            assertEqual(ab.iax,[2,4]);
            assertEqual(ab.iint,[-2,0;2,10]);
            
            proj1 = ortho_proj([1,0,0],[0,1,0]);
            
            bin = ab.get_default_binning_range(dbr,proj1,proj1);
            
            assertEqualToTol(bin0,bin,'abstol',1.e-12);
        end
        %
        function test_build_from_input_binning_more_infs(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10.05]};
            pbin = {[-inf,inf],[inf,0.1,1],[-2,0.1,inf],[-inf,0.1,inf]};
            [block,targ_img_db_range] = axes_block.build_from_input_binning(default_binning,pbin);
            assertTrue(isa(block,'axes_block'));
            assertEqual(targ_img_db_range,...
                [-1,-2.0,-2.05,0;...
                1, 1.05,3.0,10.05]);
            assertEqual(block.dax,[1,2,3]);
            assertEqual(block.iax,1)
            assertEqual(block.pax,[2,3,4])
            assertEqual(block.iint,[-1;1])
            assertElementsAlmostEqual(block.p{1},-2.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:3.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},0:0.1:10.1,'absolute',1.e-12)
        end
        %
        function test_build_from_input_binning(~)
            default_binning = {[-1,0.1,1],[-2,0.2,2],[-3,0.3,3],[0,1,10]};
            pbin = {[],[-1,1],[-2,0.1,2],[-inf,0,inf]};
            [block,targ_img_db_range] = axes_block.build_from_input_binning(default_binning,pbin);
            assertTrue(isa(block,'axes_block'));
            assertEqual(targ_img_db_range,[-1.05,-1,-2.05,0;1.05,1,2.05,10]);
            assertEqual(block.dax,[1,2,3]);
            assertEqual(block.iax,2)
            assertEqual(block.pax,[1,3,4])
            assertEqual(block.iint,[-1;1])
            assertElementsAlmostEqual(block.p{1},-1.05:0.1:1.05,'absolute',1.e-12);
            assertElementsAlmostEqual(block.p{2},-2.05:0.1:2.05,'absolute',1.e-12)
            assertElementsAlmostEqual(block.p{3},0:10,'absolute',1.e-12)
        end
    end
end

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
        %
        function this=test_build_from_input_binning_more_infs(this)
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
        function this=test_build_from_input_binning(this)
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

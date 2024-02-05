classdef test_proj_info < TestCase
    % The tests to verify how proj_info works
    %
    % At the moment Re #1487 these methods are disabled
    %
    properties
    end

    methods
        function this=test_proj_info(varargin)
            if nargin == 0
                name = 'test_proj_info';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_get_set_img_offset_ppr_scales_hkl(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            alatt = [2,2,2];
            angdeg = 90;

            pra = line_proj([1,-1,0],[1, 1,0],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.img_offset = [0,1,0,0];
            assertElementsAlmostEqual(pra.img_offset,[0,1,0,0],'absolute',1.e-12);
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);
        end
        function test_img_offset_zero(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];

            pra = line_proj([1,1,0],[0, 1,0],'w',[1,1,1],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            assertEqual(pra.offset,pra.img_offset);
        end
        function test_set_offset_get_img_offset_scaled(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            alatt = [1,2,3];
            angdeg = 90;

            pra = line_proj([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg,'type','aaa');
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.offset = in_offset;
            assertEqual(pra.offset,in_offset);
            img_offset = in_offset.*(2*pi./[alatt,1]);

            assertElementsAlmostEqual(pra.img_offset,img_offset,'absolute',1.e-12);
        end
        function test_set_img_offset_get_offset_scaled(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            alatt = [1,2,3];
            angdeg = 90;

            pra = line_proj([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg,'type','aaa');
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            img_offset = in_offset.*(2*pi./[alatt,1]);
            pra.img_offset = img_offset;

            assertElementsAlmostEqual(pra.img_offset,img_offset,'absolute',1.e-12);
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);
        end
        function test_get_set_hkl_offset_ppr_scales(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            alatt = [2,2,2];
            angdeg = 90;

            pra = line_proj([1,-1,0],[1, 1,0],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.offset = in_offset;
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);

            assertElementsAlmostEqual(pra.img_offset,[0,1,0,0],'absolute',1.e-12);
        end
        %------------------------------------------------------------------
        function test_no_lattice_not_calculated_before_lattice_defined(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')
            proj = line_proj([1,0,0],[0,1,0],...
                'alatt',[2,3,4]);
            proj.offset = [1,1,0,0];
            assertTrue(isempty(proj.img_offset));
            proj.angdeg = 90;
            assertElementsAlmostEqual(proj.img_offset,proj.offset);
        end
        function test_no_lattice_uoffset_hangs_before_lattice_defined(~)
            skipTest('Re #1487 proj_helper tests are disabled as proj_transf is not here yet')            
            proj = line_proj([1,0,0],[0,1,0],...
                'angdeg',90);
            proj.img_offset = [1,1,0,0];
            assertEqual(proj.img_offset,[1,1,0,0]);
            assertEqual(proj.offset,[0,0,0,0]);
            proj.alatt = 2;
            assertElementsAlmostEqual(proj.img_offset,proj.offset);
        end


    end
end
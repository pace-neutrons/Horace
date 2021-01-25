classdef test_proj_captions<TestCase
    % The test class to verify how projection works
    %
    properties
        data
        wk_data
    end

    methods
        function this=test_proj_captions(name)
            this=this@TestCase(name);
            %sqw/dnd data structure with fields used in caption
            this.data= data_sqw_dnd();
        end
        function this=setUp(this)
            this.wk_data = this.data;
        end
        function this=tearDown(this)
            this.wk_data = [];
        end

        function test_cube_caption(this)

            capt = an_axis_caption();
            assertTrue(capt.changes_aspect_ratio);

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.wk_data);
            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,2]);
            %
            assertTrue(iscell(title_pax));
            assertTrue(isempty(title_pax));
            %
            assertTrue(iscell(title_iax));
            assertEqual(size(title_iax),[4,1]);
            %
            assertTrue(iscell(display_pax));
            assertTrue(isempty(display_pax));
            %
            assertTrue(iscell(display_iax));
            assertEqual(size(display_iax),[4,1]);
            %
            assertEqual(energy_axis,4);
        end


        function test_spher_caption(this)
            skipTest('Requires generic projection refactoring');
            capt = spher_proj_caption();
            assertFalse(capt.changes_aspect_ratio);
            this.wk_data.ulabel={'\rho'  '\theta'  '\phi'  'E'};

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.wk_data);

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            %
            assertTrue(iscell(title_pax));
            assertTrue(isempty(title_pax));
            %
            assertTrue(iscell(title_iax));
            assertEqual(size(title_iax),[4,1]);
            %
            assertTrue(iscell(display_pax));
            assertTrue(isempty(display_pax));
            %
            assertTrue(iscell(display_iax));
            assertEqual(size(display_iax),[4,1]);
            %
            assertEqual(energy_axis,4);

        end
        function test_spher_caption2D(this)
            skipTest('Requires generic projection refactoring');
            capt = spher_proj_caption();
            assertFalse(capt.changes_aspect_ratio);
            this.wk_data.ulabel={ '\rho','\theta','\phi','E'};
            this.wk_data.iax=[1,4];
            %
            this.wk_data.pax=[2,3];
            % if pax defined, p has to be too.
            this.wk_data.p={[1;4;10],[2;10;20]};
            this.wk_data.dax=[1,2];
            this.wk_data.ulen=[1 0.5000 1 1];
            this.wk_data.img_range=[0.1500  -89.3891 -179.9992   40.0000;
                0.2500   89.3295  179.9985   60.0000];
            this.wk_data.uoffset=[1;1;0;0];
            this.wk_data.iint=[0.1500   40.0000; 0.2500   60.0000];
            this.wk_data.s=ones(2);
            this.wk_data.e=ones(2);
            this.wk_data.npix=ones(2);

            [ok,type,mess]=this.wk_data.check_sqw_data('b+');
            assertTrue(ok);
            assertEqual(type,'a-');
            assertTrue(isempty(mess));

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.wk_data);

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            %
            assertTrue(iscell(title_pax));
            assertEqual(size(title_pax),[2,1]);
            %
            assertTrue(iscell(title_iax));
            assertEqual(size(title_iax),[2,1]);
            %
            assertTrue(iscell(display_pax));
            assertEqual(size(display_pax),[2,1]);
            %
            assertTrue(iscell(display_iax));
            assertEqual(size(display_iax),[2,1]);
            %
            assertEqual(energy_axis,4);

        end

    end
end

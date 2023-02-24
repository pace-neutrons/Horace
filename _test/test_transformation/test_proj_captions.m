classdef test_proj_captions<TestCase
    % The test class to verify how projection works
    %
    properties
        data
    end

    methods
        function this=test_proj_captions(name)
            this=this@TestCase(name);
            %sqw/dnd data structure with fields used in caption
            ab = ortho_axes(2);
            proj  = ortho_proj;
            this.data= d2d(ab,proj);
        end

        %         function test_cube_caption(this)
        %             wk_data = this.data;
        %             capt = an_axis_caption();
        %             assertTrue(capt.changes_aspect_ratio);
        %
        %             [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
        %                 capt.data_plot_titles(wk_data);
        %             assertTrue(iscell(title_main));
        %             assertEqual(size(title_main),[1,3]);
        %
        %             assertTrue(iscell(title_pax));
        %             assertEqual(numel(title_pax),2);
        %
        %             assertTrue(iscell(title_iax));
        %             assertEqual(size(title_iax),[2,1]);
        %
        %             assertTrue(iscell(display_pax));
        %             assertEqual(size(display_pax),[2,1]);
        %
        %             assertTrue(iscell(display_iax));
        %             assertEqual(size(display_iax),[2,1]);
        %
        %             assertEqual(energy_axis,4);
        %         end
        %
        %         function test_spher_caption(obj)
        %             ldata = obj.data;
        %             ldata.proj = spher_proj();
        %
        %             existing_range = ldata.axes.get_binning_range();
        %             range = {[-10,1,10],[-20,1,20],[0,0.01,1],existing_range{4}};
        %             ab = ldata.proj.get_proj_axes_block(existing_range,range);
        %             capt = ab.axis_caption();
        %             assertFalse(capt.changes_aspect_ratio);
        %
        %
        %             [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
        %                 capt.data_plot_titles(ldata);
        %
        %             assertTrue(iscell(title_main));
        %             assertEqual(size(title_main),[1,4]);
        %
        %             assertTrue(iscell(title_pax));
        %             assertEqual(size(title_pax),[2,1]);
        %
        %             assertTrue(iscell(title_iax));
        %             assertEqual(size(title_iax),[2,1]);
        %
        %             assertTrue(iscell(display_pax));
        %             assertEqual(size(display_pax),[2,1]);
        %
        %             assertTrue(iscell(display_iax));
        %             assertEqual(size(display_iax),[2,1]);
        %
        %             assertEqual(energy_axis,4);
        %
        %         end
        function test_ortho_proj_description(~)
            op = ortho_proj('alatt',2,'angdeg',90,'u',[1,1,0],'v',[-1,1,0]);
            [totvector,in_totvector,in_vector,energy_axis] = op.axes_scales_description();


        end

    end
end

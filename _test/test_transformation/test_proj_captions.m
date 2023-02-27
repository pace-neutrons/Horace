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
            range = ones(2,4);
            range(1,1) = -2;
            range(2,1) =  2;

            range(1,4) = -5;
            range(2,4) = 20;
            ab = ortho_axes('img_range',range,'nbins_all_dims',[50,1,1,40]);
            proj  = ortho_proj('alatt',2,'angdeg',90,'u',[1,1,0],'v',[-1,1,0]);
            this.data= d2d(ab,proj);
        end

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
        function test_ortho_proj_description_dax(obj)

            dat = obj.data;
            dat.axes.dax = [2,1];
            dat.title = 'My Sample';
            dat.filename = 'My File';

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertEqual(title_main{1},'My File');
            assertEqual(title_main{2},'My Sample');

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{2},'[-1+\zeta, 1+\zeta, 1] (Å^{-1})');
            assertEqual(title_pax{1},' (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'1 \leq \xi \leq 1 in [-\xi, \xi, 0]');
            assertEqual(title_iax{2},'1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{2},'\zeta = -2:0.08:2 in [-1+\zeta, 1+\zeta, 1]');
            assertEqual(display_pax{1},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'1 =< \xi =< 1 in [-\xi, \xi, 0]');
            assertEqual(display_iax{2},'1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);

        end



        function test_ortho_proj_description(obj)

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                obj.data.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},'[-1+\zeta, 1+\zeta, 1] (Å^{-1})');
            assertEqual(title_pax{2},' (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'1 \leq \xi \leq 1 in [-\xi, \xi, 0]');
            assertEqual(title_iax{2},'1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [-1+\zeta, 1+\zeta, 1]');
            assertEqual(display_pax{2},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'1 =< \xi =< 1 in [-\xi, \xi, 0]');
            assertEqual(display_iax{2},'1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);

        end

    end
end

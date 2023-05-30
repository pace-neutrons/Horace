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
            range(1,2) = -range(2,2);
            range(1,3) = -range(2,3);

            range(1,4) = -5;
            range(2,4) = 20;
            proj  = ortho_proj('alatt',2,'angdeg',90,'u',[1,1,0],'v',[-1,1,0]);                        
            ab = ortho_axes('img_range',range,'nbins_all_dims',[50,1,1,40]);
            [~,~,ulen]  = proj.get_pix_img_transformation(3);
            ab.ulen  = ulen;

            this.data= d2d(ab,proj);
        end

        function test_spher_proj_description(obj)
            dat = obj.data;
            range = [0,0,-180,-5;8,90,-180,20];
            dat.axes = spher_axes('img_range',range,'nbins_all_dims',[50,1,1,40]);
            dat.proj = spher_proj();            

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
               dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['|Q| (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'En (mEv)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'0 \leq \theta \leq 90 in ^{o}');
            assertEqual(title_iax{2},'-180 \leq \phi \leq -180 in ^{o}');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['|Q| = 0.08:0.16:7.92 in ',char(197)','^{-1}']);
            assertEqual(display_pax{2},'En = -4.6875:0.625:19.6875 in mEv');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'0 =< \theta =< 90 in ^{o}');
            assertEqual(display_iax{2},'-180 =< \phi =< -180 in ^{o}');

            assertEqual(energy_axis,4);

        end
        

        function test_ortho_proj_description_with_dax_non_default(obj)

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
            assertEqual(title_pax{2},['[0.7071\zeta, 0.7071\zeta, 0] in 4.4429 ', ...
                char(197),'^{-1}']);
            assertEqual(title_pax{1},' (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [-0.7071\xi, 0.7071\xi, 0]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{2},'\zeta = -2:0.08:2 in [0.7071\zeta, 0.7071\zeta, 0]');
            assertEqual(display_pax{1},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [-0.7071\xi, 0.7071\xi, 0]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);

        end

        function test_ortho_proj_description_with_offset(obj)

            dat = obj.data;
            dat.proj.offset = [1,1,1,1];
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['[1+0.7071\zeta, 1+0.7071\zeta, 1] in 4.4429 ',char(197),'^{-1}']);
            assertEqual(title_pax{2},'[0, 0, 0, 1+E] (meV)'); % Re #954 why 0,0,0, why not 1,1,1,1+dE

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [1-0.7071\xi, 1+0.7071\xi, 1]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [1, 1, 1+\eta]');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [1+0.7071\zeta, 1+0.7071\zeta, 1]');
            assertEqual(display_pax{2},'E = -5:0.625:20 in [0, 0, 0, 1+E]'); % Re #954 why 0, why not 1,1,1,1+dE

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [1-0.7071\xi, 1+0.7071\xi, 1]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [1, 1, 1+\eta]');

            assertEqual(energy_axis,4);

        end
        

        function test_ortho_proj_description(obj)

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                obj.data.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['[0.7071\zeta, 0.7071\zeta, 0] in 4.4429 ',char(197),'^{-1}']);
            assertEqual(title_pax{2},' (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [-0.7071\xi, 0.7071\xi, 0]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [0.7071\zeta, 0.7071\zeta, 0]');
            assertEqual(display_pax{2},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [-0.7071\xi, 0.7071\xi, 0]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);

        end

    end
end

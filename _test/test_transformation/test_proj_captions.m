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
            obj_range = ones(2,4);
            obj_range(1,1) = -2;
            obj_range(2,1) =  2;
            obj_range(1,2) = -obj_range(2,2);
            obj_range(1,3) = -obj_range(2,3);

            obj_range(1,4) = -5;
            obj_range(2,4) = 20;
            proj  = line_proj('alatt',2,'angdeg',90,'u',[1,1,0],'v',[-1,1,0]);
            ab = line_axes('img_range',obj_range,'nbins_all_dims',[50,1,1,40]);
            [~,~,scales]  = proj.get_pix_img_transformation(3);
            ab.img_scales = scales;

            this.data= d2d(ab,proj);
        end
        %------------------------------------------------------------------
        function test_cyl_proj_description_PhiRad(obj)
            dat = obj.data;
            range = [0,0,-pi,-5;8,pi/2,pi,20];
            dat.do_check_combo_arg = false;
            dat.axes = cylinder_axes('img_range',range,'nbins_all_dims',[1,50,40,1],'axes_units','aar');
            dat.proj = cylinder_proj('type','aad');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['Q_{||} (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'\phi (rad)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq Q_{\perp} \leq 8 in ',char(197),'^{-1}']);
            assertEqual(title_iax{2},'-5 \leq En \leq 20 in meV');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['Q_{||} = 0.0157:0.031:1.56 in ',char(197),'^{-1}']);
            assertEqual(display_pax{2}, '\phi = -3.06:0.16:3.06 in rad');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< Q_{\perp} =< 8 in ',char(197),'^{-1}']);
            assertEqual(display_iax{2}, '-5 =< En =< 20 in meV');

            assertEqual(energy_axis,4);
        end

        function test_cyl_proj_description_QdErad(obj)
            dat = obj.data;
            range = [0,0,-pi,-10;8,pi/2,pi,30];
            dat.do_check_combo_arg = false;
            dat.axes = cylinder_axes('img_range',range,'nbins_all_dims',[50,1,1,40], ...
                'axes_units','aar');
            dat.proj = cylinder_proj('type','aar');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['Q_{\perp} (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'En (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq Q_{||} \leq 1.57 in ',char(197)','^{-1}']);
            assertEqual(title_iax{2},'-3.14 \leq \phi \leq 3.14 in rad');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['Q_{\perp} = 0.08:0.16:7.92 in ',char(197)','^{-1}']);
            assertEqual(display_pax{2},'En = -9.5:1:29.5 in meV');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< Q_{||} =< 1.57 in ',char(197)','^{-1}']);
            assertEqual(display_iax{2},'-3.14 =< \phi =< 3.14 in rad');

            assertEqual(energy_axis,4);
        end

        function test_cyl_proj_description_ThetaPhiDeg(obj)
            dat = obj.data;
            range = [0,0,-180,-5;8,90,180,20];
            dat.do_check_combo_arg = false;
            dat.axes = cylinder_axes('img_range',range,'nbins_all_dims',[1,50,40,1]);
            dat.proj = cylinder_proj('type','aad');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['Q_{||} (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'\phi^{o}');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq Q_{\perp} \leq 8 in ',char(197),'^{-1}']);
            assertEqual(title_iax{2},'-5 \leq En \leq 20 in meV');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['Q_{||} = 0.9:1.8:89.1 in ',char(197),'^{-1}']);
            assertEqual(display_pax{2}, '\phi = -176:9:176 in ^{o}');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< Q_{\perp} =< 8 in ',char(197),'^{-1}']);
            assertEqual(display_iax{2}, '-5 =< En =< 20 in meV');

            assertEqual(energy_axis,4);
        end

        function test_cyl_proj_description_QdEDeg(obj)
            dat = obj.data;
            range = [0,0,-180,-10;8,90,180,30];
            dat.do_check_combo_arg = false;
            dat.axes = cylinder_axes('img_range',range,'nbins_all_dims',[50,1,1,40]);
            dat.proj = cylinder_proj('type','aar');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['Q_{\perp} (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'En (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq Q_{||} \leq 90 in ',char(197),'^{-1}']);
            assertEqual(title_iax{2},'-180 \leq \phi \leq 180 in ^{o}');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['Q_{\perp} = 0.08:0.16:7.92 in ',char(197),'^{-1}']);
            assertEqual(display_pax{2},'En = -9.5:1:29.5 in meV');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< Q_{||} =< 90 in ',char(197),'^{-1}'])
            assertEqual(display_iax{2},'-180 =< \phi =< 180 in ^{o}');

            assertEqual(energy_axis,4);
        end
    end
    %======================================================================
    methods % Spherical proj captions

        function test_spher_proj_description_ThetaPhiRad(obj)
            dat = obj.data;
            range = [0,0,-pi,-5;8,pi/2,pi,20];
            dat.do_check_combo_arg = false;
            dat.axes = sphere_axes('img_range',range,'nbins_all_dims',[1,50,40,1],'axes_units','arr');
            dat.proj = sphere_proj('type','arr');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},'\theta (rad)');
            assertEqual(title_pax{2},'\phi (rad)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq |Q| \leq 8 in ',char(197),'^{-1}']);
            assertEqual(title_iax{2},'-5 \leq En \leq 20 in meV');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},'\theta = 0.0157:0.031:1.56 in rad');
            assertEqual(display_pax{2}, '\phi = -3.06:0.16:3.06 in rad');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< |Q| =< 8 in ',char(197),'^{-1}']);
            assertEqual(display_iax{2}, '-5 =< En =< 20 in meV');

            assertEqual(energy_axis,4);
        end

        function test_spher_proj_description_QdErad(obj)
            dat = obj.data;
            range = [0,0,-pi,-10;8,pi/2,pi,30];
            dat.do_check_combo_arg = false;
            dat.axes = sphere_axes('img_range',range,'nbins_all_dims',[50,1,1,40], ...
                'axes_units','arr');
            dat.proj = sphere_proj('type','add');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['|Q| (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'En (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'0 \leq \theta \leq 1.57 in rad');
            assertEqual(title_iax{2},'-3.14 \leq \phi \leq 3.14 in rad');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['|Q| = 0.08:0.16:7.92 in ',char(197)','^{-1}']);
            assertEqual(display_pax{2},'En = -9.5:1:29.5 in meV');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'0 =< \theta =< 1.57 in rad');
            assertEqual(display_iax{2},'-3.14 =< \phi =< 3.14 in rad');

            assertEqual(energy_axis,4);
        end

        function test_spher_proj_description_ThetaPhiDeg(obj)
            dat = obj.data;
            range = [0,0,-180,-5;8,90,180,20];
            dat.do_check_combo_arg = false;
            dat.axes = sphere_axes('img_range',range,'nbins_all_dims',[1,50,40,1]);
            dat.proj = sphere_proj('type','add');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},'\theta^{o}');
            assertEqual(title_pax{2},'\phi^{o}');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},['0 \leq |Q| \leq 8 in ',char(197),'^{-1}']);
            assertEqual(title_iax{2},'-5 \leq En \leq 20 in meV');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},'\theta = 0.9:1.8:89.1 in ^{o}');
            assertEqual(display_pax{2}, '\phi = -176:9:176 in ^{o}');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},['0 =< |Q| =< 8 in ',char(197),'^{-1}']);
            assertEqual(display_iax{2}, '-5 =< En =< 20 in meV');

            assertEqual(energy_axis,4);
        end

        function test_spher_proj_description_QdEDeg(obj)
            dat = obj.data;
            range = [0,0,-180,-10;8,90,180,30];
            dat.do_check_combo_arg = false;
            dat.axes = sphere_axes('img_range',range,'nbins_all_dims',[50,1,1,40]);
            dat.proj = sphere_proj('type','add');
            dat.do_check_combo_arg = true;
            dat = dat.check_combo_arg();

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,4]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            assertEqual(title_pax{1},['|Q| (',char(197),'^{-1})']);
            assertEqual(title_pax{2},'En (meV)');

            assertEqual(numel(title_iax),2);
            assertEqual(title_iax{1},'0 \leq \theta \leq 90 in ^{o}');
            assertEqual(title_iax{2},'-180 \leq \phi \leq 180 in ^{o}');

            assertEqual(numel(display_pax),2);
            assertEqual(display_pax{1},['|Q| = 0.08:0.16:7.92 in ',char(197)','^{-1}']);
            assertEqual(display_pax{2},'En = -9.5:1:29.5 in meV');

            assertEqual(numel(display_iax),2);
            assertEqual(display_iax{1},'0 =< \theta =< 90 in ^{o}');
            assertEqual(display_iax{2},'-180 =< \phi =< 180 in ^{o}');

            assertEqual(energy_axis,4);
        end
    end
    %======================================================================
    methods % Linead proj captions

        function test_line_proj_description_with_dax_non_default(obj)

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
            %assertEqual(title_pax{2},['[0.7071\zeta, -0.7071\zeta, 0] in 4.4429 ', ...
            assertEqual(title_pax{2},['[\zeta, \zeta, 0] in 4.4429 ', ...
                char(197),'^{-1}']);
            assertEqual(title_pax{1},' (meV)');

            assertEqual(numel(title_iax),2);
            %assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [0.7071\xi, 0.7071\xi, 0]');
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [-\xi, \xi, 0]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            %assertEqual(display_pax{2},'\zeta = -2:0.08:2 in [0.7071\zeta, -0.7071\zeta, 0]');
            assertEqual(display_pax{2},'\zeta = -2:0.08:2 in [\zeta, \zeta, 0]');
            assertEqual(display_pax{1},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            %assertEqual(display_iax{1},'-1 =< \xi =< 1 in [0.7071\xi, 0.7071\xi, 0]');
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [-\xi, \xi, 0]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);

        end

        function test_line_proj_description_with_offset(obj)

            dat = obj.data;
            dat.proj.offset = [1,1,1,1];
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                dat.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            %assertEqual(title_pax{1},['[1+0.7071\zeta, 1-0.7071\zeta, 1] in 4.4429 ',char(197),'^{-1}']);
            % not sure it is better
            assertEqual(title_pax{1},['[1+\zeta, 1+\zeta, 1] in 4.4429 ',char(197),'^{-1}']);

            assertEqual(title_pax{2},'[0, 0, 0, 1+E] (meV)'); % Re #954 why 0,0,0, why not 1,1,1,1+dE

            assertEqual(numel(title_iax),2);
            %assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [1+0.7071\xi, 1+0.7071\xi, 1]');
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [1-\xi, 1+\xi, 1]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [1, 1, 1+\eta]');

            assertEqual(numel(display_pax),2);
            %assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [1+0.7071\zeta, 1-0.7071\zeta, 1]');
            assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [1+\zeta, 1+\zeta, 1]');
            assertEqual(display_pax{2},'E = -5:0.625:20 in [0, 0, 0, 1+E]'); % Re #954 why 0, why not 1,1,1,1+dE

            assertEqual(numel(display_iax),2);
            %assertEqual(display_iax{1},'-1 =< \xi =< 1 in [1+0.7071\xi, 1+0.7071\xi, 1]');
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [1-\xi, 1+\xi, 1]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [1, 1, 1+\eta]');

            assertEqual(energy_axis,4);

        end

        function test_line_proj_description(obj)

            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                obj.data.data_plot_titles();

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,3]);
            assertTrue(isempty(title_main{1}));

            assertEqual(numel(title_pax),2);
            %assertEqual(title_pax{1},['[0.7071\zeta, -0.7071\zeta, 0] in 4.4429 ', ...
            assertEqual(title_pax{1},['[\zeta, \zeta, 0] in 4.4429 ', ...
                char(197),'^{-1}']);
            assertEqual(title_pax{2},' (meV)');

            assertEqual(numel(title_iax),2);
            %assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [0.7071\xi, 0.7071\xi, 0]');
            assertEqual(title_iax{1},'-1 \leq \xi \leq 1 in [-\xi, \xi, 0]');
            assertEqual(title_iax{2},'-1 \leq \eta \leq 1 in [0, 0, \eta]');

            assertEqual(numel(display_pax),2);
            %assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [0.7071\zeta, -0.7071\zeta, 0]');
            assertEqual(display_pax{1},'\zeta = -2:0.08:2 in [\zeta, \zeta, 0]');
            assertEqual(display_pax{2},'E = -5:0.625:20');

            assertEqual(numel(display_iax),2);
            %assertEqual(display_iax{1},'-1 =< \xi =< 1 in [0.7071\xi, 0.7071\xi, 0]');
            assertEqual(display_iax{1},'-1 =< \xi =< 1 in [-\xi, \xi, 0]');
            assertEqual(display_iax{2},'-1 =< \eta =< 1 in [0, 0, \eta]');

            assertEqual(energy_axis,4);
        end
    end
end

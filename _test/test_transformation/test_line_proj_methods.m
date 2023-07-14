classdef test_line_proj_methods<TestCase
    % The tests to verify main ortho_proj methods.
    %
    properties
        tests_folder
        par_file
        %en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs
        fake_sqw_par = {[],'','',35.5,1,[4.4,5.5,6.6],[100,105,110],...
            [1.02,0.99,0.02],[0.025,-0.01,1.04],...
            90,10.5,0.2,3-1/6,2.4+1/7};
    end

    methods
        function this=test_line_proj_methods(varargin)
            if nargin == 0
                name = 'test_line_proj_methods';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
            this.tests_folder = fileparts(fileparts(mfilename('fullpath')));
            this.par_file=fullfile( this.tests_folder,'common_data','gen_sqw_96dets.nxspe');

            efix = this.fake_sqw_par{4};
            en = 0.05*efix:0.2+1/50:0.95*efix;
            this.fake_sqw_par{1} = en;
            this.fake_sqw_par{2} = this.par_file;
        end

        %------------------------------------------------------------------
        function test_get_axes_block_nonortho(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_proj([1,1,0],[0, 1,0],'w',[1,1,1],'alatt',alatt,'angdeg',angdeg);
            pra.nonorthogonal = true;

            binning = {[-1,1],[-2,0.2,2],[0,1],[0,0.1,10]};
            ax = pra.get_proj_axes_block(binning,binning);

            assertTrue(ax.nonorthogonal)
            assertEqual(ax.unit_cell,[1,1,0,0;0,1,0,0;1,1,1,0;0,0,0,1]');
        end

    end
    %------------------------------------------------------------------
    methods % Test offset
        function test_get_set_img_offset_ppr_scales_hkl(~)
            alatt = [2,2,2];
            angdeg = 90;

            pra = ortho_proj([1,-1,0],[1, 1,0],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.img_offset = [0,1,0,0];
            assertElementsAlmostEqual(pra.img_offset,[0,1,0,0],'absolute',1.e-12);
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);

        end

        function test_get_set_hkl_offset_ppr_scales(~)
            alatt = [2,2,2];
            angdeg = 90;

            pra = ortho_proj([1,-1,0],[1, 1,0],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.offset = in_offset;
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);

            assertElementsAlmostEqual(pra.img_offset,[0,1,0,0],'absolute',1.e-12);

        end

        function test_set_img_offset_get_offset_scaled(~)
            alatt = [1,2,3];
            angdeg = 90;

            pra = ortho_proj([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg,'type','aaa');
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            img_offset = in_offset.*(2*pi./[alatt,1]);
            pra.img_offset = img_offset;

            assertElementsAlmostEqual(pra.img_offset,img_offset,'absolute',1.e-12);
            assertElementsAlmostEqual(pra.offset,in_offset,'absolute',1.e-12);
        end

        function test_set_offset_get_img_offset_scaled(~)
            alatt = [1,2,3];
            angdeg = 90;

            pra = ortho_proj([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg,'type','aaa');
            assertEqual(pra.offset,zeros(1,4));
            in_offset = [1,1,0,0];
            pra.offset = in_offset;
            assertEqual(pra.offset,in_offset);
            img_offset = in_offset.*(2*pi./[alatt,1]);

            assertElementsAlmostEqual(pra.img_offset,img_offset,'absolute',1.e-12);
        end

        function test_img_offset_zero(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];

            pra = ortho_proj([1,1,0],[0, 1,0],'w',[1,1,1],'alatt',alatt,'angdeg',angdeg);
            assertEqual(pra.offset,zeros(1,4));
            assertEqual(pra.offset,pra.img_offset);
        end
    end
    methods  % Bining ranges
        %------------------------------------------------------------------
        function test_bin_range_05_samp_proj2Drot45_3D_opt_vs4D_generic_withdE(~)
            % full 4D transformation with orthogonal dE axis tested against
            % equivalent 3d+1 transformation. Should give equal results
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            proj1.do_generic = true;
            proj1.do_3D_transformation = false;
            proj1.convert_targ_to_source = false;

            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,1];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[0.5*(dbr(1,4)+dbr(2,4)),1,dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});
            proj2 = ortho_proj([1,1,0],[1,-1,0],'alatt',1,'angdeg',90);
            %
            proj2.do_generic = true;
            proj2.do_3D_transformation = false;
            proj2.convert_targ_to_source = false;
            %------------------------------------------------------------
            %
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));
            %------------------------------------------------------------
            %
            proj1.do_generic = false;
            proj1.do_3D_transformation = true;
            proj1.convert_targ_to_source = false;
            %
            proj2.do_generic = false;
            proj2.do_3D_transformation = true;
            proj2.convert_targ_to_source = false;
            %------------------------------------------------------------
            [bl_startO,bl_sizeO] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_startO),numel(bl_sizeO));
            %------------------------------------------------------------

            assertEqual(bl_start,bl_startO);
            assertEqual(bl_size,bl_sizeO);

        end

        function test_binning_range_05_samp_proj2Drot45_3D_opt_vs4D_generic(~)
            % full 4D transformation with orthogonal dE axis tested against
            % equivalent 3d+1 transformation. Should give the same results
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',2,'angdeg',90);
            proj1.do_generic = true;
            proj1.do_3D_transformation = false;
            proj1.convert_targ_to_source = false;

            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,1];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});
            proj2 = ortho_proj([1,1,0],[1,-1,0],'alatt',2,'angdeg',90);
            %
            proj2.do_generic = true;
            proj2.do_3D_transformation = false;
            proj2.convert_targ_to_source = false;
            %------------------------------------------------------------
            %
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));
            %------------------------------------------------------------
            %
            proj1.do_generic = false;
            proj1.do_3D_transformation = true;
            proj1.convert_targ_to_source = false;
            %
            proj2.do_generic = false;
            proj2.do_3D_transformation = true;
            proj2.convert_targ_to_source = false;
            %------------------------------------------------------------
            [bl_startO,bl_sizeO] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_startO),numel(bl_sizeO));
            %------------------------------------------------------------

            assertEqual(bl_start,bl_startO);
            assertEqual(bl_size,bl_sizeO);

            assertEqual(numel(bl_start),7);
            % both use halo

            assertEqual(bl_startO,[9,18,27,36,48,61,74]);
            assertEqual(bl_sizeO, [3, 5, 7, 9, 8, 6, 4]);
        end

        function test_binning_range_half_sampe_proj2Drot45(~)
            % compare default generic cut (3D+1 now) with
            % old-style ranges cut
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',2,'angdeg',90);
            proj1.do_generic = true;
            proj1.convert_targ_to_source = false;

            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,1];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});
            proj2 = ortho_proj([1,1,0],[-1,1,0],'alatt',2,'angdeg',90);
            proj2.do_generic = true;
            proj2.convert_targ_to_source = false;


            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));

            % range within
            proj1.convert_targ_to_source = true;
            proj1.do_generic = false;
            proj2.convert_targ_to_source = true;
            [bl_startOld,bl_sizeOld] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_startOld),numel(bl_sizeOld));
            % old sub-algorithm provides narrower ranges as it does not use
            % halo
            % Old cells selected:
            % x\y 1   2   3   4   5   6   7   8   9  10  11
            % 1   0   0   0   0   1   1   1   1   1   1   1
            % 2   0   0   0   0   1   1   1   1   1   1   1
            % 3   0   0   0   1   1   1   1   1   1   1   1
            % 4   0   0   0   1   1   1   1   1   1   1   0
            % 5   0   0   1   1   1   1   1   1   1   1   0
            % 6   0   0   1   1   1   1   1   1   1   0   0
            % 7   0   0   1   1   1   1   1   1   1   0   0
            % 8   0   0   1   1   1   1   1   1   0   0   0
            % 9   0   0   0   1   1   1   1   1   0   0   0
            %10   0   0   0   1   1   1   1   0   0   0   0
            %11   0   0   0   0   1   1   1   0   0   0   0
            % New cells selected:   %======================
            % x\y 1   2   3   4   5   6   7   8   9  10  11
            % 1   0   0   0   0   1   1   1   1   1   1   1
            % 2   0   0   0   0   1   1   1   1   1   1   1
            % 3   0   0   0   1   1   1   1   1   1   1   1
            % 4   0   0   0   1   1   1   1   1   1   1   0
            % 5   0   0   1   1   1   1   1   1   1   1   0
            % 6   0   0   1   1   1   1   1   1   1   0   0
            % 7   0   1   1   1   1   1   1   1   1   0   0
            % 8   0   1   1   1   1   1   1   1   0   0   0
            % 9   0   0   1   1   1   1   1   1   0   0   0
            %10   0   0   1   1   1   1   1   0   0   0   0
            %11   0   0   0   1   1   1   1   0   0   0   0

            assertEqual(numel(bl_start),6);
            assertEqual(numel(bl_startOld),6);
            assertEqual(bl_start,[18,27,36,89,100,111])
            assertEqual(bl_size,[2,6,51,7,5,3])
            assertEqual(bl_startOld,[27,36,45,89,100,111]);
            assertEqual(bl_sizeOld, [4,8,42,7,5,3]);
        end
        %
        function test_binning_range_half_sampe_proj2Drot90(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);

            dbr = [0,0,0,0;1,1,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,dbr(2,1)];[0,0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});
            proj2 = ortho_proj([0,1,0],[-1,0,0],'alatt',1,'angdeg',90);



            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj2);
            assertEqual(numel(bl_start),numel(bl_size));

            % hell it knows if this is correct or not. Looks plausible
            % if you carefully analyse the image
            assertEqual(numel(bl_start),7);
            assertEqual(bl_start,[45,56,67,78,89,100,111]);
            assertEqual(bl_size, ones(1,7)*1);
        end
        function test_binning_range_half_sampe_proj2D_offset_eq_ranges_shif(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',2,'angdeg',90);

            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,dbr(2,1)];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});

            [bl_start_r,bl_size_r] = proj1.get_nrange(npix,ab0,ab1,proj1);
            assertEqual(numel(bl_start_r),numel(bl_size_r));

            bin2 = {[0.0,0.1,dbr(2,1)];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab2 = ortho_axes(bin2{:});
            proj2 = proj1;
            proj2.offset = [0.5,0,0,0];

            [bl_start_o,bl_size_o] = proj1.get_nrange(npix,ab0,ab2,proj2);
            assertEqual(numel(bl_start_o),numel(bl_size_o));

            assertEqual(bl_start_r,bl_start_o)
            assertEqual(bl_size_r,bl_size_o)

        end
        %
        function test_binning_range_half_sampe_proj2D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            proj1.do_generic = true;
            dbr = [0,0,0,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);
            bin1 = {[0.5,0.1,dbr(2,1)];[0,0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab1 = ortho_axes(bin1{:});


            proj1.do_3D_transformation = false;
            [bl_start,bl_size] = proj1.get_nrange(npix,ab0,ab1,proj1);
            assertEqual(numel(bl_start),numel(bl_size));

            nd = ab1.dimensions;
            sz1 = ab1.dims_as_ssize();
            assertEqual(nd,2)
            assertEqual(bl_start(1),5);
            assertEqual(numel(bl_start),sz1(2));
            assertEqual(bl_size,ones(1,sz1(2))*7);

            proj1.do_3D_transformation = true;
            [bl_start3,bl_size3] = proj1.get_nrange(npix,ab0,ab1,proj1);
            assertEqual(numel(bl_start),numel(bl_size));
            assertEqual(bl_start,bl_start3)
            assertEqual(bl_size,bl_size3)

        end
        function test_binning_range_the_same_1D_dE(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            proj1.do_generic = true;
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);

            proj1.do_3D_transformation = false;
            [bl_start,bl_end] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(bl_start,1);
            assertEqual(bl_end,numel(npix));

            proj1.do_3D_transformation = true;
            [bl_start,bl_end] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(bl_start,1);
            assertEqual(bl_end,numel(npix));
        end
        %
        function test_binning_range_the_same_4D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            proj1.do_generic = true;
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);

            % check the whole range using full 4D transformation
            proj1.do_3D_transformation = false;
            [nstart,nend] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(nstart,1);
            assertEqual(nend,numel(npix));

            % check the whole range using more efficient 3D+1 transformation
            % working for orthogonal dE axis
            proj1.do_3D_transformation = true;
            [nstart,nend] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(nstart,1);
            assertEqual(nend,numel(npix));
        end
        %
        function test_binning_range_the_same_1D(~)
            proj1 = ortho_proj([1,0,0],[0,1,0],'alatt',1,'angdeg',90);
            proj1.do_generic = true;
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab0 = ortho_axes(bin0{:});
            sz = ab0.dims_as_ssize();
            npix = ones(sz);

            proj1.do_3D_transformation = false;
            [bl_start,bl_end] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(bl_start,1);
            assertEqual(bl_end,numel(npix));

            proj1.do_3D_transformation = true;
            [bl_start,bl_end] = proj1.get_nrange(npix,ab0,ab0,proj1);
            assertEqual(bl_start,1);
            assertEqual(bl_end,numel(npix));
        end
    end
    methods % CUT parts
        %------------------------------------------------------------------
        %
        function test_cut_dnd(this)
            clob0 = set_temporary_warning('off','HORACE:realign_bin_edges:invalid_argument');
            clob = set_temporary_config_options(hor_config, 'use_mex', false);

            [w, grid_size, pix_range]=dummy_sqw (this.fake_sqw_par{:});
            w = dnd(w{1});
            w.s = ones(size(w.s));
            w.e = ones(size(w.s));
            w.npix = ones(size(w.s));
            wc = cut(w,0.01,0.01,[-3.0,-0.2],2);
            %[~,warn_id]=lastwarn;
            %assertEqual(warn_id,'HORACE:realign_bin_edges:invalid_argument')
            assertTrue(isa(wc,'d3d'));
            assertElementsAlmostEqual(wc.img_range,w.img_range)
            assertElementsAlmostEqual(wc.img_range,pix_range)

            assertEqual(sum(w.npix(:)),sum(wc.npix(:)));
        end
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function test_rotation_and_shift_4D(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'offset',[1,0,0,1],...
                'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'offset',[1,1,1,2],...
                'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = prb;
            pix = eye(4);

            pix_transf_spec = pra.from_this_to_targ_coord(pix);

            pra.do_generic = true;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);

            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end

        function test_rotation_and_shift_3D(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'offset',[1,0,0,0],...
                'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'offset',[1,1,1,0],...
                'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = prb;
            pix = eye(4);

            pix_transf_spec = pra.from_this_to_targ_coord(pix);

            pra.do_generic = true;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);

            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end

        function test_rotation_no_shift(~)
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_projTester([1,0,0],[0, 1,0],'alatt',alatt,'angdeg',angdeg);
            prb = ortho_projTester([1,1,0],[1,-1,0],'alatt',alatt,'angdeg',angdeg);

            pix = eye(4);

            pra.disable_srce_to_targ_optimization = true;
            pra.targ_proj  = prb;
            pix_transf_gen = pra.from_this_to_targ_coord(pix);

            pra.disable_srce_to_targ_optimization = false;
            pra.targ_proj  = prb;
            pix_transf_spec = pra.from_this_to_targ_coord(pix);


            assertElementsAlmostEqual(pix_transf_spec,pix_transf_gen);
        end
        %------------------------------------------------------------------
        function test_two_same_proj_define_unit_transf(~)
            u = [1,1,0];
            v = [1,-1,0];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_proj(u,v,'alatt',alatt,'angdeg',angdeg);
            pra.targ_proj = pra;
            pix = eye(4);

            pix_transf = pra.from_this_to_targ_coord(pix);
            assertElementsAlmostEqual(pix,pix_transf);

        end

        function test_from_this_to_targ_throws_no_targ(~)
            u = [1,1,0];
            v = [1,-1,0];
            alatt = [2.83,2,3.83];
            angdeg = [95,85,97];
            pra = ortho_proj(u,v,'alatt',alatt,'angdeg',angdeg);
            pix = eye(4);
            assertExceptionThrown(@()from_this_to_targ_coord(pra,pix),...
                'HORACE:aProjectionBase:runtime_error');
        end
    end
end

classdef test_bin_pixels_mex_nomex < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        this_folder;
        no_mex;
    end

    methods
        function obj=test_bin_pixels_mex_nomex(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_bin_pixels_mex_nomex';
            end
            obj = obj@TestCase(name);

            obj.this_folder = fileparts(which('test_bin_pixels_mex_nomex.m'));

            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
        end

        function obj=setUp(obj)
            %addpath(obj.accum_cut_folder);
            %cd(obj.accum_cut_folder);
        end

        function tearDown(obj)
            %cd(obj.curr_folder);
            %rmpath(obj.accum_cut_folder);
            set(hor_config,'use_mex',obj.use_mex);
        end

        function obj=test_bin_pixels_mex_multithread(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to bin pixels in parallel');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            [npix_1,s_1,e_1,pix_ok_1,unique_runid_1] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            clear clObPar;
            clObPar = set_temporary_config_options(parallel_config, 'threads', 8);
            [npix_8,s_8,e_8,pix_ok_8,unique_runid_8] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            assertEqual(npix_1,npix_8)
            assertEqual(s_1,s_8)
            assertEqual(e_1,e_8)
            assertEqual(pix_ok_1,pix_ok_8)
            assertEqual(unique_runid_1,unique_runid_8)
            skipTest('Only pixel sorting is currently mexed')
        end

        function obj=test_bin_pixels_on_line_proj_mex_nomex(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to bin pixels on line proj');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);

            hc = hor_config;
            hc.saveable = false;

            %check matlab-part
            hc.use_mex = false;
            [npix_m,s_m,e_m,pix_ok_m,unique_runid_m] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            %check C-part
            hc.use_mex = true;
            [npix_c,s_c,e_c,pix_ok_c,unique_runid_c] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);


            % verify results against each other.
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqualToTol(pix_ok_m,pix_ok_c);
            assertElementsAlmostEqual(unique_runid_m,unique_runid_c);
        end
        function test_bin_pixels_mex_nomex_mode0_3D_1Dmultipage_single(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[1,1,20,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            in_coord1 = single(rand(3,10));
            in_coord2 = single(rand(3,20));

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            npix_nom = [];
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord1,npix_nom);
            npix_ret_nom = out_info_nom.npix_retained;
            npix_nom_step1 = npix_nom;
            assertEqual(npix_ret_nom,sum(npix_nom(:)))
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord2,npix_nom);
            npix_ret_nom = out_info_nom.npix_retained;
            assertEqual(npix_ret_nom,sum(npix_nom(:)))

            assertEqual(size(npix_nom),[20,1]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = [];
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord1,npix_mex);
            npix_ret_mex = out_info_mex.npix_retained;
            assertEqual(npix_ret_mex ,sum(npix_ret_mex(:)))
            assertEqual(npix_nom_step1,npix_mex);
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord2,npix_mex);
            npix_ret_mex = out_info_mex.npix_retained;
            assertEqual(npix_ret_mex ,sum(npix_ret_mex(:)))
            assertEqual(size(npix_mex),[20,1]);

            assertEqual(npix_ret_nom,npix_ret_mex)
            assertEqual(npix_mex,npix_nom)
        end
        

        function test_bin_pixels_mex_nomex_mode0_3Dmultipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,30], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            in_coord1 = rand(4,10);
            in_coord2 = rand(4,20);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            npix_nom = [];
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord1,npix_nom);
            npix_ret_nom = out_info_nom.npix_retained;
            assertEqual(npix_ret_nom,sum(npix_nom(:)))
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord2,npix_nom);
            npix_ret_nom = out_info_nom.npix_retained;
            assertEqual(npix_ret_nom,sum(npix_nom(:)))

            assertEqual(size(npix_nom),[10,20,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = [];
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord1,npix_mex);
            npix_ret_mex = out_info_mex.npix_retained;
            assertEqual(npix_ret_mex ,sum(npix_ret_mex(:)))
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord2,npix_mex);
            npix_ret_mex = out_info_mex.npix_retained;
            assertEqual(npix_ret_mex ,sum(npix_ret_mex(:)))
            assertEqual(size(npix_mex),[10,20,30]);

            assertEqual(npix_ret_nom,npix_ret_mex)
            assertEqual(npix_mex,npix_nom)
        end

        function test_bin_pixels_mex_nomex_mode0_0D(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            AB = AxesBlockBase_tester('nbins_all_dims',[1,1,1,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            in_coord1 = rand(4,10);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord1);
            assertEqual(size(npix_nom),[1,1]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord1);

            assertEqual(size(npix_mex),[1,1]);
            assertEqual(out_info_nom.npix_retained,out_info_mex.npix_retained);

            assertEqual(npix_mex,npix_nom);
        end

        function test_bin_pixels_mex_nomex_mode0_4D(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[0,0,0,0;1,1,1,1]);
            in_coord1 = rand(4,10);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord1);
            assertEqual(size(npix_nom),[10,20,30,40]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord1);

            assertEqual(size(npix_mex),[10,20,30,40]);
            assertEqual(out_info_nom.npix_retained,out_info_mex.npix_retained);

            assertEqual(npix_mex,npix_nom);
        end
        function test_bin_pixels_mex_nomex_mode0_2D(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            in_coord1 = rand(4,10);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            [npix_nom,out_info_nom] = AB.bin_pixels(in_coord1);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,out_info_mex] = AB.bin_pixels(in_coord1);

            assertEqual(size(npix_mex),[10,30]);
            assertEqual(out_info_nom.npix_retained,out_info_mex.npix_retained);

            assertEqual(npix_mex,npix_nom);
        end


        function test_bin_pixels_AB_inputs_twice(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            in_coord1 = rand(4,10);
            [npix,out_data] = AB.bin_pixels(in_coord1,'-test_mex_inputs');
            assertEqual(size(npix),[10,20,30,40]);
            assertEqual(npix,zeros(10,20,30,40));
            assertEqual(out_data.coord_in,in_coord1);

            npix(2) = 10;
            in_coord2 = rand(4,10);
            [npix_out,out_data] = AB.bin_pixels(in_coord2 ,npix,'-test_mex_inputs');

            assertEqual(size(npix_out),[10,20,30,40]);
            assertEqual(npix,npix_out);
            assertEqual(out_data.coord_in,in_coord2);

        end
        function test_bin_pixels_AB_inputs(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            in_coord = rand(4,10);
            [npix,out_data] = AB.bin_pixels(in_coord,'-test_mex_inputs');

            assertEqual(size(npix),[10,20,30,40]);
            assertEqual(npix,zeros(10,20,30,40));

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,1);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertFalse(out_data.return_selected);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertTrue(isempty(out_data.pix_candidates));
            assertFalse(out_data.check_pix_selection);
        end
    end
    methods(Access=protected)
        function  rd = calc_fake_data(obj)
            rd = rundatah();
            rd.efix = obj.efix;
            rd.emode=1;
            lat = oriented_lattice(struct('alatt',[1,1,1],'angdeg',[92,88,73],...
                'u',[1,0,0],'v',[1,1,0],'psi',20));
            rd.lattice = lat;

            det = struct('filename','','filepath','');
            det.x2  = ones(1,obj.nDet);
            det.group = 1:obj.nDet;
            polar=(0:(obj.nPolar-1))*(pi/(obj.nPolar-1));
            azim=(0:(obj.nAzim-1))*(2*pi/(obj.nAzim-1));
            det.phi = reshape(repmat(azim,obj.nPolar,1),1,obj.nDet);
            det.azim =reshape(repmat(polar,obj.nAzim,1)',1,obj.nDet);
            det.width= 0.1*ones(1,obj.nAzim*obj.nPolar);
            det.height= 0.1*ones(1,obj.nAzim*obj.nPolar);
            rd.det_par = det;

            S  = rand(obj.nEn,obj.nDet);
            rd.S = S;
            rd.ERR = sqrt(S);
            rd.en =(-obj.efix+(0:(obj.nEn))*(1.99999*obj.efix/(obj.nEn)))';
        end

        function [data,pix]=gen_fake_accum_cut_data(obj,u,v)
            % build fake data to test accumulate cut

            nPixels = obj.nDet*obj.nEn;
            ebin=1.99*obj.efix/obj.nEn;
            en = -obj.efix+(0:(obj.nEn-1))*ebin;

            L1=20;
            L2=10;
            L3=2;
            E0=min(en);
            E1=max(en);
            Es=2;
            proj = line_proj(u,v,'alatt',[3,4,5],'angdeg',[90,90,90]);
            ab = line_axes([0,1,L1],[0,1,L2],[0,0.1,L3],[E0,Es,E1]);
            data = DnDBase.dnd(ab,proj);

            vv=ones(9,nPixels);
            for i=1:3
                p=data.p{i};
                ac=0.5*(p(2:end)+p(1:end-1));
                p_mi=min(ac);
                p_ma=max(ac);
                step=(p_ma-p_mi)/(nPixels-1);
                vv(i,:) =p_mi:step:p_ma;
            end
            vv(4,:)=repmat(en,1,obj.nDet);

            pix = PixelDataBase.create(vv);
        end
    end
end

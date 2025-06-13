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
    end
    methods
        function performance_mex_nomex_mode3(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            %
            AB = AxesBlockBase_tester('nbins_all_dims',[50,1,50,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);

            n_points = 50000000;
            n_repeats = 10;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode3 (bin pixels only):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-9,1.e-9])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-9,1.e-9])
            end
            tav_mex = sum(t_mex)/n_repeats;
            tav_nom = sum(t_nomex)/n_repeats;
            fprintf( ...
                '\n*** time of first step,    nomex: %4.2g(sec)  mex: %4.2g(sec); Acceleration : %4.2g\n', ...
                t_nomex(1),t_mex(1),t_nomex(1)/t_mex(1));
            fprintf( ...
                '*** Average time per step, nomex: %4.2g(sec)  mex: %4.2g(sec); Acceleration : %4.2g\n', ...
                tav_nom,tav_mex,tav_nom/tav_mex);

        end



        function test_bin_pixels_mex_nomex_mode3_2Dmultipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            pix_coord1 = rand(9,10);
            pix_coord2 = rand(9,20);
            pix1 = PixelDataMemory(pix_coord1);
            pix2 = PixelDataMemory(pix_coord2);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            in_coord = pix1.coordinates;
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2);
            assertEqual(size(npix_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2);
            assertEqual(size(npix_nom),[10,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end

        function test_bin_pixels_mex_nomex_mode3_2D_selection_works(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,50);
            selected  = rand(1,50)>0.5;
            pix = PixelDataMemory(pix_coord);
            pix = pix.tag(selected);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end

        function test_bin_pixels_mex_nomex_mode3_2D(obj)
            % bin pixels no pixel sorting
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,10);
            pix = PixelDataMemory(pix_coord);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end

        function test_bin_pixels_inputs_mode3_twice(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,20,30,40]);
            assertEqual(npix,zeros(10,20,30,40));
            assertEqual(s,npix);
            assertEqual(e,npix);
            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.pix_candidates,pix_coord);

            npix(2) = 10;
            s(1) = 10;
            e(3) = 10;
            pix_coord2 = rand(9,20);
            pix = PixelDataMemory(pix_coord2);

            in_coord = pix.coordinates;
            [npix_out,s_out,e_out,out_data] = AB.bin_pixels(in_coord,npix,s,e,pix,'-test_mex_inputs');

            assertEqual(size(npix_out),[10,20,30,40]);
            assertEqual(npix,npix_out);
            assertEqual(s,s_out);
            assertEqual(e,e_out);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.pix_candidates,pix_coord2);
        end

        function test_return_inputs_mex_mode3_2D(obj)
            % bin pixels no pixel sorting, input/output parameters
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,20,30,40]);
            assertEqual(npix,zeros(10,20,30,40));
            assertEqual(s,npix);
            assertEqual(e,npix);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,3);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertFalse(out_data.return_selected);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,pix.data);
            assertTrue(out_data.check_pix_selection);

        end
        %==================================================================
        function performance_mex_nomex_mode0(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            %
            AB = AxesBlockBase_tester('nbins_all_dims',[50,1,50,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);

            n_points = 50000000;
            n_repeats = 10;
            npix_nomex = [];
            npix_mex   = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode0:")
            for i= 1:n_repeats
                fprintf('.')
                in_coord = rand(4,n_points);
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                npix_nomex = AB.bin_pixels(in_coord,npix_nomex);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                npix_mex = AB.bin_pixels(in_coord,npix_mex);
                t_mex(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
            end
            tav_mex = sum(t_mex)/n_repeats;
            tav_nom = sum(t_nomex)/n_repeats;
            fprintf( ...
                '\n*** time of first step,    nomex: %4.2g(sec)  mex: %4.2g(sec); Acceleration : %4.2g\n', ...
                t_nomex(1),t_mex(1),t_nomex(1)/t_mex(1));
            fprintf( ...
                '*** Average time per step, nomex: %4.2g(sec)  mex: %4.2g(sec); Acceleration : %4.2g\n', ...
                tav_nom,tav_mex,tav_nom/tav_mex);

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

        function test_bin_pixels_inputs_mode0_twice(obj)
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

        function test_bin_pixels_inputs_mode0(obj)
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

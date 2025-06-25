classdef test_bin_pixels_at_AxesBlock_mex_nomex < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        this_folder;
        no_mex;
    end

    methods
        function obj=test_bin_pixels_at_AxesBlock_mex_nomex(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_bin_pixels_at_AxesBlock_mex_nomex';
            end
            obj = obj@TestCase(name);

            obj.this_folder = fileparts(which('test_bin_pixels_at_AxesBlock_mex_nomex.m'));

            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
        end
        %==================================================================
        function performance_mex_mode5_for_profile(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true,'log_level',-1);
            %
            AB = AxesBlockBase_tester('nbins_all_dims',[50,20,50,20], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);

            n_points = 20000000;
            n_repeats = 5;
            npix_mex   = []; s_mex = [];  e_mex=[];

            t_mex  = zeros(1,n_repeats);
            pix = PixelDataMemory();
            disp("*** Mex performance mode5 (bin and sort pixels):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                pix = pix.set_raw_data(pix_data);
                coord = pix.coordinates;

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

            end
            tav_mex = sum(t_mex)/n_repeats;
            fprintf( ...
                '\n*** time of first step : %4.2g(sec)  av time per step: %4.2g(sec)\n', ...
                t_mex(1),tav_mex);

        end

        function performance_mex_nomex_mode5_and_align(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            %
            AB = AxesBlockBase_tester('nbins_all_dims',[50,20,50,20], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);

            n_points = 20000000;
            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];

            al_matr = rotvec_to_rotmat([10,20,15]);

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode5 (bin and sort pixels applying alignment):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                pix = PixelDataMemAlTester(pix_data);
                coord = pix.coordinates;
                % set alignment matrix but do not apply alignment.
                % (Simulate filebased pixels)
                pix.alignment_matr = al_matr;

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
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
        function performance_mex_nomex_mode5(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            %
            AB = AxesBlockBase_tester('nbins_all_dims',[50,20,50,20], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);

            n_points = 20000000;
            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode5 (bin and sort pixels):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
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

        function test_bin_pixels_mex_nomex_mode5_multipage0Dim(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[1,1,1,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            pix_coord1 = rand(9,20);
            pix_coord2 = rand(9,15);
            pix1 = PixelDataMemory(pix_coord1);
            pix2 = PixelDataMemory(pix_coord2);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            in_coord = pix1.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom1] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom2] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2);
            assertEqual(size(npix_nom),[1,1]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex1] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            assertEqual(pix_ok_nom1,pix_ok_mex1);
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex2] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2);
            assertEqual(size(npix_nom),[1,1]);

            assertEqual(npix_mex,npix_nom);
            assertEqualToTol(s_mex,s_nom,'tol',[1.e-12,1.e-12]);
            assertEqualToTol(e_mex,e_nom,'tol',[1.e-12,1.e-12]);

            assertEqual(pix_ok_nom2,pix_ok_mex2);
        end

        function test_bin_pixels_mex_nomex_mode5_multipage(obj)
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
            [npix_nom,s_nom,e_nom,pix_ok_nom1] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom2] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2);
            assertEqual(size(npix_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex1] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            assertEqual(pix_ok_nom1,pix_ok_mex1);
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex2] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2);
            assertEqual(size(npix_nom),[10,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqualToTol(s_mex,s_nom);
            assertEqualToTol(e_mex,e_nom);


            assertEqual(pix_ok_nom2,pix_ok_mex2);
        end

        function test_bin_pixels_mode5_sort_and_align(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,20);
            pix = PixelDataMemAlTester(pix_coord);
            al_matr = rotvec_to_rotmat([10,20,15]);
            % set alignment matrix but do not apply alignment
            pix.alignment_matr = al_matr;

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
            assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12]);
        end

        function test_bin_pixels_mode5_sorting(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,20);
            pix = PixelDataMemory(pix_coord);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
            assertEqualToTol(pix_ok_nom,pix_ok_mex);
        end

        function test_bin_pixels_inputs_mode5_twice(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);


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
            [npix_out,s_out,e_out,pix_ok,out_data] = AB.bin_pixels(in_coord,npix,s,e,pix,'-test_mex_inputs');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord2);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertEqual(size(npix_out),[10,20,30,40]);
            assertEqual(npix,npix_out);
            assertEqual(s,s_out);
            assertEqual(e,e_out);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.pix_candidates,pix_coord2);
        end

        function test_return_inputs_mex_mode5_2D(obj)
            % bin pixels and sort pixels, input/output parameters
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,1,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,40]);
            assertEqual(npix,zeros(10,40));
            assertEqual(s,npix);
            assertEqual(e,npix);


            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,5);
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
        function performance_mex_nomex_mode4(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
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
            disp("*** Mex/nomex performance mode4 (binning cellarrays of data over coordinate frame):")
            for i= 1:n_repeats
                fprintf('.')
                coord = rand(4,n_points);
                sig = rand(1,n_points);
                err = rand(1,n_points);

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,{sig,err});
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,{sig,err});
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

        function test_bin_pixels_mex_nomex_mode4_3Dmultipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,15,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            in_coord1 = rand(4,30);
            in_coord2 = rand(4,20);
            sig1 = rand(1,30);
            sig2 = rand(1,20);
            err1 = rand(1,30);
            err2 = rand(1,20);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord1,npix_nom,s_nom,e_nom,{sig1,err1});
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord2,npix_nom,s_nom,e_nom,{sig2,err2});
            assertEqual(size(npix_nom),[10,15,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord1,npix_mex,s_mex,e_mex,{sig1,err1});
            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord2,npix_mex,s_mex,e_mex,{sig2,err2});
            assertEqual(size(npix_nom),[10,15,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end

        function test_mex_nomex_mode4_one_array_in(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            in_coord1 = rand(4,10);
            bin_sig    = rand(1,10);

            npix_nom = []; s_nom    = [];   e_nom    = [];
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord1 ,npix_nom,s_nom, e_nom,{bin_sig});
            assertEqual(size(npix_nom),[10,20]);
            assertEqual(size(s_nom),[10,20]);
            assertTrue(isempty(e_nom));

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord1,[],[],[],{bin_sig});
            assertEqual(size(npix_mex),[10,20]);
            assertEqual(size(s_mex),[10,20]);
            assertTrue(isempty(e_mex));


            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
        end

        function test_mex_nomex_mode4_three_arrays_in(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            AB = AxesBlockBase_tester('nbins_all_dims',[1,1,40,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            in_coord1 = rand(4,10);
            bin_sig    = rand(1,10);
            bin_err    = rand(1,10);
            npix_to_bin    = rand(1,10);            

            npix_nom = []; s_nom    = [];   e_nom    = [];
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord1 ,npix_nom,s_nom, e_nom,{bin_sig,bin_err,npix_to_bin});
            assertEqual(size(npix_nom),[40,1]);
            assertEqual(size(s_nom),[40,1]);
            assertEqual(size(e_nom),[40,1]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord1,[],[],[],{bin_sig,bin_err,npix_to_bin});
            assertEqual(size(npix_mex),[40,1]);
            assertEqual(size(s_mex),[40,1]);
            assertEqual(size(e_mex),[40,1]);


            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end
        
        function test_mex_nomex_mode4_two_arrays_in(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            in_coord1 = rand(4,10);
            bin_sig    = rand(1,10);
            bin_err    = rand(1,10);

            npix_nom = []; s_nom    = [];   e_nom    = [];
            [npix_nom,s_nom,e_nom] = AB.bin_pixels(in_coord1 ,npix_nom,s_nom, e_nom,{bin_sig,bin_err});
            assertEqual(size(npix_nom),[10,20]);
            assertEqual(size(s_nom),[10,20]);
            assertEqual(size(e_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            [npix_mex,s_mex,e_mex] = AB.bin_pixels(in_coord1,[],[],[],{bin_sig,bin_err});
            assertEqual(size(npix_mex),[10,20]);
            assertEqual(size(s_mex),[10,20]);
            assertEqual(size(e_mex),[10,20]);


            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
        end

        function test_bin_pixels_inputs_mode4_twice(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[1,20,30,1], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);

            in_coord1 = rand(4,10);
            r1 = rand(1,10); r2 = rand(1,10);
            in_sig1 = {r1,r2};
            [npix,s,e,out_data] = AB.bin_pixels(in_coord1,[],[],[],in_sig1,'-test_mex_inputs');

            assertEqual(size(npix),[20,30]);
            assertEqual(npix,zeros(20,30));
            assertEqual(s,npix);
            assertEqual(e,npix);
            assertEqual(out_data.pix_candidates,in_sig1);
            assertEqual(out_data.coord_in,in_coord1);


            npix(2) = 10;
            s(1)    = 10;
            e(10)   = 11;
            in_coord2 = rand(4,10);
            r1 = rand(1,10); r2 = rand(1,10);
            in_sig2 = {r1;r2};

            [npixO,sO,eO,out_data] = AB.bin_pixels(in_coord2,npix,s,e,in_sig2,'-test_mex_inputs');

            assertEqual(size(npix),[20,30]);
            assertEqual(npix,npixO);
            assertEqual(s,sO);
            assertEqual(e,eO);
            assertEqual(out_data.pix_candidates,in_sig2);
            assertEqual(out_data.coord_in,in_coord2);

        end

        function test_bin_pixels_inputs_mode4(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[1,20,30,1], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            in_coord = rand(4,10);
            bin_sig  = rand(1,10);
            [npix,s,e,out_data] = AB.bin_pixels(in_coord,[],[],[],{bin_sig},'-test_mex_inputs');

            assertEqual(size(npix),[20,30]);
            assertEqual(npix,zeros(20,30));
            assertEqual(s,npix);
            assertTrue(isempty(e));

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,4);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertFalse(out_data.return_selected);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,{bin_sig});
            assertFalse(out_data.check_pix_selection);
        end
        %==================================================================
        function performance_mex_nomex_mode3(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
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
end

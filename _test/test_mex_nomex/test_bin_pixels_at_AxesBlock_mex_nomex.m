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
        function performance_mex_nomex_mode7_nosort_idx_sel(obj)
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
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode7 (bin pixels + unique runid + return idx + selected):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                ids = 500+floor(100*rand(1,n_points));
                pix_data(PixelDataBase.field_index('run_idx'),:) = ids;

                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom,pix_idx_nom,is_sel_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex,pix_idx_mex,is_sel_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex);
                t_mex(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint64(pix_idx_nom),pix_idx_mex);
                assertEqual(is_sel_nom,is_sel_mex);

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
            % REFERENCE DATA: ndw2671
            %*** Mex/nomex performance mode7 (bin pixels + unique runid + return idx + selected):
            %*** time of first step,    nomex:  3.1(sec)  mex:  1.2(sec); Acceleration :  2.5
            %*** Average time per step, nomex:  3.1(sec)  mex:  1.3(sec); Acceleration :  2.3
        end

        function test_bin_pixels_mex_nomex_mode7_nosort_and_sel_multipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            pix_coord1 = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord1(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];

            pix_coord2 = rand(9,10);
            pix_id = [10,11,7,11,7, 8,5,5,10,10];
            pix_coord2(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix1 = PixelDataMemory(pix_coord1);
            pix2 = PixelDataMemory(pix_coord2);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            in_coord = pix1.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom1,uniq_id1_nom,pix_idx_nom1,sel_nom1] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom2,uniq_id2_nom,pix_idx_nom2,sel_nom2] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2,uniq_id1_nom);
            assertEqual(size(npix_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex1,uniq_id1_mex,pix_idx_mex1,sel_mex1] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            assertEqual(pix_ok_nom1,pix_ok_mex1);
            assertEqual(int64(pix_idx_nom1),pix_idx_mex1);
            assertEqual(uint32(uniq_id1_nom),uniq_id1_mex)
            assertEqual(sel_nom1,sel_mex1)
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex2,uniq_id2_mex,pix_idx_mex2,sel_mex2] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2,uniq_id1_mex);
            assertEqual(sel_nom2,sel_mex2)
            assertEqual(size(npix_nom),[10,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqualToTol(s_mex,s_nom);
            assertEqualToTol(e_mex,e_nom);
            assertEqual(int64(pix_idx_nom2),pix_idx_mex2);
            assertEqual(uint32(uniq_id2_nom),uniq_id2_mex)

            assertEqual(pix_ok_nom2,pix_ok_mex2);
        end

        function test_bin_pixels_mode7_nosort_and_sel(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];


            pix = PixelDataMemory(pix_coord);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom,unique_runid_nom,pix_id_nom,is_select_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex,pix_ok_mex,unique_runid_mex,pix_id_mex,is_select_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(uint32(unique_runid_nom),unique_runid_mex)
            assertEqual(int64(pix_id_nom),pix_id_mex)
            assertEqual(is_select_nom,is_select_mex);
            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
            assertEqualToTol(pix_ok_nom,pix_ok_mex);

            pix_sel = pix.get_pixels(is_select_mex);
            assertEqualToTol(pix_sel,pix_ok_mex);

        end

        function test_return_inputs_mex_mode7_nosort_and_selected(obj)
            % bin pixels and sort pixels, input/output parameters
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,1,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord = rand(9,10);
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,unique_id,pix_idx,is_selected,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,40]);
            assertEqual(npix,zeros(10,40));
            assertEqual(s,npix);
            assertEqual(e,npix);
            assertTrue(isempty(unique_id));
            assertTrue(isa(unique_id,'uint32'));
            assertTrue(isempty(pix_idx));
            assertTrue(isa(pix_idx,'uint64'));
            assertTrue(isempty(is_selected));
            assertTrue(isa(is_selected,'logical'));

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,bin_mode.nosort_sel);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,pix.data);
            assertTrue(out_data.check_pix_selection);
            assertEqual(out_data.pix_img_idx,pix_idx);
            assertEqual(out_data.is_pix_selected,is_selected);
        end

        %==================================================================
        function performance_mex_nomex_mode6_nosort_idx(obj)
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
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode6 (bin pixels + unique runid + return idx):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                ids = 500+floor(100*rand(1,n_points));
                pix_data(PixelDataBase.field_index('run_idx'),:) = ids;

                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom,pix_idx_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex,pix_idx_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex);
                t_mex(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(int64(pix_idx_nom),pix_idx_mex);

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
            % REFERENCE DATA: ndw2671
            %*** Mex/nomex performance mode6 (bin pixels + unique runid + return idx):
            %*** time of first step,    nomex:  3.8(sec)  mex:  1.3(sec); Acceleration :  2.6-3
            %*** Average time per step, nomex:  3.3(sec)  mex:  1.4(sec); Acceleration :  2.4
        end

        function test_bin_pixels_mex_nomex_mode6_nosort_multipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            pix_coord1 = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord1(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];

            pix_coord2 = rand(9,10);
            pix_id = [10,11,7,11,7, 8,5,5,10,10];
            pix_coord2(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix1 = PixelDataMemory(pix_coord1);
            pix2 = PixelDataMemory(pix_coord2);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            in_coord = pix1.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom1,uniq_id1_nom,pix_idx_nom1] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom2,uniq_id2_nom,pix_idx_nom2] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2,uniq_id1_nom);
            assertEqual(size(npix_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex1,uniq_id1_mex,pix_idx_mex1] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            assertEqual(pix_ok_nom1,pix_ok_mex1);
            assertEqual(int64(pix_idx_nom1),pix_idx_mex1);
            assertEqual(uint32(uniq_id1_nom),uniq_id1_mex)
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex2,uniq_id2_mex,pix_idx_mex2] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2,uniq_id1_mex);
            assertEqual(size(npix_nom),[10,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqualToTol(s_mex,s_nom);
            assertEqualToTol(e_mex,e_nom);
            assertEqual(int64(pix_idx_nom2),pix_idx_mex2);
            assertEqual(uint32(uniq_id2_nom),uniq_id2_mex)

            assertEqual(pix_ok_nom2,pix_ok_mex2);
        end

        function test_bin_pixels_mode6_nosort(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];


            pix = PixelDataMemory(pix_coord);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom,unique_runid_nom,pix_id_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex,pix_ok_mex,unique_runid_mex,pix_id_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(uint32(unique_runid_nom),unique_runid_mex)
            assertEqual(int64(pix_id_nom),pix_id_mex)
            assertEqual(npix_mex,npix_nom);
            assertEqual(s_mex,s_nom);
            assertEqual(e_mex,e_nom);
            assertEqualToTol(pix_ok_nom,pix_ok_mex);
        end

        function test_bin_pixels_inputs_mode6_twice(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            clWarn  = set_temporary_warning('off','HORACE:test_warning','HORACE:bin_pixels_c:internal_accumulator_reset');

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;

            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,unique_id,pix_img_idx,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,[],'-test_mex_inputs');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);
            assertTrue(isempty(unique_id));
            assertTrue(isa(unique_id,'uint32'));
            assertTrue(isempty(pix_img_idx));
            assertTrue(isa(pix_img_idx,'int64'));


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
            pix_coord2(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];
            pix = PixelDataMemory(pix_coord2);

            warning('HORACE:test_warning','warning to clear warning cache')
            in_coord = pix.coordinates;
            [npix_out,s_out,e_out,pix_ok,pix_id,pix_img_idx,out_data] = AB.bin_pixels(in_coord,npix,s,e,pix,pix_id,'-test_mex_inputs');
            [~,wid] = lastwarn;
            assertEqual(wid,'HORACE:bin_pixels_c:internal_accumulator_reset');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord2);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertTrue(isa(unique_id,'uint32'));
            assertEqual(pix_id,uint32([5,7,10,11]));
            assertTrue(isempty(pix_img_idx));
            assertTrue(isa(pix_img_idx,'int64'));


            assertEqual(size(npix_out),[10,20,30,40]);
            assertEqual(npix,npix_out);
            assertEqual(s,s_out);
            assertEqual(e,e_out);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.pix_candidates,pix_coord2);
        end

        function test_return_inputs_mex_mode6_nosort_2D(obj)
            % bin pixels and sort pixels, input/output parameters
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,1,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord = rand(9,10);
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,unique_id,pix_idx,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,40]);
            assertEqual(npix,zeros(10,40));
            assertEqual(s,npix);
            assertEqual(e,npix);
            assertTrue(isempty(unique_id));
            assertTrue(isa(unique_id,'uint32'));
            assertTrue(isempty(pix_idx));
            assertTrue(isa(pix_idx,'int64'));


            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,bin_mode.nosort);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,pix.data);
            assertTrue(out_data.check_pix_selection);
            assertEqual(out_data.pix_img_idx,pix_idx);

        end

        %==================================================================
        function performance_mex_nomex_mode5_sort_and_uid(obj)
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
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode5 (bin and sort pixels + unique runid):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                ids = 500+floor(100*rand(1,n_points));
                pix_data(PixelDataBase.field_index('run_idx'),:) = ids;

                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex);
                t_mex(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);

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
            % REFEFENCE Data NDW2671
            %*** Mex/nomex performance mode5 (bin and sort pixels + unique runid):
            %*** time of first step,    nomex:  5.8(sec)  mex:  2.1(sec); Acceleration :  2.7
            %*** Average time per step, nomex:  5.7(sec)  mex:  2.1(sec); Acceleration :  2.7
        end

        function test_bin_pixels_mex_nomex_mode5_multipage(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,20,1], ...
                'img_range',[0,0,0,0;0.8,0.8,1,0.8]);
            pix_coord1 = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord1(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];

            pix_coord2 = rand(9,10);
            pix_id = [10,11,7,11,7, 8,5,5,10,10];
            pix_coord2(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix1 = PixelDataMemory(pix_coord1);
            pix2 = PixelDataMemory(pix_coord2);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);

            npix_nom = [];   s_nom    = [];   e_nom    = [];
            in_coord = pix1.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom1,uniq_id1_nom] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix1);
            in_coord = pix2.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom2,uniq_id2_nom] = AB.bin_pixels(in_coord,npix_nom,s_nom,e_nom,pix2,uniq_id1_nom);
            assertEqual(size(npix_nom),[10,20]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            npix_mex = []; s_mex    = [];   e_mex    = [];

            in_coord = pix1.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex1,uniq_id1_mex] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix1);
            assertEqual(pix_ok_nom1,pix_ok_mex1);
            assertEqual(uint32(uniq_id1_nom),uniq_id1_mex)
            in_coord = pix2.coordinates;
            [npix_mex,s_mex,e_mex,pix_ok_mex2,uniq_id2_mex] = AB.bin_pixels(in_coord,npix_mex,s_mex,e_mex,pix2,uniq_id1_mex);
            assertEqual(size(npix_nom),[10,20]);

            assertEqual(npix_mex,npix_nom);
            assertEqualToTol(s_mex,s_nom);
            assertEqualToTol(e_mex,e_nom);
            assertEqual(uint32(uniq_id2_nom),uniq_id2_mex)

            assertEqual(pix_ok_nom2,pix_ok_mex2);
        end

        function test_bin_pixels_mode5_sort_and_id(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            pix_coord = rand(9,20);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];


            pix = PixelDataMemory(pix_coord);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            in_coord = pix.coordinates;
            [npix_nom,s_nom,e_nom,pix_ok_nom,unique_runid_nom] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_nom),[10,30]);

            clear clObHor
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            [npix_mex,s_mex,e_mex,pix_ok_mex,unique_runid_mex] = AB.bin_pixels(in_coord,[],[],[],pix);
            assertEqual(size(npix_mex),[10,30]);

            assertEqual(uint32(unique_runid_nom),unique_runid_mex)
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
            clWarn  = set_temporary_warning('off','HORACE:test_warning','HORACE:bin_pixels_c:internal_accumulator_reset');

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_coord = rand(9,10);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;

            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,unique_id,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,[],'-test_mex_inputs');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);
            assertTrue(isempty(unique_id));
            assertTrue(isa(unique_id,'uint32'));

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
            pix_coord2(PixelDataBase.field_index('run_idx'),:) = [pix_id,pix_id];
            pix = PixelDataMemory(pix_coord2);

            warning('HORACE:test_warning','warning to clear warning cache')
            in_coord = pix.coordinates;
            [npix_out,s_out,e_out,pix_ok,pix_id,out_data] = AB.bin_pixels(in_coord,npix,s,e,pix,pix_id,'-test_mex_inputs');
            [~,wid] = lastwarn;
            assertEqual(wid,'HORACE:bin_pixels_c:internal_accumulator_reset');

            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord2);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertTrue(isa(unique_id,'uint32'));
            assertEqual(pix_id,uint32([5,7,10,11]));

            assertEqual(size(npix_out),[10,20,30,40]);
            assertEqual(npix,npix_out);
            assertEqual(s,s_out);
            assertEqual(e,e_out);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.pix_candidates,pix_coord2);
        end

        function test_return_inputs_mex_mode5_sort_and_unique_id_2D(obj)
            % bin pixels and sort pixels, input/output parameters
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,1,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            pix_id = [10,10,11,11,7, 5,5,5,10,10];
            pix_coord = rand(9,10);
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix = PixelDataMemory(pix_coord);

            in_coord = pix.coordinates;
            [npix,s,e,pix_ok,unique_id,out_data] = AB.bin_pixels(in_coord,[],[],[],pix,'-test_mex_inputs');

            assertEqual(size(npix),[10,40]);
            assertEqual(npix,zeros(10,40));
            assertEqual(s,npix);
            assertEqual(e,npix);
            assertTrue(isempty(unique_id));
            assertTrue(isa(unique_id,'uint32'));


            assertEqual(pix_ok.data,out_data.pix_ok_data);
            assertEqual(pix_ok.data,pix_coord);
            assertEqual(pix_ok.data_range,out_data.pix_ok_data_range);
            % range matrix have been allocated and probably contains zeros
            % but this is not guaranteed.
            assertEqual(size(out_data.pix_ok_data_range),[2,9]);

            assertEqual(out_data.coord_in,in_coord);
            assertEqual(out_data.binning_mode,bin_mode.sort_and_uid);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,pix.data);
            assertTrue(out_data.check_pix_selection);

        end

        %==================================================================
        function performance_mex_mode4_for_profile_sort_pix(obj)
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
            disp("*** Mex performance mode4 (bin and sort pixels):")
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
            % REFERENCE Data ndw2671
            %*** Mex performance mode4 (bin and sort pixels):
            %*** time of first step :  1.9(sec)  av time per step:  1.8(sec)
        end

        function performance_mex_nomex_mode4_and_align(obj)
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
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode4 (bin and sort pixels applying alignment):
            %*** time of first step,    nomex:  5.9(sec)  mex:  1.7(sec); Acceleration :  3.4
            %*** Average time per step, nomex:  6.1(sec)  mex:  1.9(sec); Acceleration :  3.2
        end

        function performance_mex_nomex_mode4(obj)
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
            disp("*** Mex/nomex performance mode4 (bin and sort pixels):")
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
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode4 (bin and sort pixels):
            %*** time of first step,    nomex:  5.4(sec)  mex:  1.7(sec); Acceleration :  3.1
            %*** Average time per step, nomex:  5.4(sec)  mex:  1.8(sec); Acceleration :    3
        end

        function test_bin_pixels_mex_nomex_mode4_multipage0Dim(obj)
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

        function test_bin_pixels_mex_nomex_mode4_multipage(obj)
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

        function test_bin_pixels_mode4_sort_and_align(obj)
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

        function test_bin_pixels_mode4_sorting(obj)
            if obj.no_mex
                skipTest('Can not test mex code to bin pixels in mode 5');
            end
            AB = AxesBlockBase_tester('nbins_all_dims',[10,1,30,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            %pix_coord = rand(9,20);
            pix_coord = [...
                0.6936    0.6407    0.6058    0.2156    0.9591    0.3461    0.4608    0.5346    0.5712    0.1647    0.7259    0.8369     0.2823    0.5745    0.6971    0.8592    0.9748    0.5006    0.1485    0.4807;
                0.4426    0.3362    0.6337    0.4402    0.3327    0.0963    0.2927    0.8736    0.0584    0.4272    0.0598    0.8065     0.3287    0.2656    0.1279    0.3955    0.2310    0.3191    0.0001    0.6104;
                0.6440    0.0662    0.9269    0.9104    0.0134    0.4546    0.4363    0.9459    0.1833    0.1861    0.1094    0.8270     0.6309    0.5462    0.2659    0.5493    0.9961    0.0303    0.7255    0.4200;
                0.8657    0.5877    0.3735    0.0129    0.0945    0.8528    0.1318    0.9440    0.6747    0.2441    0.4930    0.5085     0.2576    0.6351    0.7076    0.9287    0.6741    0.8371    0.3090    0.4321;
                0.4415    0.7744    0.3418    0.1608    0.2352    0.9831    0.8627    0.2110    0.8544    0.3528    0.9903    0.4295     0.3090    0.8754    0.5039    0.1476    0.7385    0.4800    0.4727    0.9346;
                0.8208    0.3400    0.0930    0.8076    0.4111    0.8913    0.7574    0.6752    0.5285    0.6833    0.7397    0.4559     0.9184    0.9322    0.3626    0.9927    0.8962    0.1914    0.8305    0.4014;
                0.8085    0.4506    0.7776    0.5345    0.9249    0.4883    0.8323    0.7030    0.4622    0.4898    0.9398    0.6953     0.0069    0.7117    0.0938    0.4572    0.7001    0.0683    0.2891    0.6983;
                0.2812    0.2142    0.7665    0.2883    0.9962    0.7300    0.9260    0.8621    0.6814    0.5637    0.5714    0.0136     0.5878    0.2455    0.3241    0.2629    0.6974    0.6193    0.9070    0.8719;
                0.2501    0.8506    0.5617    0.1678    0.4046    0.0161    0.7434    0.3022    0.5426    0.2798    0.0633    0.9758     0.0356    0.3254    0.6039    0.5630    0.3437    0.7623    0.4827    0.5719];

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
            assertEqualToTol(pix_ok_nom.data,pix_ok_mex.data);
            assertEqualToTol(pix_ok_nom,pix_ok_mex);
        end

        function test_bin_pixels_inputs_mode4_twice(obj)
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

        function test_return_inputs_mex_mode4_2D_sort_pix(obj)
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
            assertEqual(out_data.binning_mode,bin_mode.sort_pix);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,pix.data);
            assertTrue(out_data.check_pix_selection);

        end

        %==================================================================
        function performance_mex_nomex_mode3_sigerr_cell(obj)
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
            disp("*** Mex/nomex performance mode3 (binning cellarrays of data over coordinate frame):")
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
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode3 (binning cellarrays of data over coordinate frame):
            %*** time of first step,    nomex:  2.2(sec)  mex:  0.7(sec); Acceleration :  3.2
            %*** Average time per step, nomex:  2.2(sec)  mex: 0.69(sec); Acceleration :  3.3
        end

        function test_bin_pixels_mex_nomex_mode3_3Dmultipage(obj)
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

        function test_mex_nomex_mode3_one_array_in(obj)
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

        function test_mex_nomex_mode3_three_arrays_in(obj)
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

        function test_mex_nomex_mode3_two_arrays_in(obj)
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

        function test_bin_pixels_inputs_mode3_twice(obj)
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

        function test_bin_pixels_inputs_mode3_sigerr_cell(obj)
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
            assertEqual(out_data.binning_mode,bin_mode.sigerr_cell);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertEqual(out_data.pix_candidates,{bin_sig});
            assertFalse(out_data.check_pix_selection);
        end
        %==================================================================
        function performance_mex_nomex_mode2_npix_and_sigerr(obj)
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
            disp("*** Mex/nomex performance mode2 (bin pixels + sig_err):")
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
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode2 (bin pixelsbin pixels + sig_err):
            %*** time of first step,    nomex:  3.4(sec)  mex: 0.68(sec); Acceleration :    5
            %*** Average time per step, nomex:  3.4(sec)  mex: 0.71(sec); Acceleration :  4.8
        end

        function test_bin_pixels_mex_nomex_mode2_2Dmultipage(obj)
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

        function test_bin_pixels_mex_nomex_mode2_2D_selection_works(obj)
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

        function test_bin_pixels_mex_nomex_mode2_2D(obj)
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

        function test_bin_pixels_inputs_mode2_twice(obj)
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

        function test_return_inputs_mex_mode2_sig_err_2D(obj)
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
            assertEqual(out_data.binning_mode,bin_mode.sig_err);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
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
            disp("*** Mex/nomex performance mode0 (bin coord, calc npix):")
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
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode0 (bin coord, calc npix):
            %*** time of first step,    nomex:  1.4(sec)  mex: 0.61(sec); Acceleration :  2.3
            %*** Average time per step, nomex:  1.4(sec)  mex: 0.62(sec); Acceleration :  2.2
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
            assertEqual(out_data.binning_mode,bin_mode.npix_only);
            assertEqual(out_data.num_threads, ...
                config_store.instance().get_value('parallel_config','threads'));
            assertEqual(out_data.data_range,AB.img_range)
            assertEqual(out_data.bins_all_dims,uint32(AB.nbins_all_dims));
            assertTrue(isempty(out_data.unique_runid));
            assertFalse(out_data.force_double);
            assertTrue(out_data.test_input_parsing);
            assertTrue(isempty(out_data.alignment_matr));
            assertTrue(isempty(out_data.pix_candidates));
            assertFalse(out_data.check_pix_selection);
        end
    end
end

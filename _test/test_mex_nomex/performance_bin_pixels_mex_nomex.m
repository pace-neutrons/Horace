classdef performance_bin_pixels_mex_nomex
    % Series of tests to check work of mex files against Matlab files

    properties
        this_folder;
        no_mex;
        perf_tests_list
        result_name
        perf_results;
        n_threads;
    end

    methods
        function obj=performance_bin_pixels_mex_nomex(varargin)

            obj.this_folder = fileparts(which('performance_bin_pixels_mex_nomex.m'));
            obj.n_threads = 8;
            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
            test_names = {...
                'mode8p (proj pixels + unique runid + return idx + selected)',... 8
                'mode7p (proj pixels + unique runid + return idx)',...            7
                'mode5p (proj and sort pixels + unique runid)',...                5
                'mode4p (proj and sort pixels applying alignment)',...            4a
                'mode4p (proj and sort pixels)',...                               4
                'mode2p (proj pixels + sig_err)',...                              2
                'mode0p (proj coord, calc npix)'...                               0
                'mode8 (bin pixels + unique runid + return idx + selected)',... 8
                'mode7 (bin pixels + unique runid + return idx)',...            7
                'mode6 (bin pixels + unique runid)',...                         6
                'mode5 (bin and sort pixels + unique runid)',...                5
                'mode4 (bin and sort pixels applying alignment)',...            4a
                'mode4 (bin and sort pixels)',...                               4
                'mode3 (binning cellarrays of data over coordinate frame)',...  3
                'mode2 (bin pixels + sig_err)',...                              2
                'mode0 (bin coord, calc npix)'...
                };
            test_func = {...
                @()performance_proj_mex_nomex_mode8_nosort_idx_sel(obj),... 8
                @()performance_proj_mex_nomex_mode7_nosort_id_idx(obj),...  7
                @()performance_proj_mex_nomex_mode5_sort_and_uid(obj),...   5
                @()performance_proj_mex_nomex_mode4_and_align(obj),...      4a
                @()performance_proj_mex_nomex_mode4(obj),...                4
                @()performance_proj_mex_nomex_mode2_npix_and_sigerr(obj),...2
                @()performance_proj_mex_nomex_mode0(obj)...                 0
                @()performance_mex_nomex_mode8_nosort_idx_sel(obj),... 8
                @()performance_mex_nomex_mode7_nosort_id_idx(obj),...  7
                @()performance_mex_nomex_mode6_nosort_id(obj),...      6
                @()performance_mex_nomex_mode5_sort_and_uid(obj),...   5
                @()performance_mex_nomex_mode4_and_align(obj),...      4a
                @()performance_mex_nomex_mode4(obj),...                4
                @()performance_mex_nomex_mode3_sigerr_cell(obj),...    3
                @()performance_mex_nomex_mode2_npix_and_sigerr(obj),...2
                @()performance_mex_nomex_mode0(obj)...
                };

            obj.perf_tests_list = containers.Map(test_names,test_func);
            obj.result_name = [getComputerName(),'_mex_performance_',char(datetime('today'))];
        end
        %==================================================================
        function run_all_performance_tests(obj)
            meth_names = obj.perf_tests_list.keys();

            perf_res = struct();
            for i=1:numel(meth_names)
                mode_name = split(meth_names{i});
                fh = obj.perf_tests_list(meth_names{i});
                [t_nomex,t_mex,t_omp] = fh();
                mode_name = mode_name{1};
                perf_res.(mode_name) = [t_nomex(:)';t_mex(:)';t_omp];
                fprintf('\n');
            end
            obj.perf_results = perf_res;
            if isfile(obj.result_name)
                [fp,fn,fe] = fileparts(obj.result_name);
                back_file_name = fullfile(fp,[fn,'_bak',fe]);
                movefile(obj.result_name,back_file_name,'f');
            end
            save(obj.result_name,'perf_res');
        end
        %==================================================================
        %==================================================================
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode8_nosort_idx_sel(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();
            pix.run_idx  =  500+floor(100*rand(1,n_points));

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];
            npix_omp   = []; s_omp = [];  e_omp=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj performance mode8 (bin pixels + unique runid + return idx + selected):")
            for i= 1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,is_sel_nom] = ...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex,'-selected_only');

                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,is_sel_mex] =...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex,'-selected_only');
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,is_sel_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp,'-selected_only');
                t_omp(i) = toc(t1);

                assertEqual(is_sel_nom,is_sel_mex);
                assertEqual(is_sel_nom,is_sel_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])

                pix.coordinates = rand(4,n_points);
                pix.run_idx  =  500+floor(100*rand(1,n_points));

            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE DATA: ndw2671
            %*** time of first step,    nomex:  2.1(sec)  mex:  1.1(sec); Acceleration :    2
            %*** Average time per step, nomex:  2.1(sec)  mex:    1(sec); Acceleration :    2
        end

        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode8_nosort_idx_sel(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data([50,1,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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
                [npix_nomex,s_nomex,e_nomex,is_sel_nom] = ...
                    AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,'-selected_only');
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,is_sel_mex] =...
                    AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,'-selected_only');
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,is_sel_omp] = ...
                    AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix,'-selected_only');
                t_omp(i) = toc(t1);

                assertEqual(is_sel_nom,is_sel_mex);
                assertEqual(is_sel_nom,is_sel_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE DATA: ndw2671
            %*** Mex/nomex performance mode7 (bin pixels + unique runid + return idx + selected):
            %*** time of first step,    nomex:  3.1(sec)  mex:  1.2(sec); Acceleration :  2.5
            %*** Average time per step, nomex:  3.1(sec)  mex:  1.3(sec); Acceleration :  2.3
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode7_nosort_id_idx(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();
            pix.run_idx  =  500+floor(100*rand(1,n_points));

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj mex/nomex performance mode7 (bin pixels + unique runid + return idx):")
            for i= 1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom,pix_idx_nom] =...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex,pix_idx_mex] = ...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex,uniqId_mex);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp,pix_idx_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp,uniqId_omp);
                t_omp(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint32(uniqId_nom),uniqId_omp);
                assertEqual(int64(pix_idx_nom),pix_idx_mex);
                assertEqual(int64(pix_idx_nom),pix_idx_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])

                pix.coordinates = rand(4,n_points);
                pix.run_idx  =  500+floor(100*rand(1,n_points));
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE DATA: ndw2671
            %*** time of first step,    nomex:  1.9(sec)  mex:  1.1(sec); Acceleration :  1.8
            %*** Average time per step, nomex:  1.9(sec)  mex:  1.1(sec); Acceleration :  1.8
        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode7_nosort_id_idx(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            [AB,n_points]=obj.prepare_clean_bin_data([50,20,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode7 (bin pixels + unique runid + return idx):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                ids = 500+floor(100*rand(1,n_points));
                pix_data(PixelDataBase.field_index('run_idx'),:) = ids;

                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom,pix_idx_nom] = ...
                    AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex,pix_idx_mex] =...
                    AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp,pix_idx_omp] = ...
                    AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix,uniqId_omp);
                t_omp(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint32(uniqId_nom),uniqId_omp);
                assertEqual(int64(pix_idx_nom),pix_idx_mex);
                assertEqual(int64(pix_idx_nom),pix_idx_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE DATA: ndw1737
            % *** Mex/nomex performance mode7 (bin pixels + unique runid + return idx):
            % *** first step:    nomex:  2.8(sec)  mex:  1.5(sec);  omp: 0.71(sec); Acc :  1.9/   4/ 2.1
            % *** Avrg per step: nomex:  2.9(sec)  mex:  1.4(sec);  omp: 0.73(sec); Acc :    2/ 3.9/ 1.9
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode6_nosort_id(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            [AB,n_points]=obj.prepare_clean_bin_data([50,20,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode6 (bin pixels + unique runid):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                ids = 500+floor(100*rand(1,n_points));
                pix_data(PixelDataBase.field_index('run_idx'),:) = ids;

                pix = PixelDataMemory(pix_data);
                coord = pix.coordinates;
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom] = ...
                    AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom,'-nosort');
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex] =...
                    AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex,'-nosort');
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp] = ...
                    AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix,uniqId_omp,'-nosort');
                t_omp(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint32(uniqId_nom),uniqId_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE DATA: ndw2671
            %*** Mex/nomex performance mode6 (bin pixels + unique runid + return idx):
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode5_sort_and_uid(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();
            pix.run_idx  =  500+floor(100*rand(1,n_points));

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj mex/nomex performance mode5 (bin and sort pixels + unique runid):")
            for i= 1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom] =...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex,uniqId_nom);
                %AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex] = ...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex,uniqId_mex);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp,uniqId_omp);
                t_omp(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint32(uniqId_nom),uniqId_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])

                pix.coordinates = rand(4,n_points);
                pix.run_idx  =  500+floor(100*rand(1,n_points));
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFEFENCE Data NDW2671
            %*** Proj mex/nomex performance mode5 (bin and sort pixels + unique runid):
            %*** time of first step,    nomex:  2.3(sec)  mex:  1.1(sec); Acceleration :  2.1
            %*** Average time per step, nomex:  2.4(sec)  mex:    1(sec); Acceleration :  2.3
            % REFEFENCE Data NDW1737
            %* Proj mex/nomex performance mode5 (bin and sort pixels + unique runid):
            %..........
            %*** first step:    nomex:  4.7(sec)  mex:  2.7(sec);  omp: 0.88(sec); Acc :  1.8/ 5.3/   3
            %*** Avrg per step: nomex:  5.6(sec)  mex:  2.9(sec);  omp: 0.99(sec); Acc :    2/ 5.7/ 2.9

        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode5_sort_and_uid(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data([50,20,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix,uniqId_mex);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp] = AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix,uniqId_omp);
                t_omp(i) = toc(t1);

                assertEqual(uint32(uniqId_nom),uniqId_mex);
                assertEqual(uint32(uniqId_nom),uniqId_omp);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFEFENCE Data NDW2671
            %*** Mex/nomex performance mode5 (bin and sort pixels + unique runid):
            %*** time of first step,    nomex:  5.8(sec)  mex:  2.1(sec); Acceleration :  2.7
            %*** Average time per step, nomex:  5.7(sec)  mex:  2.1(sec); Acceleration :  2.7
            % REFEFENCE Data NDW1737
            %*** Mex/nomex performance mode5 (bin and sort pixels + unique runid):
            %..........
            %*** first step:    nomex:  5.5(sec)  mex:    2(sec);  omp:  1.3(sec); Acc :  2.7/ 4.4/ 1.6
            %*** Avrg per step: nomex:  5.4(sec)  mex:  2.1(sec);  omp:  1.3(sec); Acc :  2.6/ 4.3/ 1.6
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode4_and_align(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];
            npix_omp   = []; s_omp = [];  e_omp=[];

            al_matr = rotvec_to_rotmat([10,20,15]);

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj mex/nomex performance mode4 (bin and sort pixels applying alignment):")
            for i= 1:n_repeats
                fprintf('.')

                % set alignment matrix but do not apply alignment.
                % (Simulate filebased pixels)
                pix = pix.set_raw_alignment(al_matr);

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom] = ...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = ...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex);
                t_mex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp);
                t_omp(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])

                pix.coordinates = rand(4,n_points);
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Proj mex/nomex performance mode4 (sort pixels):
            %*** time of first step,    nomex:  2.3(sec)  mex:  1.1(sec); Acceleration :  2.1
            %*** Average time per step, nomex:  2.2(sec)  mex:  1.1(sec); Acceleration :  2.1

        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode4_and_align(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data([50,20,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];
            npix_omp   = []; s_omp = [];  e_omp=[];

            al_matr = rotvec_to_rotmat([10,20,15]);

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Mex/nomex performance mode4 (bin and sort pixels applying alignment):")
            for i= 1:n_repeats
                fprintf('.')
                pix_data = rand(9,n_points);
                pix = PixelDataMemAlTester(pix_data);
                coord = pix.coordinates;
                % set alignment matrix but do not apply alignment.
                % (Simulate filebased pixels)
                pix = pix.set_raw_alignment(al_matr);


                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom] = AB.bin_pixels(coord,npix_nomex,s_nomex,e_nomex,pix);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp] = AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix);
                t_omp(i) = toc(t1);


                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode4 (bin and sort pixels applying alignment):
            %*** time of first step,    nomex:  5.9(sec)  mex:  1.7(sec); Acceleration :  3.4
            %*** Average time per step, nomex:  6.1(sec)  mex:  1.9(sec); Acceleration :  3.2
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode4(obj)

            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            n_repeats = 5;

            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();

            npix_nomex=[]; s_nomex=[]; e_nomex=[];
            npix_mex=[];   s_mex=[];   e_mex=[];
            npix_omp=[];   s_omp=[];   e_omp=[];

            disp("*** Proj mex/nomex performance mode4 (sort pixels):")
            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            for i=1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom] = ...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex);
                t_nomex(i) = toc(t1);
                fprintf('.')

                t1 = tic();
                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                [npix_mex,s_mex,e_mex,pix_ok_mex] = ...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp);
                t_omp(i) = toc(t1);


                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])

                pix.coordinates = rand(4,n_points);
            end

            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Proj mex/nomex performance mode2 (bin pixels + sig_err):
            %*** time of first step,    nomex:  1.9(sec)  mex:  0.8(sec); Acceleration :  2.4
            %*** Average time per step, nomex:  1.9(sec)  mex: 0.84(sec); Acceleration :  2.3
        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode4(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data([50,20,50,20]);

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];
            npix_omp   = []; s_omp = [];  e_omp=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp] = AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix);
                t_omp(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_omp,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(s_nomex,s_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(e_nomex,e_omp,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
                assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode4 (bin and sort pixels):
            %*** time of first step,    nomex:  5.4(sec)  mex:  1.7(sec); Acceleration :  3.1
            %*** Average time per step, nomex:  5.4(sec)  mex:  1.8(sec); Acceleration :    3
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode3_sigerr_cell(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data();

            n_repeats = 10;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode3 (binning cellarrays of data over coordinate frame):
            %*** time of first step,    nomex:  2.2(sec)  mex:  0.7(sec); Acceleration :  3.2
            %*** Average time per step, nomex:  2.2(sec)  mex: 0.69(sec); Acceleration :  3.3
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode2_npix_and_sigerr(obj)

            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end

            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            n_repeats = 10;

            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();

            npix_nomex = []; s_nomex = []; e_nomex=[];
            npix_mex   = []; s_mex   = []; e_mex=[];
            npix_omp   = []; s_omp   = []; e_omp=[];

            disp("*** Proj mex/nomex performance mode2 (bin pixels + sig_err):")
            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            for i=1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1=tic();
                [npix_nomex,s_nomex,e_nomex] = lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex);
                t_nomex(i)=toc(t1);

                fprintf('.')
                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1=tic();
                [npix_mex,s_mex,e_mex] = lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex);
                t_mex(i)=toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp] = lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp);
                t_omp(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_nomex,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1e-9 1e-9])
                assertEqualToTol(s_nomex,s_omp,'tol',[1e-9 1e-9])
                assertEqualToTol(e_nomex,e_mex,'tol',[1e-9 1e-9])
                assertEqualToTol(e_nomex,e_omp,'tol',[1e-9 1e-9])

                pix.coordinates = rand(4,n_points);
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode2_npix_and_sigerr(obj)

            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data();

            n_repeats = 10;
            npix_nomex = []; s_nomex = [];e_nomex=[];
            npix_mex   = []; s_mex = [];  e_mex=[];
            npix_omp   = []; s_omp   = []; e_omp=[];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                [npix_mex,s_mex,e_mex] = AB.bin_pixels(coord,npix_mex,s_mex,e_mex,pix);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp] = AB.bin_pixels(coord,npix_omp,s_omp,e_omp,pix);
                t_omp(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_nomex,npix_omp)
                assertEqualToTol(s_nomex,s_mex,'tol',[1e-9 1e-9])
                assertEqualToTol(s_nomex,s_omp,'tol',[1e-9 1e-9])
                assertEqualToTol(e_nomex,e_mex,'tol',[1e-9 1e-9])
                assertEqualToTol(e_nomex,e_omp,'tol',[1e-9 1e-9])
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode2 (bin pixelsbin pixels + sig_err):
            %*** time of first step,    nomex:  3.4(sec)  mex: 0.68(sec); Acceleration :    5
            %*** Average time per step, nomex:  3.4(sec)  mex: 0.71(sec); Acceleration :  4.8
        end
        %------------------------------------------------------------------
        function [t_nomex,t_mex,t_omp] = performance_proj_mex_nomex_mode0(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %

            n_repeats = 10;

            [lp,AB,pix,n_points]=obj.prepare_lp_bin_data();

            npix_nomex = [];
            npix_mex   = [];
            npix_omp   = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj mex/nomex performance mode0 (bin coord, calc npix):")
            for i= 1:n_repeats
                fprintf('.')
                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                npix_nomex  = lp.bin_pixels(AB,pix,npix_nomex,[],[]);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);
                t1 = tic();
                npix_mex = lp.bin_pixels(AB,pix,npix_mex,[],[]);
                t_mex(i) = toc(t1);

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                npix_omp = lp.bin_pixels(AB,pix,npix_omp,[],[]);
                t_omp(i) = toc(t1);

                pix.coordinates = rand(4,n_points);
                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_nomex,npix_omp)
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Proj mex/nomex performance mode4 (bin and sort pixels applying alignment):
            %*** time of first step,    nomex:  2.1(sec)  mex:  1.1(sec); Acceleration :    2
            %*** Average time per step, nomex:  2.1(sec)  mex:    1(sec); Acceleration :  2.1
            % REFERENCE Data ndlt1737
            %*** first step:    nomex:  2.9(sec)  mex:  2.3(sec);  omp: 0.46(sec); Acc :  1.3/ 6.4
            %*** Avrg per step, nomex:  2.4(sec)  mex: 0.65(sec);  omp: 0.47(sec); Acc :  3.7/ 5.1
        end
        function [t_nomex,t_mex,t_omp] = performance_mex_nomex_mode0(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            [AB,n_points]=obj.prepare_clean_bin_data();

            n_repeats = 10;
            npix_nomex = [];
            npix_mex   = [];
            npix_omp   = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
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

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                npix_omp = AB.bin_pixels(in_coord,npix_omp);
                t_omp(i) = toc(t1);

                assertEqual(npix_nomex,npix_mex)
                assertEqual(npix_nomex,npix_omp)
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);
            % REFERENCE Data ndw2671
            %*** Mex/nomex performance mode0 (bin coord, calc npix):
            %*** time of first step,    nomex:  1.4(sec)  mex: 0.61(sec); Acceleration :  2.3
            %*** Average time per step, nomex:  1.4(sec)  mex: 0.62(sec); Acceleration :  2.2
            % REFERENCE Data ndlt1737
            %*** first step:    nomex: 0.52(sec)  mex: 0.22(sec);  omp: 0.049(sec); Acc :  2.4/  10
            %*** Avrg per step, nomex: 0.54(sec)  mex: 0.067(sec);  omp: 0.05(sec); Acc :  8.1/  11
        end
        function [t_nomex,t_mex,t_omp] = profile_proj_mex_nomex_mode8_nosort_id_idx_sel(obj)
            if obj.no_mex
                skipTest('Can not test mex code to check binning against mex');
            end
            % this will recover existing configuration after test have been
            % finished and temporary mex/nomex values will be set within
            % the loop.
            clObHor = set_temporary_config_options(hor_config, 'use_mex', false,'log_level',-1);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);
            %
            rng(10);
            [lp,AB,pix,n_points] = obj.prepare_lp_bin_data();
            pix.run_idx  =  500+floor(100*rand(1,n_points));

            n_repeats = 5;
            npix_nomex = []; s_nomex = [];e_nomex=[];uniqId_nom = [];
            npix_mex   = []; s_mex = [];  e_mex=[];uniqId_mex = [];
            npix_omp   = []; s_omp = [];  e_omp=[];uniqId_omp = [];

            t_nomex = zeros(1,n_repeats);
            t_mex  = zeros(1,n_repeats);
            t_omp  = zeros(1,n_repeats);
            disp("*** Proj mex/nomex performance mode8 (bin pixels nosort + unique runid + id+idx+selected):")
            for i= 1:n_repeats
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',false);
                t1 = tic();
                [npix_nomex,s_nomex,e_nomex,pix_ok_nom,uniqId_nom,pix_idx_nom,selected_nom] =...
                    lp.bin_pixels(AB,pix,npix_nomex,s_nomex,e_nomex,uniqId_nom);
                t_nomex(i) = toc(t1);
                fprintf('.')

                config_store.instance.set_value('hor_config','use_mex',true);
                config_store.instance.set_value('parallel_config','threads',1);

                t1 = tic();
                [npix_mex,s_mex,e_mex,pix_ok_mex,uniqId_mex,pix_idx_mex,selected_mex] = ...
                    lp.bin_pixels(AB,pix,npix_mex,s_mex,e_mex,uniqId_mex);
                t_mex(i) = toc(t1);
                fprintf('.')                

                config_store.instance.set_value('parallel_config','threads',obj.n_threads);
                t1 = tic();
                [npix_omp,s_omp,e_omp,pix_ok_omp,uniqId_omp,pix_idx_omp,selected_omp] = ...
                    lp.bin_pixels(AB,pix,npix_omp,s_omp,e_omp,uniqId_omp);
                t_omp(i) = toc(t1);
                fprintf('.')                

                assertEqual(selected_nom,selected_mex);
                assertEqual(selected_nom,selected_omp);
                assertEqual(int64(pix_idx_nom),pix_idx_omp);                
            end
            obj.disp_perf_results(t_nomex,t_mex,t_omp);

            assertEqual(uint32(uniqId_nom),uniqId_mex);
            assertEqual(uint32(uniqId_nom),uniqId_omp);
            assertEqual(int64(pix_idx_nom),pix_idx_mex);
            assertEqual(int64(pix_idx_nom),pix_idx_omp);
            assertEqual(selected_nom,selected_mex);
            assertEqual(selected_nom,selected_omp);

            assertEqual(npix_nomex,npix_mex)
            assertEqualToTol(s_nomex,s_mex,'tol',[1.e-12,1.e-12])
            assertEqualToTol(e_nomex,e_mex,'tol',[1.e-12,1.e-12])
            assertEqualToTol(pix_ok_nom,pix_ok_mex,'tol',[1.e-12,1.e-12])
            assertEqualToTol(pix_ok_nom,pix_ok_omp,'tol',[1.e-12,1.e-12])
        end        
    end
    
    methods(Static)
        function [AB,n_points]=prepare_clean_bin_data(nbins_all_dims)
            if nargin == 0
                nbins_all_dims = [50,1,50,1];
            end
            AB = AxesBlockBase_tester('nbins_all_dims',nbins_all_dims, ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            n_points = 20000000;
        end

        function [lp,ab,pix,n_points]=prepare_lp_bin_data()
            ab = line_axes('nbins_all_dims',[50,1,50,1], ...
                'img_range',[0,0,0,0;1,0.8,1,0.8]);
            n_points = 50000000;
            pix_id = 10;
            pix_coord = rand(9,n_points);
            pix_coord(PixelDataBase.field_index('run_idx'),:) = pix_id;
            pix_coord(PixelDataBase.field_index('run_idx'),10:20) = 2*pix_id;

            pix = PixelDataMemory(pix_coord);
            lp = line_proj([1,1,0],[0,0,1],'alatt',[1,2,3],'angdeg',[70,80,110],'offset',[0,0,0]);
        end

        function [tav_nom,tav_mex,tav_omp] = disp_perf_results(t_nomex,t_mex,t_omp)
            n_repeats = numel(t_nomex);
            tav_mex = sum(t_mex)/n_repeats;
            tav_nom = sum(t_nomex)/n_repeats;
            tav_omp = sum(t_omp)/n_repeats;
            fprintf( ...
                '\n*** first step:    nomex: %4.2g(sec)  mex: %4.2g(sec);  omp: %4.2g(sec); Acc : %4.2g/%4.2g/%4.2g\n', ...
                t_nomex(1),t_mex(1),t_omp(1),t_nomex(1)/t_mex(1),t_nomex(1)/t_omp(1),t_mex(1)/t_omp(1));
            fprintf( ...
                '*** Avrg per step: nomex: %4.2g(sec)  mex: %4.2g(sec);  omp: %4.2g(sec); Acc : %4.2g/%4.2g/%4.2g\n', ...
                tav_nom,tav_mex,tav_omp,tav_nom/tav_mex,tav_nom/tav_omp,tav_mex/tav_omp);
        end
    end
end

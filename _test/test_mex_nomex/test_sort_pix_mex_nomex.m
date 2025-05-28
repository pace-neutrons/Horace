classdef test_sort_pix_mex_nomex < TestCase
    % Tests validate sort_pixels and how mex code works against Matlab.

    properties
        no_mex;
    end

    methods
        function obj=test_sort_pix_mex_nomex(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_sort_pix_mex_nomex';
            end
            obj = obj@TestCase(name);

            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
            % addpath(obj.this_folder);
        end
        function test_accumulate_pix_mex_nomex_with_pages(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end


            [pix1,ix1,npix1] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);

            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            clWarn = set_temporary_warning('off','HORACE:test_warning','HORACE:mex_code_problem');

            warning('HORACE:test_warning','warning issued to ensure that no other warnings are received')
            buf_size = 2*numel(ix1);
            %
            tmp_file_names = cell(1,4);
            filebase = fullfile(tmp_dir,'test_accumulate_pix_mex_nomex_with_pages_N');
            for i=1:4
                tmp_file_names{i} = sprintf('%s_%d.sqw',filebase,i);
            end
            clFiles = onCleanup(@()del_memmapfile_files(tmp_file_names));

            pci = pixfile_combine_info(tmp_file_names, numel(npix1));

            clOb = onCleanup(@()cut_data_from_file_job.accumulate_pix('cleanup'));

            for i=1:4
                pci = cut_data_from_file_job.accumulate_pix(pci,false,pix1,ix1,i*npix1,buf_size);
                assertTrue(isa(pci,'pixfile_combine_info'));
            end
            pci = cut_data_from_file_job.accumulate_pix(pci,true,[],[],4*npix1);

            assertTrue(isa(pci,'pixfile_combine_info'));
            assertEqual(pci.num_pixels,uint64(4*numel(ix1)));
            assertTrue(isfile(tmp_file_names{1}))
            assertTrue(isfile(tmp_file_names{2}))

            pos_pix_start = 8*numel(npix1)+8+4; % 8 first bytes --
            % number of bytes for number of elements in stored npix field
            % + 4 additional bytes for pixel width (number of colums in
            % pixels)
            assertEqual(pci.pos_npixstart,[0,0])
            assertEqual(pci.pos_pixstart,[pos_pix_start,pos_pix_start]);

            % ensure no other warnings have been issued
            [~,lvid] = lastwarn();
            assertEqual(lvid,'HORACE:test_warning')

        end


        function test_accumulate_pix_mex_nomex(obj)

            [pix1,ix1,npix1] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);

            clConf = set_temporary_config_options('hor_config','use_mex',false);
            clWarn = set_temporary_warning('off','HORACE:test_warning','HORACE:mex_code_problem');

            warning('HORACE:test_warning','warning issued to ensure no other warnings are received')
            buf_size = 4*numel(ix1);
            tmp_file_names = {'no_file1.tmp','no_file2.tmp','no_file3.tmp','no_file4.tmp'};
            pci = pixfile_combine_info(tmp_file_names, numel(npix1));

            clOb = onCleanup(@()cut_data_from_file_job.accumulate_pix('cleanup'));
            for i=1:2
                pix1.signal = i;
                pci = cut_data_from_file_job.accumulate_pix(pci,false,pix1,ix1,i*npix1,buf_size);
                assertTrue(isa(pci,'pixfile_combine_info'));
            end
            pc_no_mex = cut_data_from_file_job.accumulate_pix(pci,true,[],[],2*npix1);

            assertTrue(isa(pc_no_mex,'PixelDataMemory'));
            assertEqual(pc_no_mex.num_pixels,2*numel(ix1));

            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            clear clOb;
            clear clConf;
            pci = pixfile_combine_info(tmp_file_names, numel(npix1));

            clConf = set_temporary_config_options('hor_config','use_mex',true);
            clOb = onCleanup(@()cut_data_from_file_job.accumulate_pix('cleanup'));

            for i=1:2
                pix1.signal = i;
                pci = cut_data_from_file_job.accumulate_pix(pci,false,pix1,ix1,i*npix1,buf_size);
                assertTrue(isa(pci,'pixfile_combine_info'));
            end
            pc_mex = cut_data_from_file_job.accumulate_pix(pci,true,[],[],2*npix1);

            assertTrue(isa(pc_mex,'PixelDataMemory'));
            assertEqual(pc_mex.num_pixels,2*numel(ix1));
            % ensure no other warnings have been issued
            [~,lvid] = lastwarn();
            assertEqual(lvid,'HORACE:test_warning')

            assertEqual(pc_mex,pc_no_mex);
        end
        %==================================================================
        function test_sort_pix_handles_emtpy_inputs(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end

            % test nomex
            clConf = set_temporary_config_options('hor_config','use_mex',false);
            pix_sn = sort_pix({[],''},{[],''});
            % test mex
            clear clConf;
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            pix_sm = sort_pix({[],''},{[],''});

            assertEqualToTol(pix_sn, pix_sm);
            assertEqual(pix_sm.num_pixels,0);
        end

        function test_sort_pix_handles_no_distr(obj)
            % prepare pixels to sort
            %xs = 9.6:-1:0.6;
            %xp = 0.1:0.5:10;
            [pix1,ix1] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);

            % test nomex
            clConf = set_temporary_config_options('hor_config','use_mex',false);
            pix_sn = sort_pix({pix1,pix1,[],''},{ix1,ix1,[],''});
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            % test mex
            clear clConf;
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            pix_sm = sort_pix({pix1,pix1,[],''},{ix1,ix1,[],''});

            assertEqualToTol(pix_sn, pix_sm);
        end

        function test_sort_pix_handles_empty_pages(obj)
            % prepare pixels to sort
            %xs = 9.6:-1:0.6;
            %xp = 0.1:0.5:10;
            [pix1,ix1,npix1] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);


            npix = npix1+npix1;
            % test nomex
            clConf = set_temporary_config_options('hor_config','use_mex',false);
            pix_sn = sort_pix({pix1,pix1,[],''},{ix1,ix1,[],''},npix);
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            % test mex
            clear clConf;
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            pix_sm = sort_pix({pix1,pix1,[],''},{ix1,ix1,[],''},npix);

            assertEqualToTol(pix_sn, pix_sm);
        end


        function test_sort_pix_2_pages(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            % prepare pixels to sort
            cleanup_obj_pc = set_temporary_config_options(parallel_config, 'threads', 8);

            %xs = 9.6:-1:0.6;
            %xp = 0.1:0.5:10;
            [pix1,ix1,npix1] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);


            npix = npix1+npix1;
            % test nomex
            clConf = set_temporary_config_options('hor_config','use_mex',false);
            pix_sn = sort_pix({pix1,pix1},{ix1,ix1},npix);
            % test mex
            clear clConf;
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            pix_sm = sort_pix({pix1,pix1},{ix1,ix1},npix);

            assertEqualToTol(pix_sn, pix_sm);
        end

        function test_sort_pix_1_page(obj)
            % prepare pixels to sort
            cleanup_obj_hc = set_temporary_config_options(hor_config, ...
                'log_level', -1, ...
                'use_mex', false ...
                );
            cleanup_obj_pc = set_temporary_config_options(parallel_config, 'threads', 8);

            %xs = 9.6:-1:0.6;
            %xp = 0.1:0.5:10;
            [pix,ix,npix] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);

            % test sorting parameters and matlab sorting
            pix1 = sort_pix(pix,ix,[]);
            assertElementsAlmostEqual(pix1.energy_idx(1:4),[1810,1820,3810,3820]);
            assertElementsAlmostEqual(pix1.energy_idx(5:8),[1809,1819,3809,3819]);
            assertElementsAlmostEqual(pix1.energy_idx(end-3:end),[36181,36191,38181,38191]);

            pix2 = sort_pix(pix,ix,npix,[]);
            assertElementsAlmostEqual(pix1.data,pix2.data);

            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            % test mex
            clear cleanup_obj_hc
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);

            pix1 = sort_pix(pix,ix,npix);
            assertElementsAlmostEqual(pix1.energy_idx(1:4),[1810,1820,3810,3820]);
            assertElementsAlmostEqual(pix1.data, pix2.data);

            pix0 = PixelData(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix);
            assertElementsAlmostEqual(pix0a.data, pix2.data,'absolute',1.e-6);
        end

        function test_mex_keeps_precision(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end

            [pix,ix,npix] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);
            % test mex
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            pix1 = sort_pix(pix,ix,npix,[]);

            assertTrue(isa(pix1.data,'double'))

            pix0 = PixelDataBase.create(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,[],true);
            assertTrue(isa(pix0a.data,'single'))
            assertElementsAlmostEqual(pix0a.data, pix1.data,'absolute',1.e-6);
        end

        function test_mex_changes_precision(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);

            [pix,ix,npix] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);

            % test mex
            pix1 = sort_pix(pix,ix,npix,[],true);

            assertTrue(isa(pix1.data,'double'))

            pix0 = PixelDataBase.create(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,[]);

            assertTrue(isa(pix0a.data,'double'))
            assertElementsAlmostEqual(pix0a.data, pix1.data,'absolute',1.e-6);

        end


        function profile_sort_pix(obj)
            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end

            xs = 9.99:-0.1:0.01;
            xp = 0.01:0.1:9.99;
            [pix,ix,npix] = obj.build_pix_page_for_sorting(xs,xp);

            pix0 = pix;
            pix0.data = single(pix.data);
            ix0 = int64(ix);


            disp('Profile started')
            %profile on
            % test sorting parameters and matlab sorting
            clConf = set_temporary_config_options('hor_config','use_mex',true,'force_mex_if_use_mex',true);
            disp('sorting pixels with signle precision, keep precision:')
            t1a=tic();
            pix1 = sort_pix(pix0,ix0,npix,[],true);
            t2=toc(t1a) % ~2 sec
            clear pix1;
            disp('sorting pixels with signle precision, change precision:')
            t1b=tic();
            pix1 = sort_pix(pix,ix,npix,[],false);
            t3=toc(t1b) %
            clear pix1;

            pix0.data = pix.data;
            disp('sorting pixels with double precision:')
            t1c=tic();
            pix1 = sort_pix(pix,ix,npix,[],false);
            t3a=toc(t1c) %
            clear pix1;

            disp('sorting pixels  with signle precision using MATLAB, keep precision:')
            pix0.data = single(pix.data);
            clear clConf;
            clConf = set_temporary_config_options('hor_config','use_mex',false);
            profile on
            t1d =tic();
            pix1 = sort_pix(pix0,ix0,npix,[],true);
            t4=toc(t1d) % ~20 sec
            clear pix1;

            profile off
            profview;

            disp('sorting pixels  with double precision using MATLAB, keep precision:')
            pix0.data = pix.data;
            t1d =tic();
            pix1 = sort_pix(pix0,ix0,npix,[],true);
            t4=toc(t1d) % ~20 sec
            clear pix1;

        end

    end
    methods(Access=protected)
        function [pix,ix,npix] = build_pix_page_for_sorting(~,xs,xp)
            % pix=ones(9,40000);
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            NumPix = numel(ux);
            pix=ones(9,NumPix);
            npix_size = [10,10,10,10];
            npix = ones(npix_size)*(NumPix/prod(npix_size));

            pix(1,:) = ux(:);
            pix(2,:) = uy(:);
            pix(3,:) = uz(:);
            pix(4,:) = et(:);
            pix(7,:) = 1:NumPix;
            pix = PixelDataBase.create(pix);

            ix = ceil(pix.u1);
            iy = ceil(pix.u2);
            iz = ceil(pix.u3);
            ie = ceil(pix.dE);
            ix = sub2ind(size(npix), ix,iy,iz,ie);
            ix = ix(:);
        end
    end
end

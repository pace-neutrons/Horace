classdef test_sort_pix_mex_nomex < TestCase
    % Series of tests to check work of mex files against Matlab files

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
            pix_sn = sort_pix({pix1,pix1},{ix1,ix1},npix,'-nomex');
            % test mex
            pix_sm = sort_pix({pix1,pix1},{ix1,ix1},npix,'-force_mex');

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

            pix2 = sort_pix(pix,ix,npix,'-nomex');
            assertElementsAlmostEqual(pix1.data,pix2.data);

            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for sorting the pixels');
            end
            % test mex
            pix1 = sort_pix(pix,ix,npix,'-force_mex');
            assertElementsAlmostEqual(pix1.energy_idx(1:4),[1810,1820,3810,3820]);
            assertElementsAlmostEqual(pix1.data, pix2.data);

            pix0 = PixelData(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,'-force_mex');
            assertElementsAlmostEqual(pix0a.data, pix2.data,'absolute',1.e-6);            
        end

        function test_mex_keeps_precision(obj)
            [pix,ix,npix] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);
            % test mex
            pix1 = sort_pix(pix,ix,npix,'-force_mex');

            assertTrue(isa(pix1.data,'double'))

            pix0 = PixelDataBase.create(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,'-force_mex','-keep_precision');
            assertTrue(isa(pix0a.data,'single'))
            assertElementsAlmostEqual(pix0a.data, pix1.data,'absolute',1.e-6);
        end

        function test_mex_changes_precision(obj)
            [pix,ix,npix] = obj.build_pix_page_for_sorting(9.6:-1:0.6,0.1:0.5:10);
            % test mex
            pix1 = sort_pix(pix,ix,npix,'-force_mex');

            assertTrue(isa(pix1.data,'double'))

            pix0 = PixelDataBase.create(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,'-force_mex');

            assertTrue(isa(pix0a.data,'double'))
            assertElementsAlmostEqual(pix0a.data, pix1.data,'absolute',1.e-6);

        end


        function profile_sort_pix(obj)
            xs = 9.99:-0.1:0.01;
            xp = 0.01:0.1:9.99;
            [pix,ix,npix] = obj.build_pix_page_for_sorting(xs,xp);

            pix0 = pix;
            pix0.data = single(pix.data);
            ix0 = int64(ix);


            disp('Profile started')
            profile on
            % test sorting parameters and matlab sorting
            t1=tic();
            pix1 = sort_pix(pix0,ix0,npix,'-force_mex','-keep_precision');
            t2=toc(t1) % 2 sec
            clear pix1;
            pix1 = sort_pix(pix,ix,npix,'-force_mex','-keep_precision');
            t3=toc(t1); % 25sec
            clear pix1;
            t3r = t3-t2
            pix1 = sort_pix(pix0,ix0,npix,'-nomex','-keep_precision');
            t4=toc(t1); % 50 sec
            clear pix1;
            t4= t4-t3

            profile off
            profview;

        end

    end
    methods(Access=protected)
        function [pix,ix,npix] = build_pix_page_for_sorting(~,xs,xp)
            % pix=ones(9,40000);
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            NumPix = numel(ux);
            pix=ones(9,NumPix);
            npix = ones(10,10,10,10)*(NumPix/10000);

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
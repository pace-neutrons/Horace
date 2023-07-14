classdef test_main_mex < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        accum_cut_folder;
        this_folder;
        curr_folder;

        nPolar=99;
        nAzim =101;
        nDet;
        nEn  = 102;
        efix=100;
        use_mex;
        no_mex;
    end

    methods
        function obj=test_main_mex(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_mex_nomex';
            end
            obj = obj@TestCase(name);

            pths = horace_paths;

            if ispc
                this.accum_cut_folder=fullfile(pths.horace,'\@sqw');
            else
                this.accum_cut_folder=fullfile(pths.horace,'@sqw');
            end
            obj.this_folder = fileparts(which('test_main_mex.m'));
            obj.curr_folder = pwd();
            obj.nDet=obj.nPolar*obj.nAzim;

            obj.use_mex = get(hor_config,'use_mex');
            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
            % addpath(obj.this_folder);
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

        function obj=test_accum_cut_mex_multithread(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to accumulate_cut');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

            [npix_1,s_1,e_1,pix_ok_1,unique_runid_1] = ...
                cut_data_from_file_job.bin_pixels(data.proj,data.axes,pix);

            par.threads = 8;
            [npix_8,s_8,e_8,pix_ok_8,unique_runid_8] = ...
                cut_data_from_file_job.bin_pixels(data.proj,data.axes,pix);

            assertEqual(npix_1,npix_8)
            assertEqual(s_1,s_8)
            assertEqual(e_1,e_8)
            assertEqual(pix_ok_1,pix_ok_8)
            assertEqual(unique_runid_1,unique_runid_8)
            skipTest('Only pixel sorting is currently mexed')
        end


        function obj=test_accum_cut(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to accumulate_cut');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);

            hc = hor_config;
            hc.saveable = false;

            %check matlab-part
            hc.use_mex = false;
            [npix_m,s_m,e_m,pix_ok_m,unique_runid_m] = ...
                cut_data_from_file_job.bin_pixels(data.proj,data.axes,pix);

            %check C-part
            hc.use_mex = true;
            [npix_c,s_c,e_c,pix_ok_c,unique_runid_c] = ...
                cut_data_from_file_job.bin_pixels(data.proj,data.axes,pix);


            % verify results against each other.
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqualToTol(pix_ok_m,pix_ok_c);
            assertElementsAlmostEqual(unique_runid_m,unique_runid_c);
        end

        function obj=test_calc_proj(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to calc_projections');
            end

            hc = hor_config;
            hc.saveable = false;

            rd =calc_fake_data(obj);

            hc.use_mex = false;

            [pix_range_matl,pix_matl,rd]=rd.calc_projections();

            hc.use_mex = true;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);
        end

        function test_calc_proj_options(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code for calc_projections with parameters');
            end

            rd = calc_fake_data(obj);
            hcf = hor_config;
            hcf.saveable = false;


            hcf.use_mex = false;
            [pix_range_matl,pix_matl]=rd.calc_projections();
            hcf.use_mex = true;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);

            hcf.use_mex = false;
            [pix_range_matl,pix_matl]=rd.calc_projections();

            assertEqual(size(pix_matl.data, 1), 9);
            hcf.use_mex = true;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);

            assertEqual(size(pix_c.data, 1), 9);
        end

        function test_recompute_bin_data(obj)

            hc = hor_config;
            pc = parallel_config;
            cleanup_obj_hc = set_temporary_config_options(hor_config, ...
                                                          'log_level', -1, ...
                                                          'use_mex', false ...
                                                         );
            cleanup_obj_pc = set_temporary_config_options(parallel_config, 'threads', 8);

            test_sqw = sqw();
            pix=PixelDataBase.create(ones(9,40000));
            xs = 0.1:1:10;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix.coordinates = [ux(:)';uy(:)';uz(:)';et(:)'];
            npix = 4*ones(10,10,10,10);
            ab = ortho_axes('nbins_all_dims',[10,10,10,10],'img_range',[0,0,0,0;2,2,2,2]);
            test_sqw.data = DnDBase.dnd(ab,ortho_proj);
            test_sqw.data.npix = npix;
            test_sqw.pix  = pix;

            new_sqw = recompute_bin_data(test_sqw);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(4*s,npix);
            assertElementsAlmostEqual((4*4)*e,npix);

            if obj.no_mex
                skipTest('MEX code is broken and can not be used to check against Matlab for recompute_bin_data');
            end

            hc.use_mex = true;
            par.threads = 1;
            new_sqw1 = recompute_bin_data(test_sqw);
            assertElementsAlmostEqual(new_sqw1.data.s,s)
            assertElementsAlmostEqual(new_sqw1.data.e,e)

            hc.use_mex = true;
            par.threads = 8;
            new_sqw2 = recompute_bin_data(test_sqw);
            assertElementsAlmostEqual(new_sqw2.data.s,s)

            assertElementsAlmostEqual(new_sqw2.data.e,e)

        end

        function test_sort_pix(obj)
            % prepare pixels to sort
            cleanup_obj_hc = set_temporary_config_options(hor_config, ...
                                                          'log_level', -1, ...
                                                          'use_mex', false ...
                                                         );
            cleanup_obj_pc = set_temporary_config_options(parallel_config, 'threads', 8);

            pix=ones(9,40000);
            xs = 9.6:-1:0.6;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix(1,:) = ux(:);
            pix(2,:) = uy(:);
            pix(3,:) = uz(:);
            pix(4,:) = et(:);
            pix(7,:) = 1:size(pix,2);
            pix = PixelDataBase.create(pix);
            npix = 4*ones(10,10,10,10);
            ix = ceil(pix.u1);
            iy = ceil(pix.u2);
            iz = ceil(pix.u3);
            ie = ceil(pix.dE);
            ix = sub2ind(size(npix), ix,iy,iz,ie);

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

            pix0 = PixelDataBase.create(single(pix.data));
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,'-force_mex');
            assertElementsAlmostEqual(pix0a.data, pix2.data,'absolute',1.e-6);

        end

        function profile_sort_pix(~)
            xs = 9.99:-0.1:0.01;
            xp = 0.01:0.1:9.99;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            NumPix = numel(ux);
            pix=ones(9,NumPix);
            pix(1,:) = ux(:);
            pix(2,:) = uy(:);
            pix(3,:) = uz(:);
            pix(4,:) = et(:);
            pix(7,:) = 1:NumPix;
            npix = ones(10,10,10,10)*(NumPix/10000);
            ix = ceil(pix(1,:));
            iy = ceil(pix(2,:));
            iz = ceil(pix(3,:));
            ie = ceil(pix(4,:));
            ix = sub2ind(size(npix), ix,iy,iz,ie);
            pix0 = single(pix);
            ix0 = int64(ix);
            clear iy iz ie ux uy uz et

            disp('Profile started')
            profile on
            % test sorting parameters and matlab sorting
            t1=tic();
            pix1 = sort_pix(pix0,ix0,npix,'-force_mex','-keep_type');
            t2=toc(t1);
            pix1 = sort_pix(pix,ix,npix,'-force_mex','-keep_type');
            t3=toc(t2);
            pix1 = sort_pix(pix0,ix0,npix,'-nomex','-keep_type');
            t4=toc(t3);

            profile off
            profview;

        end

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
            proj = ortho_proj(u,v,'alatt',[3,4,5],'angdeg',[90,90,90]);
            ab = ortho_axes([0,1,L1],[0,1,L2],[0,0.1,L3],[E0,Es,E1]);
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

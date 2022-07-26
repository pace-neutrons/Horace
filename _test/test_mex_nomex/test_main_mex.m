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
    end

    methods
        function this=test_main_mex (varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_mex_nomex';
            end
            this = this@TestCase(name);

            pths = horace_paths;

            if ispc
                this.accum_cut_folder=fullfile(pths.horace,'\@sqw');
            else
                this.accum_cut_folder=fullfile(pths.horace,'@sqw');
            end
            this.this_folder = fileparts(which('test_main_mex.m'));
            this.curr_folder = pwd();
            this.nDet=this.nPolar*this.nAzim;

            this.use_mex = get(hor_config,'use_mex');
            % addpath(this.this_folder);
        end
        function this=setUp(this)
            %addpath(this.accum_cut_folder);
            %cd(this.accum_cut_folder);
        end
        function tearDown(this)
            %cd(this.curr_folder);
            %rmpath(this.accum_cut_folder);
            set(hor_config,'use_mex',this.use_mex);
        end

        function this=test_accum_cut_mex_multithread(this)
            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('Can not use and test mex code to accumulate_cut');
            end

            [data,proj]=gen_fake_accum_cut_data(this,[1,0,0],[0,1,0]);

            hc = hor_config;
            hc.saveable = false;
            ds = hc.get_data_to_store();
            clOb = onCleanup(@()set(hc,ds));

            hc.threads = 1;
            hc.use_mex= true;
            [npix_1,s_1,e_1,pix_ok_1,unique_runid_1] = ...
                cut_data_from_file_job.bin_pixels(proj,data,data.pix);

            hc.threads = 8;
            [npix_8,s_8,e_8,pix_ok_8,unique_runid_8] = ...
                cut_data_from_file_job.bin_pixels(proj,data,data.pix);


            assertEqual(npix_1,npix_8)
            assertEqual(s_1,s_8)
            assertEqual(e_1,e_8)
            assertEqual(pix_ok_1,pix_ok_8)
            assertEqual(unique_runid_1,unique_runid_8)
        end


        function this=test_accum_cut(this)
            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('Can not use and test mex code to accumulate_cut');
            end



            [data,proj]=gen_fake_accum_cut_data(this,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);

            hc = hor_config;
            current_state = hc.use_mex;
            clob = onCleanup(@()set(hc,'use_mex',current_state));
            hc.saveable = false;

            %check matlab-part
            hc.use_mex = false;
            [npix_m,s_m,e_m,pix_ok_m,unique_runid_m] = ...
                cut_data_from_file_job.bin_pixels(proj,data,data.pix);

            %check C-part
            hc.use_mex = true;
            [npix_c,s_c,e_c,pix_ok_c,unique_runid_c] = ...
                cut_data_from_file_job.bin_pixels(proj,data,data.pix);


            % verify results against each other.
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqualToTol(pix_ok_m,pix_ok_c);
            assertElementsAlmostEqual(unique_runid_m,unique_runid_c);
            skipTest('Only pixel sorting is currently mexed')
        end

        function this=test_calc_proj(this)
            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('Can not use and test mex code to calc_projections');
            end                        %
            hc = hor_config;
            current_state = hc.use_mex;
            clob = onCleanup(@()set(hc,'use_mex',current_state));
            hc.saveable = false;

            rd =calc_fake_data(this);
            %
            hc.use_mex = false;

            [pix_range_matl,pix_matl,rd]=rd.calc_projections();

            hc.use_mex = true;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);
        end

        function test_calc_proj_options(this)
            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('Can not use and test mex code for calc_projections with parameters');
            end


            rd = calc_fake_data(this);
            hcf = hor_config;
            current_state = hcf.use_mex;
            clob = onCleanup(@()set(hcf,'use_mex',current_state));
            hcf.saveable = false;


            hcf.use_mex = 0;
            [pix_range_matl,pix_matl]=rd.calc_projections();
            hcf.use_mex = 1;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);



            hcf.use_mex = 0;
            [pix_range_matl,pix_matl]=rd.calc_projections();

            assertEqual(size(pix_matl.data, 1), 9);
            hcf.use_mex = 1;
            [pix_range_c,pix_c]=rd.calc_projections();

            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl.data,pix_c.data,'absolute',1.e-8);

            assertEqual(size(pix_c.data, 1), 9);
        end
        function test_recompute_bin_data(~)
            [cur_mex,log_level,n_threads] = get(hor_config,'use_mex','log_level','threads');
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'log_level',log_level,'threads',n_threads));

            test_sqw = sqw();
            pix=PixelData(ones(9,40000));
            xs = 0.1:1:10;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix.coordinates = [ux(:)';uy(:)';uz(:)';et(:)'];
            npix = 4*ones(10,10,10,10);
            test_sqw.data.npix = npix;
            test_sqw.data.pix  = pix;
            set(hor_config,'use_mex',false);
            new_sqw = recompute_bin_data_tester(test_sqw);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(4*s,npix);
            assertElementsAlmostEqual((4*4)*e,npix);


            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('MEX code is broken and can not be used to check against Matlab for recompute_bin_data');
            end
            set(hor_config,'use_mex',true,'threads',1);
            new_sqw1 = recompute_bin_data_tester(test_sqw);
            assertElementsAlmostEqual(new_sqw1.data.s,s)
            assertElementsAlmostEqual(new_sqw1.data.e,e)

            set(hor_config,'use_mex',true,'threads',8);
            new_sqw2 = recompute_bin_data_tester(test_sqw);
            assertElementsAlmostEqual(new_sqw2.data.s,s)
            assertElementsAlmostEqual(new_sqw2.data.e,e)

        end


        function test_sort_pix(~)
            % prepare pixels to sort
            [cur_mex,log_level,n_threads] = get(hor_config,'use_mex','log_level','threads');
            cleanup_obj=onCleanup(@()set(hor_config,'use_mex',cur_mex,'log_level',log_level,'threads',n_threads));

            pix=ones(9,40000);
            xs = 9.6:-1:0.6;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix(1,:) = ux(:);
            pix(2,:) = uy(:);
            pix(3,:) = uz(:);
            pix(4,:) = et(:);
            pix(7,:) = 1:size(pix,2);
            pix = PixelData(pix);
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

            [~,n_errors] = check_horace_mex();
            if n_errors>0
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
            t2=toc(t1)
            pix1 = sort_pix(pix,ix,npix,'-force_mex','-keep_type');
            t3=toc(t2);
            pix1 = sort_pix(pix0,ix0,npix,'-nomex','-keep_type');
            t4=toc(t3);

            profile off
            profview;

        end

        function  rd = calc_fake_data(this)
            rd = rundatah();
            rd.efix = this.efix;
            rd.emode=1;
            lat = oriented_lattice(struct('alatt',[1,1,1],'angdeg',[92,88,73],...
                'u',[1,0,0],'v',[1,1,0],'psi',20));
            rd.lattice = lat;

            det = struct('filename','','filepath','');
            det.x2  = ones(1,this.nDet);
            det.group = 1:this.nDet;
            polar=(0:(this.nPolar-1))*(pi/(this.nPolar-1));
            azim=(0:(this.nAzim-1))*(2*pi/(this.nAzim-1));
            det.phi = reshape(repmat(azim,this.nPolar,1),1,this.nDet);
            det.azim =reshape(repmat(polar,this.nAzim,1)',1,this.nDet);
            det.width= 0.1*ones(1,this.nAzim*this.nPolar);
            det.height= 0.1*ones(1,this.nAzim*this.nPolar);
            rd.det_par = det;

            S   = rand(this.nEn,this.nDet);
            rd.S   = S;
            rd.ERR = sqrt(S);
            rd.en =(-this.efix+(0:(this.nEn))*(1.99999*this.efix/(this.nEn)))';


        end
        function [data,proj]=gen_fake_accum_cut_data(this,u,v)
            % build fake data to test accumulate cut

            nPixels = this.nDet*this.nEn;
            ebin=1.99*this.efix/this.nEn;
            en = -this.efix+(0:(this.nEn-1))*ebin;

            L1=20;
            L2=10;
            L3=2;
            E0=min(en);
            E1=max(en);
            Es=2;
            proj = ortho_proj(u,v);
            data = data_sqw_dnd([3,4,5,90,90,90],proj,[0,1,L1],[0,1,L2],[0,0.1,L3],[E0,Es,E1]);
            proj.alatt = data.alatt;
            proj.angdeg = data.angdeg;
            % clear npix as we will cut data to fill it in
            if sum(data.npix(:))>0
                data.s    = zeros(size(data.s));
                data.e    = zeros(size(data.s));
                data.npix = zeros(size(data.s));
            end

            vv=ones(9,nPixels);
            for i=1:3
                p=data.p{i};
                ac=0.5*(p(2:end)+p(1:end-1));
                p_mi=min(ac);
                p_ma=max(ac);
                step=(p_ma-p_mi)/(nPixels-1);
                vv(i,:) =p_mi:step:p_ma;
            end
            vv(4,:)=repmat(en,1,this.nDet);

            data.pix = PixelData(vv);
            [type,data] = data.check_sqw_data('a');
            assertEqual(type,'b+','Invalid test data type generated, type ''b+'' expected')
        end
    end
end

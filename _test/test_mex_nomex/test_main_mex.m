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
            
            root_folder = fileparts(which('horace_init.m'));
            if ispc
                this.accum_cut_folder=fullfile(root_folder,'\@sqw');
            else
                this.accum_cut_folder=fullfile(root_folder,'@sqw');
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
            if ~this.use_mex
                warning('TEST:skipped','test_accum_cut_mex skipped as mex is disabled')
            end
            [data,proj]=gen_fake_accum_cut_data(this,[1,0,0],[0,1,0]);
            pax = [1,2,3,4];
            [urange_step_pix_recent1, ok1, ix1, s1, e1, npix1, npix_retain1,success]= ...
                proj.accumulate_cut(data.pix,data.s,data.e,data.npix,pax,1,0,1,1);
            assertTrue(success)
            [urange_step_pix_recent2, ok2, ix2, s2, e2, npix2, npix_retain2,success]= ...
                proj.accumulate_cut(data.pix,data.s,data.e,data.npix,pax,1,0,1,4);
            assertTrue(success)
            
            assertEqual(npix_retain1,npix_retain2)
            assertElementsAlmostEqual(urange_step_pix_recent1,urange_step_pix_recent2);
            assertEqual(sum(ok1),sum(ok2));
            assertEqual(sort(ix1),sort(ix2));
            assertElementsAlmostEqual(s1,s2);
            assertElementsAlmostEqual(e1,e2);
            assertElementsAlmostEqual(npix1,npix2);
            
        end
        
        
        function this=test_accum_cut(this)
            mex_present=fileparts(which('accumulate_cut_c'));
            assertTrue(~isempty(mex_present),'Mex file accumulate_cut_c is not availible on this computer')
            
            
            [data,proj]=gen_fake_accum_cut_data(this,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);
            urange_step_pix=zeros(2,4);
            urange_step_pix(1,:) =  Inf;
            urange_step_pix(2,:) = -Inf;
            
            %check matlab-part
            set(hor_config,'use_mex',0,'-buffer');
            dummy  = sqw();
            dummy.data = data;
            [s_m, e_m, npix_m, urange_step_pix_m, npix_retain_m,ok_m, ix_m] = accumulate_cut_tester(dummy,urange_step_pix, true,...
                proj, [1,2,3,4]);
            
            
            %check C-part
            set(hor_config,'use_mex',1,'-buffer');
            [s_c, e_c, npix_c, urange_step_pix_c, npix_retain_c,ok_c, ix_c] = accumulate_cut_tester(dummy,urange_step_pix, true,...
                proj, [1,2,3,4]);
            
            % verify results against each other.
            assertElementsAlmostEqual(urange_step_pix_m,urange_step_pix_c);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqual(npix_retain_m,npix_retain_c);
            assertEqual(ok_m,ok_c);
            assertElementsAlmostEqual(ix_m,double(ix_c),'absolute',1.e-12);
        end
        
        function this=test_calc_proj(this)
            mex_present=fileparts(which('calc_projections_c'));
            assertTrue(~isempty(mex_present),'Mex file calc_projections_c is not availible on this computer')
            %
            [efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det]=calc_fake_data(this);
            %
            dummy = sqw();
            set(hor_config,'use_mex',0,'-buffer');
            [u_to_rlu_matl,urange_matl,pix_matl]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            set(hor_config,'use_mex',1,'-buffer');
            [u_to_rlu_c, urange_c,pix_c]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(urange_matl,urange_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_matl,pix_c,'absolute',1.e-8);
            
        end
        
        function test_calc_proj_options(this)
            hcf=hor_config;
            if ~hcf.use_mex
                return;
            end
            cleanup_obj=onCleanup(@()set(hcf,'use_mex',1));
            
            [efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det]=calc_fake_data(this);
            dummy = sqw();
            hcf.saveable=false;
            hcf.use_mex = 0;
            [u_to_rlu_matl,urange_matl]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,0);
            hcf.use_mex = 1;
            [u_to_rlu_c,urange_c]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,0);
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(urange_matl,urange_c,'absolute',1.e-8);
            
            
            hcf.use_mex = 0;
            [u_to_rlu_matl,urange_matl,pix_m]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,1);
            assertEqual(size(pix_m,1),4)
            hcf.use_mex = 1;
            [u_to_rlu_c,urange_c,pix_c]=calc_projections_tester(dummy,efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det,1);
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(urange_matl,urange_c,'absolute',1.e-8);
            assertEqual(size(pix_c,1),4)
            assertElementsAlmostEqual(pix_m,pix_c,'absolute',1.e-8);
        end
        
        function test_sort_pix(this)
            % prepare pixels to sort
            pix=ones(9,40000);
            xs = 9.6:-1:0.6;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix(1,:) = ux(:);
            pix(2,:) = uy(:);
            pix(3,:) = uz(:);
            pix(4,:) = et(:);
            pix(7,:) = 1:size(pix,2);
            npix = 4*ones(10,10,10,10);
            ix = ceil(pix(1,:));
            iy = ceil(pix(2,:));
            iz = ceil(pix(3,:));
            ie = ceil(pix(4,:));
            ix = sub2ind(size(npix), ix,iy,iz,ie);
            
            % test sorting parameters and matlab sorting
            pix1 = sort_pix(pix,ix,[]);
            assertElementsAlmostEqual(pix1(7,1:4),[1810,1820,3810,3820]);
            assertElementsAlmostEqual(pix1(7,5:8),[1809,1819,3809,3819]);
            assertElementsAlmostEqual(pix1(7,end-3:end),[36181,36191,38181,38191]);
            
            pix2 = sort_pix(pix,ix,npix,'-nomex');
            assertElementsAlmostEqual(pix1,pix2);
            
            if ~get(hor_config,'use_mex')
                return
            end
            % test mex
            pix1 = sort_pix(pix,ix,npix,'-force_mex');
            assertElementsAlmostEqual(pix1(7,1:4),[1810,1820,3810,3820]);
            assertElementsAlmostEqual(pix1,pix2);
            
            pix0 = single(pix);
            ix0  = int64(ix);
            pix0a = sort_pix(pix0,ix0,npix,'-force_mex');
            assertElementsAlmostEqual(pix0a,pix2,'absolute',1.e-6);
            
            
        end
        function profile_sort_pix(this)
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
            t=toc(t1)
            pix1 = sort_pix(pix,ix,npix,'-force_mex','-keep_type');
            t=toc(t1)            
            pix1 = sort_pix(pix0,ix0,npix,'-nomex','-keep_type');
            t=toc(t1)            
            
            profile off
            profview;
            
        end
        
        function  [efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det]=calc_fake_data(this)
            efix = this.efix;
            emode=1;
            alatt=[1,1,1];
            angdeg=[92,88,73];
            u=[1,0,0];
            v=[1,1,0];
            psi = 20;
            omega = 0;
            dpsi = 0;
            gl=0;
            gs =0;
            
            polar=(0:(this.nPolar-1))*(pi/(this.nPolar-1));
            azim=(0:(this.nAzim-1))*(2*pi/(this.nAzim-1));
            det.phi = reshape(repmat(azim,this.nPolar,1),1,this.nDet);
            det.azim =reshape(repmat(polar,this.nAzim,1)',1,this.nDet);
            data.S   = rand(this.nEn,this.nDet);
            data.ERR = sqrt(data.S);
            data.en =(-efix+(0:(this.nEn))*(1.99999*efix/(this.nEn)))';
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
            prj = projaxes(u,v);
            data = data_sqw_dnd([3,4,5,90,90,90],prj,[0,1,L1],[0,1,L2],[0,0.1,L3],[E0,Es,E1]);
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
            
            
            minv  =min(vv,[],2);
            maxv  =max(vv,[],2);
            minv=minv(1:4);
            maxv=maxv(1:4);
            %
            data.pix = vv;
            [ok,type,mess] = data.check_sqw_data('a');
            assertTrue(ok,['Invalid test data generated: ',mess]);
            assertEqual(type,'b+','Invalid test data type generated, type ''b+'' expected')
            
            % set to cut half of the dataset in all 4 dimensions (1/16 of
            % total dataset)
            urange(1,:) =  0.5*(minv+maxv);
            % move range in e-direction a bit to avoid accum_cut binning
            % coinside with initial binning and result depending on
            % round-off errors -- then it give different results in case of
            % used on different machines and c vs matlab
            urange(1,4) =  1.01*urange(1,4);
            urange(2,:) =  (maxv-minv);
            
            % Prepare cut projection to cut half of the data
            proj = projection(prj);
            upix_to_rlu=eye(3);
            upix_offset = zeros(4,1);
            
            proj=proj.retrieve_existing_tranf(data,upix_to_rlu,upix_offset);
            % Important!!!!! to have the same number of bins as target data.s.
            % The question is how to assure that.
            step = (maxv-minv)./size(data.s)';
            proj=proj.set_proj_binning(urange,[1,2,3,4],[],...
                {minv(1):step(1):maxv(1),minv(2):step(2):maxv(2),minv(3):step(3):maxv(3),minv(4):step(4):maxv(4)});
            
            
        end
    end
end
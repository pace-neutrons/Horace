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
            % addpath(this.this_folder);
        end
        function this=setUp(this)
            %addpath(this.accum_cut_folder);
            %cd(this.accum_cut_folder);
            this.use_mex = get(hor_config,'use_mex');
            
        end
        function tearDown(this)
            %cd(this.curr_folder);
            %rmpath(this.accum_cut_folder);
            set(hor_config,'use_mex',this.use_mex);
        end
        
        function this=test_accum_cut(this)
            mex_present=fileparts(which('accumulate_cut_c'));
            assertTrue(~isempty(mex_present),'Mex file accumulate_cut_c is not availible on this computer')
            
            
            [v,sizes,proj,urange_step_pix]=gen_fake_accum_cut_data(this,[1,-1,0],[1,1,1]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);
            s=zeros(sizes);
            e=zeros(sizes);
            npix=zeros(sizes);
            %check matlab-part
            set(hor_config,'use_mex',0,'-buffer');
            dummy  = sqw();
            [s_m, e_m, npix_m, urange_step_pix_m, npix_retain_m,ok_m, ix_m] = accumulate_cut_tester(dummy,s, e, npix, urange_step_pix, true,...
                v, proj, [1,2,3,4]);
            
            
            %check C-part
            set(hor_config,'use_mex',1,'-buffer');
            s=zeros(sizes);
            e=zeros(sizes);
            npix=zeros(sizes);
            [s_c, e_c, npix_c, urange_step_pix_c, npix_retain_c,ok_c, ix_c] = accumulate_cut_tester(dummy,s, e, npix, urange_step_pix, true,...
                v, proj, [1,2,3,4]);
            
            % verify results against each other.
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertElementsAlmostEqual(urange_step_pix_m,urange_step_pix_c);
            assertEqual(npix_retain_m,npix_retain_c);
            assertEqual(ok_m,ok_c);
            assertElementsAlmostEqual(ix_m,ix_c,'absolute',1.e-12);
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
        function [vv,box_sizes,proj,urange_step_pix]=gen_fake_accum_cut_data(this,u,v)
            
            %%rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step
            %rx = @(x)[1,0,0;0,cos(x),-sin(x);0,sin(x),cos(x)];
            %ry = @(x)[cos(x),0,sin(x);0,1,0;-sin(x),0,cos(x)];
            
            %rot_ustep = rx(theta)*ry(phi);
            data.alatt = [3,4,5];
            data.angdeg = [90,90,95];
            data.u_to_rlu = eye(4);
            data.uoffset = [0;0;0;0];      %(4x1)
            data.upix_to_rlu = eye(3);
            data.upix_offset = [0;0;0;0];
            
            data.ulabel = {'xx','yy','zz','ee'};
            
            ebin=1.99*this.efix/this.nEn;
            en = -this.efix+(0:(this.nEn-1))*ebin;

            box_sizes=[50,50,50,50];            
            data.ulen  = [1/50,1/50,1/50,ebin];
            
            
            prs = struct('u',u,'v',v);
            proj = projection(prs);
            proj=proj.retrieve_existing_tranf(data);
            
            
            rs= [0.11930-1;1.338890;0.02789];
            
            nPixels = this.nDet*this.nEn;
            vv=ones(9,nPixels);
            %rot_inv=inv(rot_ustep);
            
            vv(1,:) =(0:(nPixels-1))*20/(nPixels);
            vv(2,:) =(0:(nPixels-1))*10/(nPixels);
            vv(3,:) =(0:(nPixels-1))*2/(nPixels);
            
            
            % shift data to test shift
            vv(1:3,:)=vv(1:3,:)+repmat(rs',[size(vv,2),1])';
            vv(4,:)=repmat(en,1,this.nDet);
            
            
            
            urange_step_pix = zeros(2,4);
            urange_step     = zeros(2,4);
            urange_step_pix(1,:) =  Inf;
            urange_step_pix(2,:) = -Inf;
            minv  =min(vv,[],2);
            maxv  =max(vv,[],2);
            minv=minv(1:4);
            maxv=maxv(1:4);

            % set to cut half of the dataset
            urange_step(1,:) =  (0.5*(minv+0.5*(minv+maxv))-minv)./data.ulen';
            urange_step(2,:) =  (0.5*(maxv+0.5*(minv+maxv))-minv)./data.ulen';
            
            proj=proj.set_proj_ranges(data.ulen,urange_step,zeros(1,4));
            
            
        end
    end
end
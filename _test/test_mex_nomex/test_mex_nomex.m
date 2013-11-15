classdef test_mex_nomex < TestCase
    % Series of tests to check work of mex files agains matlab files
    
    properties
        accum_cut_folder;
        curr_folder;
        nPolar=99;
        nAzim =101;
        nDet;
        nEn  = 102;
        efix=100;
        use_mex;
    end
    
    methods
        function this=test_mex_nomex (varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_mex_nomex';
            end
            this = this@TestCase(name);
            
            root_folder = fileparts(which('horace_init.m'));
            this.accum_cut_folder=fullfile(root_folder,'\@sqw/private');
            this.curr_folder = pwd();
            this.nDet=this.nPolar*this.nAzim;
        end
        function setUp(this)
            cd(this.accum_cut_folder);
            this.use_mex = get(hor_config,'use_mex');
        end
        function tearDown(this)
            cd(this.curr_folder);
            set(hor_config,'use_mex',this.use_mex);
        end
        
        function this=test_accum_cut(this)
            mex_present=fileparts(which('accumulate_cut_c'));
            assertTrue(~isempty(mex_present),'Mex file accumulate_cut_c is not availible on this computer')
            
                        
            [v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,10*(pi/180),45*(pi/180));
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);            
            s=zeros(sizes);
            e=zeros(sizes);
            npix=zeros(sizes);
            %check matlab-part                        
            set(hor_config,'use_mex',0,'-buffer');

            [s_m, e_m, npix_m, urange_step_pix_m, npix_retain_m,ok_m, ix_m] = accumulate_cut (s, e, npix, urange_step_pix, true,...
                                    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, [1,2,3,4]);

            
            %check C-part
            set(hor_config,'use_mex',1,'-buffer');
            s=zeros(sizes);
            e=zeros(sizes);
            npix=zeros(sizes);           
            [s_c, e_c, npix_c, urange_step_pix_c, npix_retain_c,ok_c, ix_c] = accumulate_cut (s, e, npix, urange_step_pix, true,...
                                    v, urange_step, rot_ustep, trans_bott_left, ebin, trans_elo, [1,2,3,4]);

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

            set(hor_config,'use_mex',0,'-buffer');
            [u_to_rlu_matl, ucoords_matl]=calc_projections (efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            set(hor_config,'use_mex',1,'-buffer');
            [u_to_rlu_c, ucoords_c]=calc_projections (efx, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(ucoords_matl,ucoords_c,'absolute',1.e-8);            
            
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
            data.S   = ones(this.nEn,this.nDet);
            data.ERR = ones(this.nEn,this.nDet);
            data.en =(-efix+(0:(this.nEn))*(1.99999*efix/(this.nEn)))';
        end
        function [vv,box_sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,theta,phi)
            
            rx = @(x)[1,0,0;0,cos(x),-sin(x);0,sin(x),cos(x)];
            ry = @(x)[cos(x),0,sin(x);0,1,0;-sin(x),0,cos(x)];            
            
            rot_ustep = rx(theta)*ry(phi);
            
            box_sizes=[50,50,50,50];

            urange_step_pix = zeros(2,4);
            urange_step     = zeros(2,4);            
            urange_step_pix(1,:) =  Inf;
            urange_step_pix(2,:) = -Inf;            
           
            rs= [0.11930-1;1.338890;0.02789];

            nPixels = this.nDet*this.nEn;
            vv=ones(9,nPixels);
            %rot_inv=inv(rot_ustep);
            ebin=1.99*this.efix/this.nEn;
            en = -this.efix+(0:(this.nEn-1))*ebin;
                                   
            vv(1,:) =(0:(nPixels-1))*20/(nPixels);
            vv(2,:) =(0:(nPixels-1))*10/(nPixels);            
            vv(3,:) =(0:(nPixels-1))*2/(nPixels);


            % shift data to test shift
            vv(1:3,:)=vv(1:3,:)+repmat(rs',[size(vv,2),1])';           
            vv(4,:)=repmat(en,1,this.nDet);

            minv  =min(vv,[],2);
            maxv  =max(vv,[],2);            
            minv=minv(1:4);
            maxv=maxv(1:4);        

         % this should cut off half of the Q-dE volume
            urange_step(1,:) =  0.5*(minv+0.5*(minv+maxv))-minv;
            urange_step(2,:) =  0.5*(maxv+0.5*(minv+maxv))-minv; 
            trans_elo = urange_step(1,4);
            trans_bott_left=urange_step(1,1:3)';
            

            vt = (vv(1:3,:)'-repmat(trans_bott_left',[size(vv,2),1]))*rot_ustep';
            minv  =min(vt,[],1);
            maxv  =max(vt,[],1);      
            urange_step(1,1:3)=minv;
            urange_step(2,1:3)=maxv;            
                
            delta=(urange_step(2,:)-urange_step(1,:))./box_sizes;
            delta=[1,1,1,1]./delta;
            urange_step = urange_step.*repmat(delta,2,1);

            urange_step(2,:)=urange_step(2,:)-urange_step(1,:);
            urange_step(1,:)=urange_step(1,:)-urange_step(1,:);                        
            
            rot_ustep = (rot_ustep'.*repmat(delta(1:3)',1,3));
        end
    end
end
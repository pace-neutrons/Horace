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
            
            root_folder = horace_root();
            if ispc
                this.accum_cut_folder=fullfile(root_folder,'horace_core','\@sqw');
            else
                this.accum_cut_folder=fullfile(root_folder,'horace_core','@sqw');
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
            [~,n_errors] = check_horace_mex();
            if n_errors>0
                skipTest('Can not use and test mex code to accumulate_cut');
            end
            
            
            
            [data,proj]=gen_fake_accum_cut_data(this,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);
            urange_step_pix=zeros(2,4);
            urange_step_pix(1,:) =  Inf;
            urange_step_pix(2,:) = -Inf;
            
            hc = hor_config;
            current_state = hc.use_mex;
            clob = onCleanup(@()set(hc,'use_mex',current_state));            
            hc.saveable = false;
            
            %check matlab-part
            hc.use_mex = false;
            
            [s_m, e_m, npix_m, urange_step_pix_m, npix_retain_m,ok_m, ix_m] =...
                cut_data_from_file_job.accumulate_cut(data.s, data.e, data.npix,...
                urange_step_pix, true,...
                data.pix,proj, [1,2,3,4]);
            
            
            %check C-part
            hc.use_mex = true;
            
            [s_c, e_c, npix_c, urange_step_pix_c, npix_retain_c,ok_c, ix_c] = ...
                cut_data_from_file_job.accumulate_cut(data.s, data.e, data.npix,...
                urange_step_pix, true,...
                data.pix,proj, [1,2,3,4]);
            
            % verify results against each other.
            assertElementsAlmostEqual(urange_step_pix_m,urange_step_pix_c,'relative',1.e-7);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqual(npix_retain_m,npix_retain_c);
            assertEqual(ok_m,ok_c);
            assertElementsAlmostEqual(ix_m,double(ix_c),'absolute',1.e-12);
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
            
            [pix_range_matl,u_to_rlu_matl,pix_matl]=rd.calc_projections();
            
            hc.use_mex = true;
            [pix_range_c,u_to_rlu_c,pix_c]=rd.calc_projections();
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
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
            [pix_range_matl,u_to_rlu_matl]=rd.calc_projections();
            hcf.use_mex = 1;
            [pix_range_c,u_to_rlu_c]=rd.calc_projections();
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            
            
            hcf.use_mex = 0;
            [pix_range_matl,u_to_rlu_matl,pix_m]=rd.calc_projections();
            
            assertEqual(size(pix_m.data, 1), 9);
            hcf.use_mex = 1;
            [pix_range_c,u_to_rlu_c,pix_c]=rd.calc_projections();
            
            assertElementsAlmostEqual(u_to_rlu_matl,u_to_rlu_c,'absolute',1.e-8);
            assertElementsAlmostEqual(pix_range_matl,pix_range_c,'absolute',1.e-8);
            assertEqual(size(pix_c.data, 1), 9);
            assertElementsAlmostEqual(pix_m.data,pix_c.data,'absolute',1.e-8);
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
            t=toc(t1)
            pix1 = sort_pix(pix,ix,npix,'-force_mex','-keep_type');
            t=toc(t1)
            pix1 = sort_pix(pix0,ix0,npix,'-nomex','-keep_type');
            t=toc(t1)
            
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
            data.pix = PixelData(vv);
            [ok,type,mess] = data.check_sqw_data('a');
            assertTrue(ok,['Invalid test data generated: ',mess]);
            assertEqual(type,'b+','Invalid test data type generated, type ''b+'' expected')
            
            % set to cut half of the dataset in all 4 dimensions (1/16 of
            % total dataset)
            pix_range(1,:) =  0.5*(minv+maxv);
            % move range in e-direction a bit to avoid accum_cut binning
            % coinside with initial binning and result depending on
            % round-off errors -- then it give different results in case of
            % used on different machines and c vs matlab
            pix_range(1,4) =  1.01*pix_range(1,4);
            pix_range(2,:) =  (maxv-minv);
            
            % Prepare cut projection to cut half of the data
            proj = projection(prj);
            upix_to_rlu=eye(3);
            upix_offset = zeros(4,1);
            
            proj=proj.retrieve_existing_tranf(data,upix_to_rlu,upix_offset);
            % Important!!!!! to have the same number of bins as target data.s.
            % The question is how to assure that.
            step = (maxv-minv)./size(data.s)';
            proj=proj.set_proj_binning(pix_range,[1,2,3,4],[],...
                {minv(1):step(1):maxv(1),minv(2):step(2):maxv(2),minv(3):step(3):maxv(3),minv(4):step(4):maxv(4)});
            
            
        end
    end
end
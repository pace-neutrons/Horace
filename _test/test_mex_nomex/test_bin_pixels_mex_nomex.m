classdef test_bin_pixels_mex_nomex < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        this_folder;
        no_mex;
    end

    methods
        function obj=test_bin_pixels_mex_nomex(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_bin_pixels_mex_nomex';
            end
            obj = obj@TestCase(name);

            obj.this_folder = fileparts(which('test_bin_pixels_mex_nomex.m'));

            [~,n_errors] = check_horace_mex();
            obj.no_mex = n_errors > 0;
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

        function obj=test_bin_pixels_mex_multithread(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to bin pixels in parallel');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);

            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);
            clObPar = set_temporary_config_options(parallel_config, 'threads', 1);

             [data.proj,npix_1,s_1,e_1,pix_ok_1,unique_runid_1] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            clear clObPar;
            clObPar = set_temporary_config_options(parallel_config, 'threads', 8);            
            [data.proj,npix_8,s_8,e_8,pix_ok_8,unique_runid_8] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            assertEqual(npix_1,npix_8)
            assertEqual(s_1,s_8)
            assertEqual(e_1,e_8)
            assertEqual(pix_ok_1,pix_ok_8)
            assertEqual(unique_runid_1,unique_runid_8)
            skipTest('Only pixel sorting is currently mexed')
        end

        function obj=test_bin_pixels_on_line_proj_mex_nomex(obj)
            if obj.no_mex
                skipTest('Can not use and test mex code to bin pixels on line proj');
            end

            [data,pix]=gen_fake_accum_cut_data(obj,[1,0,0],[0,1,0]);
            %[v,sizes,rot_ustep,trans_bott_left,ebin,trans_elo,urange_step_pix,urange_step]=gen_fake_accum_cut_data(this,0,0);

            hc = hor_config;
            hc.saveable = false;

            %check matlab-part
            hc.use_mex = false;
            [data.proj,npix_m,s_m,e_m,pix_ok_m,unique_runid_m] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);

            %check C-part
            hc.use_mex = true;
            [data.proj,npix_c,s_c,e_c,pix_ok_c,unique_runid_c] = ...
                data.proj.bin_pixels(data.axes,pix,[],[],[]);


            % verify results against each other.
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertElementsAlmostEqual(s_m,s_c);
            assertElementsAlmostEqual(e_m,e_c);
            assertElementsAlmostEqual(npix_m,npix_c,'absolute',1.e-12);
            assertEqualToTol(pix_ok_m,pix_ok_c);
            assertElementsAlmostEqual(unique_runid_m,unique_runid_c);
        end

        function test_bin_pixels_AB_inputs(~)
            if obj.no_mex
                skipTest('Can not test mex code to checko binning parameters');
            end
            clObHor = set_temporary_config_options(hor_config, 'use_mex', true);

            AB = AxesBlockBase_tester('nbins_all_dims',[10,20,30,40], ...
                'img_range',[-1,-2,-3,-10;1,2,3,40]);
            [AB,npix,s,e,out_flds,out_par] = AB.bin_pixels(rand(4,10),'-test_mex_inputs');
            

        end


    end
    methods(Access=protected)
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
            proj = line_proj(u,v,'alatt',[3,4,5],'angdeg',[90,90,90]);
            ab = line_axes([0,1,L1],[0,1,L2],[0,0.1,L3],[E0,Es,E1]);
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

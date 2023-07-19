classdef test_proj_alignment<TestCase
    % testing ortho_proj class constructor
    %
    properties
        h0 = 2;  % the position and the extend of the
        k0 = 2;  % pseudo peak
        sigmaSq = 10;
    end

    methods
        function this=test_proj_alignment(varargin)
            if nargin == 0
                name = 'test_proj_alignment';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        function test_align_simple_lat_change_alatt(obj)
            %
            ax = ortho_axes('img_range',[-5,-5,-2,-2;5,5,2,2],'nbins_all_dims',[100,100,1,1]);
            w2 = sqw.generate_cube_sqw(ax,@(h,k,l,e,p)sample_gaus(obj,h,k,l,e,1));

            % this alignment moves the peak into actual [1,0,0] position where
            % lattice parameters is previous lattice parameter divided by
            % sqrt(2)
            al_inf = crystal_alignment_info();
            al_inf.rotvec  = [0,0,pi/4];
            al_inf.alatt   = w2.data.alatt/sqrt(2);            
            w2 = w2.change_crystal(al_inf);
            % now we do normal cut and should find the peak in the
            % [1,0,0] position
            targ_proj = ortho_proj([1,0,0],[0,1,0], ...
                'alatt',w2.data.alatt,'angdeg',w2.data.angdeg);
            targ_ab   = targ_proj.get_proj_axes_block(cell(4,1), ...
                {[-5,0.1,5],[-5,0.1,5],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start,1);
            assertEqual(bl_size,sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-5,0.1,5],[-5,0.1,5],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,w2.npixels)
            % Check data correctntess numerically
            w1_l = cut_sqw(w2,targ_proj,[-5,0.1,5], ...
                [-0.5,0.5],[-2,2],[-2,2]);
            kk1 = multifit (w1_l);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_l, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,2,sqrt(obj.sigmaSq)/2],'relative',2.e-2)

            w1_t = cut_sqw(w2,targ_proj,[2-0.5,2+0.5], ...
                [-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]);
            kk1 = multifit (w1_t);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_t, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,0,sqrt(obj.sigmaSq)/2],'absolute',2.e-2)

        end

        function test_align_simple_lattice_latt_no_change_with_offset(obj)
            ax = ortho_axes('img_range',[-6,-6,-2,-2;4,4,2,2],'nbins_all_dims',[100,100,1,1]);
            proj = ortho_proj([1,0,0],[0,1,0],'offset',[1.0,1.0,0,0], ...
                'alatt',2*pi,'angdeg',90);
            w2 = sqw.generate_cube_sqw(ax,proj,@(h,k,l,e,p)sample_gaus(obj,h,k,l,e,1));
            assertEqual(w2.pix.pix_range, [...
                -4.9500  -4.9500     0         0;
                4.9500    4.9500     0         0])

            %
            al_inf = crystal_alignment_info();
            al_inf.rotvec  = [0,0,pi/4];
            w2 = w2.change_crystal(al_inf);
            %
            targ_proj = ortho_proj([1,0,0],[0,1,0], ...
                'alatt',w2.data.alatt,'angdeg',w2.data.angdeg);
            targ_ab   = targ_proj.get_proj_axes_block(cell(4,1), ...
                {[-5*sqrt(2),0.1,5*sqrt(2)],[-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start(1),1);
            assertEqual(sum(bl_size),sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-5*sqrt(2),0.1,5*sqrt(2)], ...
                [-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,w2.npixels)
            %
            % Check data correctntess numerically
            w1_l = cut_sqw(w2,targ_proj,[-5*sqrt(2),0.1,5*sqrt(2)], ...
                [-0.5,0.5],[-2,2],[-2,2]);            
            kk1 = multifit (w1_l);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_l, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,2*sqrt(2),sqrt(obj.sigmaSq/2)],'relative',1.e-2)

            w1_t = cut_sqw(w2,targ_proj,[2*sqrt(2)-0.5,2*sqrt(2)+0.5], ...
                [-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]);
            kk1 = multifit (w1_t);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_t, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,0,sqrt(obj.sigmaSq/2)],'absolute',1.e-2)
            
        end


        function test_align_simple_lattice_latt_no_change(obj)
            %
            ax = ortho_axes('img_range',[-5,-5,-2,-2;5,5,2,2],'nbins_all_dims',[100,100,1,1]);
            w2 = sqw.generate_cube_sqw(ax,@(h,k,l,e,p)sample_gaus(obj,h,k,l,e,1));

            % this alignment moves the peak into actual [1,0,0] position where
            % lattice parameters is previous lattice parameter divided by
            % sqrt(2)
            al_inf = crystal_alignment_info();
            al_inf.rotvec  = [0,0,pi/4];
            w2 = w2.change_crystal(al_inf);
            % now we do normal cut and should find the peak in the
            % [1,0,0] position
            targ_proj = ortho_proj([1,0,0],[0,1,0], ...
                'alatt',w2.data.alatt,'angdeg',w2.data.angdeg);
            targ_ab   = targ_proj.get_proj_axes_block(cell(4,1), ...
                {[-5*sqrt(2),0.1,5*sqrt(2)],[-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start,1);
            assertEqual(bl_size,sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-5*sqrt(2),0.1,5*sqrt(2)], ...
                [-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,w2.npixels)
            % Check data correctntess numerically
            w1_l = cut_sqw(w2,targ_proj,[-5*sqrt(2),0.1,5*sqrt(2)], ...
                [-0.5,0.5],[-2,2],[-2,2]);
            kk1 = multifit (w1_l);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_l, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,2*sqrt(2),sqrt(obj.sigmaSq/2)],'relative',1.e-2)

            w1_t = cut_sqw(w2,targ_proj,[2*sqrt(2)-0.5,2*sqrt(2)+0.5], ...
                [-5*sqrt(2),0.1,5*sqrt(2)],[-2,2],[-2,2]);
            kk1 = multifit (w1_t);
            kk1 = kk1.set_fun(@gauss);
            kk1 = kk1.set_pin ([1,2,10]);
            [fitted_t, fit_params] = kk1.fit;
            fit_params.p(3) = abs(fit_params.p(3));
            assertElementsAlmostEqual(fit_params.p, ...
                [1,0,sqrt(obj.sigmaSq/2)],'absolute',1.e-2)

        end

        function f=sample_gaus(obj,h,k,l,en,varargin)
            % bragg peak in notional 110 position.
            f = exp(-((h-obj.h0).^2/obj.sigmaSq+(k-obj.k0).^2/obj.sigmaSq+l.^2+en.^2));
        end
    end
end

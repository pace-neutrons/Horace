classdef test_proj_alignment<TestCase
    % testing ortho_proj class constructor
    %
    properties
        h0 = 2;  % the position and the extend of the
        k0 = 2;  % pseudo peak
        sigma = 10;
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
            w0 = sqw.generate_cube_sqw(10,@(h,k,l,e,p)sample_gaus(obj,h,k,l,e,1));

            w2 = cut_sqw(w0,ortho_proj,[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]);
            % this alignment moves the peak into actual [1,0,0] position where
            % lattice parameters is previous lattice parameter divided by
            % sqrt(2)
            al_inf = crystal_alignment_info('alatt',[2,2,2],'rotvec',[0,0,pi/4]);
            w2 = w2.change_crystal(al_inf);
            % now we do normal cut and should find the peak in the
            % [1,0,0] position
            targ_proj = ortho_proj([1,0,0],[0,1,0], ...
                'alatt',w2.data.alatt,'angdeg',w2.data.angdeg);
            targ_ab   = targ_proj.get_proj_axes_block(cell(4,1), ...
                {[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start,1);
            assertEqual(bl_size,sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,1408)
        end

        function test_align_simple_lattice_latt_no_change_with_offset(obj)
            w0 = sqw.generate_cube_sqw(10,@(h,k,l,e,p)sample_gaus(obj,h,k,l,e,1));

            proj0 = ortho_proj([1,0,0],[0,1,0],'offset',[1.0,1.0,0,0]);
            w2 = cut_sqw(w0,proj0,[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]);
            %
            al_inf = crystal_alignment_info();
            al_inf.rotvec  = [0,0,pi/4];
            w2 = w2.change_crystal(al_inf);
            %
            targ_proj = ortho_proj([1,0,0],[0,1,0], ...
                'alatt',w2.data.alatt,'angdeg',w2.data.angdeg);
            targ_ab   = targ_proj.get_proj_axes_block(cell(4,1), ...
                {[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start(1),1);
            assertEqual(sum(bl_size),sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,1216)
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
                {[-4.5,1,4.5],[-4.5,1,4.5],[-2,2],[-2,2]});
            [bl_start,bl_size] = w2.data.proj.get_nrange(w2.data.npix,w2.data.axes,...
                targ_ab,targ_proj);
            assertEqual(bl_start,1);
            assertEqual(bl_size,sum(w2.data.npix(:)));

            w2m = cut_sqw(w2,targ_proj,[-4.5,0.1,4.5],[-4.5,0.1,4.5],[-2,2],[-2,2]);
            assertEqual(w2m.npixels,1408)
        end

        function f=sample_gaus(obj,h,k,l,en,varargin)
            % bragg peak in notional 110 position.
            f = exp(-((h-obj.h0).^2/obj.sigma+(k-obj.k0).^2/obj.sigma+l.^2+en.^2));
        end
    end
end

classdef test_apply_and_recompute_bin_data < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
    end

    methods
        function obj=test_apply_and_recompute_bin_data(varargin)
            if nargin>0
                name=varargin{1};
            else
                name = 'test_apply_and_recompute_bin_data';
            end
            obj = obj@TestCase(name);

        end

        function test_recompute_bin_data_in_memory(~)
            % use generate_cube_sqw
            test_sqw = sqw();
            pix=PixelDataBase.create(ones(9,40000));
            xs = 0.1:1:10;
            xp = 0.1:0.5:10;
            [ux,uy,uz,et]=ndgrid(xs,xp,xs,xp);
            pix.coordinates = [ux(:)';uy(:)';uz(:)';et(:)'];
            npix = 4*ones(10,10,10,10);
            ab = line_axes('nbins_all_dims',[10,10,10,10],'img_range',[0,0,0,0;2,2,2,2]);
            test_sqw.data = DnDBase.dnd(ab,line_proj('alatt',3,'angdeg',90));
            test_sqw.data.npix = npix;
            test_sqw.pix  = pix;

            new_sqw = recompute_bin_data(test_sqw);
            s = new_sqw.data.s;
            e = new_sqw.data.e;
            assertElementsAlmostEqual(4*s,npix);
            assertElementsAlmostEqual((4*4)*e,npix);

        end

    end
end

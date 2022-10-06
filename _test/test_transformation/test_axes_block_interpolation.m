classdef test_axes_block_interpolation < TestCase
    % Series of tests for bins_in_1Drange method of axes_block class

    properties
        out_dir=tmp_dir();
        working_dir
    end

    methods
        function obj=test_axes_block_interpolation(varargin)
            if nargin<1
                name = 'test_axes_block_binIn1D';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.working_dir = fileparts(mfilename("fullpath"));
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_interp_2D_same_points_interpolation(~)
            dbr = [0,-2,-pi/2,0;pi,2,pi/2,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.1,dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            %dbr(:,4) = [0;5];
            bin1 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.1,dbr(2,3)];[dbr(1,4),dbr(2,4)]};

            ab_interp = axes_block(bin1{:});
            source_cube = ab_base.get_axes_scales();

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            sdat= sin(0.5*(ax(1:end-1)+ax(2:end)));
            cdat =cos(0.5*(ay(1:end-1)+ay(2:end)));
            data = sdat'.*cdat;            
            step = (ax(2:end)-ax(1:end-1)).*(ay(2:end)-ay(1:end-1));

            [int_points,int_data] = ab_base.get_density(data.*step);


            [npix,si] = ab_interp.bin_pixels(int_points,[],[],[],int_data);
            vol = ab_interp.get_bin_volume();

            assertElementsAlmostEqual(int_data{1},data)
        end

        function test_interp_1D_same_points_interpolation(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            step = ax(2:end)-ax(1:end-1);
            data = sin(cp);
            [int_points,int_data] = ab_base.get_density(data.*step);

            dbr(:,4) = [0;5];
            bin1 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};

            ab_interp = axes_block(bin1{:});

            
            [npix,si] = ab_interp.bin_pixels(int_points,[],[],[],int_data);
            vol = ab_interp.get_bin_volume();

            si = si*vol;

            %assertEqual(sum(npix(:)),size(int_points,2))

            assertElementsAlmostEqual(0.5*si,data)
        end


    end
end

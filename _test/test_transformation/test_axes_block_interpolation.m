classdef test_axes_block_interpolation < TestCase
    % Series of tests for data interpolation/extrapolation in the axes_block class
    properties
    end

    methods
        function obj=test_axes_block_interpolation(varargin)
            if nargin<1
                name = 'test_axes_block_interpolation';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_interp_2D_proj_rotated(~)
            dbr = [-2,-2,-3,0;2,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            ax = 0.5*(ax(1:end-1)+ax(2:end));
            ay = 0.5*(ay(1:end-1)+ay(2:end));
            r  = sqrt(ax.^2 + ay'.^2);

            data = exp(-(r-0.5).^2/0.1);

            [int_points,int_data,cell_size] = ab_base.get_density(data);


            ab_interp = axes_block(bin0{:});
            % define source and target coordinate systems
            source_proj = ortho_proj([1,0,0],[0,1,0]);
            targ_proj = ortho_proj([1/sqrt(2),1/sqrt(2),0],[1/sqrt(2),-1/sqrt(2),0]);
            targ_proj.targ_proj = source_proj;
            si = ab_interp.interpolate_data(int_points,int_data,cell_size,targ_proj );

            assertElementsAlmostEqual(si,data,'absolute',0.06)
            % These are the tests for different definition of boundary
            % points
            %cs = size(si);
            %assertElementsAlmostEqual(si(1:cs(1)-1,1:cs(2)-1), ...
            %    data(1:cs(1)-1,1:cs(2)-1),'absolute',0.06)
        end
        function test_interp_2D_same_points_projected(~)
            dbr = [0,-2,-pi/2,0;pi,2,pi/2,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            sdat= 1+sin(0.5*(ax(1:end-1)+ax(2:end)));
            cdat =1+cos(0.5*(ay(1:end-1)+ay(2:end)));
            data = sdat'.*cdat;

            [int_points,int_data,cell_size] = ab_base.get_density(data);


            ab_interp = axes_block(bin0{:});
            % define source and target coordinate systems
            source_proj = ortho_proj([1,0,0],[0,1,0]);
            targ_proj = ortho_proj([1,0,0],[0,1,0]);
            targ_proj.targ_proj = source_proj;
            si = ab_interp.interpolate_data(int_points,int_data,cell_size,targ_proj );

            cs = size(si);
            assertElementsAlmostEqual(si(2:cs(1)-1,2:cs(2)-1), ...
                data(2:cs(1)-1,2:cs(2)-1),'absolute',1e-2)
            % These are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si,data,'absolute',1e-2)
        end


        function test_interp_2D_same_points_interpolation(~)
            dbr = [0,-2,-pi/2,0;pi,2,pi/2,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.1,dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            sdat= 1+sin(0.5*(ax(1:end-1)+ax(2:end)));
            cdat =1+cos(0.5*(ay(1:end-1)+ay(2:end)));
            data = sdat'.*cdat;

            [int_points,int_data] = ab_base.get_density(data);


            ab_interp = axes_block(bin0{:});
            si = ab_interp.interpolate_data(int_points,int_data);

            assertElementsAlmostEqual(si,data,'absolute',1e-2)
            % These are the tests for different definition of boundary
            % points
            %cs = size(si);
            %assertElementsAlmostEqual(si(1:cs(1)-1,1:cs(2)-1), ...
                %    data(1:cs(1)-1,1:cs(2)-1),'absolute',1e-2)
        end
        function test_interp_1D_frac_points_int_coeff(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = ones(size(cp));
            [int_points,int_data,cell_sizes] = ab_base.get_density(data);

            % define bins to give exactly the same range as for ab_base
            nb = ab_base.nbins_all_dims;
            nb(2) = floor(nb(2)*0.7);
            ab_interp = axes_block('img_range',ab_base.img_range,'nbins_all_dims',nb);
            assertElementsAlmostEqual(ab_base.img_range,ab_interp.img_range);


            si = ab_interp.interpolate_data(int_points,int_data,cell_sizes);
            % integrated signal increase proportinal to the
            % integration cell increase
            [~,icell_sizes] = ab_interp.get_axes_scales();
            mult = icell_sizes(2)/cell_sizes(2)/2;

            assertEqualToTol(sum(si),sum(data),1.e-8);

            assertElementsAlmostEqual(si,mult*data(1:numel(si))');
            % These are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(2:end-1),mult*data(2:numel(si)-1)');
        end
        function test_interp_1D_peak_averaging(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            ab_base = axes_block('img_range',dbr,'nbins_all_dims',[8,1,1,1]);

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = zeros(size(cp));
            n_center = floor(size(data,2)/2);
            data(n_center) = 10;
            [int_points,int_data,cell_sizes] = ab_base.get_density(data);


            ab_interp = axes_block('img_range',dbr,'nbins_all_dims',[8,1,1,1]);

            si = ab_interp.interpolate_data(int_points,int_data,cell_sizes);

            assertEqualToTol(sum(si),sum(data),1.e-12);
            sample= [0,0,1.25,7.5,1.25,0,0,0];
            assertElementsAlmostEqual(si,sample')
        end
        %
        function test_interp_1D_half_points_int_coeff(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            ab_base = axes_block('img_range',dbr,'nbins_all_dims',[1,1,60,1]);

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = ones(size(cp));
            [int_points,int_data,cell_sizes] = ab_base.get_density(data);


            ab_interp = axes_block('img_range',dbr,'nbins_all_dims',[1,1,30,1]);

            si = ab_interp.interpolate_data(int_points,int_data,cell_sizes);

            assertEqualToTol(sum(si),sum(data),1.e-12);
            assertElementsAlmostEqual(si,2*data(1:numel(si))')
            % These are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(2:end-1),2*data(2:numel(si)-1)')
        end
        %
        function test_interp_1D_same_points_interpolation(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = axes_block(bin0{:});

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));

            % add 1 as algorithm does not allow negative values even
            % anywhere in between interpolation/integration
            data = 1+sin(cp);
            [int_points,int_data] = ab_base.get_density(data);

            %dbr(:,4) = [0;5];
            bin1 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};

            ab_interp = axes_block(bin1{:});
            si = ab_interp.interpolate_data(int_points,int_data);


            assertElementsAlmostEqual(si,data')
            % These are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(1:end-1),data(1:end-1)')
        end
    end
end

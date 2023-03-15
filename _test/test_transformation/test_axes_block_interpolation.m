classdef test_axes_block_interpolation < TestCase
    % Series of tests for data interpolation/extrapolation in the ortho_axes class
    %
    % The basic operations for cut_dnd with projection.
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
            ab_base = ortho_axes(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            ax = 0.5*(ax(1:end-1)+ax(2:end));
            ay = 0.5*(ay(1:end-1)+ay(2:end));
            r  = sqrt(ax.^2 + ay'.^2);

            data = exp(-(r-0.5).^2/0.1);

            ab_interp = ortho_axes(bin0{:});
            % define source and target coordinate systems
            source_proj = ortho_proj([1,0,0],[0,1,0]);
            targ_proj = ortho_proj([1/sqrt(2),1/sqrt(2),0],[1/sqrt(2),-1/sqrt(2),0]);
            si = ab_interp.interpolate_data(ab_base,source_proj,data,targ_proj);

            assertElementsAlmostEqual(si,data,'absolute',0.1)
            % Below are the tests for different definition of boundary
            % points
            %cs = size(si);
            %assertElementsAlmostEqual(si(1:cs(1)-1,1:cs(2)-1), ...
            %    data(1:cs(1)-1,1:cs(2)-1),'absolute',0.06)
        end
        function test_interp_2D_same_points_projected(~)
            dbr = [0,-2,-pi/2,0;pi,2,pi/2,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = ortho_axes(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            sdat= 1+sin(0.5*(ax(1:end-1)+ax(2:end)));
            cdat =1+cos(0.5*(ay(1:end-1)+ay(2:end)));
            data = sdat'.*cdat;

            %[int_points,int_data,cell_size] = ab_base.get_density(data);


            ab_interp = ortho_axes(bin0{:});
            % define source and target coordinate systems
            source_proj = ortho_proj([1,0,0],[0,1,0]);
            targ_proj = ortho_proj([1,0,0],[0,1,0]);
            si = ab_interp.interpolate_data(ab_base,source_proj,data,targ_proj );

            cs = size(si);
            assertElementsAlmostEqual(si(2:cs(1)-1,2:cs(2)-1), ...
                data(2:cs(1)-1,2:cs(2)-1),'absolute',1e-2)
            % Below are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si,data,'absolute',1e-2)
        end


        function test_interp_2D_same_points_interpolation(~)
            dbr = [0,-2,-pi/2,0;pi,2,pi/2,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),0.1,dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = ortho_axes(bin0{:});

            ax = ab_base.p{1};
            ay = ab_base.p{2};
            sdat= 1+sin(0.5*(ax(1:end-1)+ax(2:end)));
            cdat =1+cos(0.5*(ay(1:end-1)+ay(2:end)));
            data = sdat'.*cdat;

            ab_interp = ortho_axes(bin0{:});
            si = ab_interp.interpolate_data(ab_base,ortho_proj,data);

            assertElementsAlmostEqual(si,data,'absolute',1e-2)
            % Below are the tests for different definition of boundary
            % points
            %cs = size(si);
            %assertElementsAlmostEqual(si(1:cs(1)-1,1:cs(2)-1), ...
                %    data(1:cs(1)-1,1:cs(2)-1),'absolute',1e-2)
        end
        function test_interp_1D_frac_points_int_coeff(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            bin0 = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.1,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = ortho_axes(bin0{:});

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = ones(size(cp));

            % define less bins buy the same range as for ab_base
            nb = ab_base.nbins_all_dims;
            base_cell_volume = ab_base.get_bin_volume();
            nb(2) = floor(nb(2)*0.7);
            ab_interp = ortho_axes('img_range',ab_base.img_range,'nbins_all_dims',nb);
            assertElementsAlmostEqual(ab_base.img_range,ab_interp.img_range);


            si = ab_interp.interpolate_data(ab_base,ortho_proj,data);
            % integrated signal increase proportional to the
            % integration cell increase
            int_bin_volume = ab_interp.get_bin_volume();
            mult = int_bin_volume/base_cell_volume;

            assertEqualToTol(sum(si),sum(data),1.e-8);

            assertElementsAlmostEqual(si,mult*data(1:numel(si))');
            % Below are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(2:end-1),mult*data(2:numel(si)-1)');
        end
        function test_interp_1D_peak_averaging(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            ab_base = ortho_axes('img_range',dbr,'nbins_all_dims',[8,1,1,1]);

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = zeros(size(cp));
            n_center = floor(size(data,2)/2);
            data(n_center) = 10;


            ab_interp = ortho_axes('img_range',dbr,'nbins_all_dims',[8,1,1,1]);

            proj = ortho_proj();
            si = ab_interp.interpolate_data(ab_base,proj ,data,proj );

            assertEqualToTol(sum(si),sum(data),1.e-12);
            %sample= [0,0,1.25,7.5,1.25,0,0,0];
            assertElementsAlmostEqual(si,data')
        end
        %
        function test_interp_1D_half_points_int_coeff(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            ab_base = ortho_axes('img_range',dbr,'nbins_all_dims',[1,1,60,1]);

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));
            data = ones(size(cp));

            ab_interp = ortho_axes('img_range',dbr,'nbins_all_dims',[1,1,30,1]);

            si = ab_interp.interpolate_data(ab_base,ortho_proj,data);

            assertEqualToTol(sum(si),sum(data),1.e-12);
            assertElementsAlmostEqual(si,2*data(1:numel(si))')
            % Below are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(2:end-1),2*data(2:numel(si)-1)')
        end
        %
        function test_interp_1D_same_points_interpolation(~)
            dbr = [0,-2,-3,0;pi,2,3,10];
            bin0 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};
            ab_base = ortho_axes(bin0{:});

            ax = ab_base.p{1};
            cp = 0.5*(ax(1:end-1)+ax(2:end));

            % add 1 as some versions of algorithm (not currently implemented)
            % does not allow negative values for intermediate values
            % anywhere in between interpolation/integration.
            % But test is generic
            data = 1+sin(cp);

            %dbr(:,4) = [0;5];
            bin1 = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),dbr(2,4)]};

            ab_interp = ortho_axes(bin1{:});
            si = ab_interp.interpolate_data(ab_base,ortho_proj,data);


            assertElementsAlmostEqual(si,data')
            % Below are the tests for different definition of boundary
            % points
            %assertElementsAlmostEqual(si(1:end-1),data(1:end-1)')
        end
    end
end

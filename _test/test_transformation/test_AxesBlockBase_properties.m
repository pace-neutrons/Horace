classdef test_AxesBlockBase_properties < TestCase
    % Series of tests exposing AxesBlockBase old interface and
    % conversion from old to new class contents with the interface
    % remaining intact.

    properties
        out_dir=tmp_dir();
        working_dir;
        % Test axes block conversion from old to modern structure
        % Sample file build and written with previous version of the class
        % are stored in repository.
        % Redefine sample file name and set_save_sample to true
        % to obtain different sample file if(when) the internal sample
        % structure changes again
        ortho_axes_v1_file = 'axes_block_sample_v1.mat'; % savobj/loadobj reference file for version 1
        ortho_axes_v2_file = 'axes_block_sample_v2.mat'; % savobj/loadobj reference file for version 2
        sample_sqw_file = 'w2d_qq_sqw.sqw'
        % save sample -- simplified TestWithSave interface.
        % Generates v2 test files when save_sample = true
        save_sample = false;
    end

    methods
        function obj=test_AxesBlockBase_properties(varargin)
            if nargin<1
                name = 'test_AxesBlockBase_properties';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.working_dir = fileparts(mfilename("fullpath"));
        end
        %------------------------------------------------------------------
        function test_bin_volume_array(~)
            dbr = [0,-2,-3,0;10,2,3,10];
            nbins_all_dims = [10,1,6,5];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims);
            ax = cell(4,1);
            ax{1} = [0,1,2,3,5,10];
            ax{2} = [0,1,2,3,5,6];
            ax{3} = 1:0.1:2;
            ax{4} = [0,2,3,4,5,10];
            n_cells = cellfun(@(x)numel(x)-1,ax);
            n_cells = prod(n_cells);

            bv = ab.get_bin_volume(ax);

            assertEqual(numel(bv),n_cells);

            assertEqualToTol(bv(1),1*1*0.1*2,'tol',1.e-11);
            assertEqualToTol(bv(end),5*1*0.1*5,'tol',1.e-11);
        end

        function test_bin_volume_single(~)
            dbr = [0,-2,-3,0;10,2,3,10];
            nbins_all_dims = [10,1,6,5];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims);
            calc_vol = (dbr(2,:)-dbr(1,:))./nbins_all_dims;
            calc_vol = prod(calc_vol);

            bv = ab.get_bin_volume();
            assertEqual(calc_vol,bv)
        end
        %------------------------------------------------------------------
        function test_axes_block_nodes_hull_grid_mult_2(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            nbins_all_dims = [8,1,4,1];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims);

            hull_sizes = nbins_all_dims*2 + 1;
            assize = 0;
            j = 1:4;
            for i=1:4
                other_dim = hull_sizes(j~=i);
                assize = assize + 2*prod(other_dim);
            end
            ax = ab.get_bin_nodes('-hull',2);
            assertEqual(size(ax),[4,assize]);
        end

        function test_axes_block_nodes_hull_grid_mult_1(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            nbins_all_dims = [8,1,4,1];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims);

            hull_sizes = nbins_all_dims + 1;
            assize = 0;
            j = 1:4;
            for i=1:4
                other_dim = hull_sizes(j~=i);
                assize = assize + 2*prod(other_dim);
            end
            ax = ab.get_bin_nodes('-hull',1);
            assertEqual(size(ax),[4,assize]);
        end

        function test_axes_block_nodes_hull_no_halo(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            nbins_all_dims = [8,1,4,1];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims);

            ax = ab.get_bin_nodes('-axes_only','-hull');
            assertEqual(numel(ax),4)
            assertEqual(numel(ax{1}),2)
            assertEqual(numel(ax{2}),2)
            assertEqual(numel(ax{3}),2)
            assertEqual(numel(ax{4}),2)

            hallo_sizes = nbins_all_dims + 1;
            assize = 0;
            j = 1:4;
            for i=1:4
                other_dim = hallo_sizes(j~=i);
                assize = assize + 2*prod(other_dim);
            end
            ax = ab.get_bin_nodes('-hull');
            assertEqual(size(ax),[4,assize]);
        end

        function test_axes_block_nodes_hull(~)
            dbr = [0,-2,-3,0;8,2,3,10];
            nbins_all_dims = [8,1,4,1];
            ab = ortho_axes('img_range',dbr,'nbins_all_dims',nbins_all_dims );

            ax = ab.get_bin_nodes('-axes_only','-hull','-halo');
            assertEqual(numel(ax),4)
            assertEqual(numel(ax{1}),4)
            assertEqual(numel(ax{2}),4)
            assertEqual(numel(ax{3}),4)
            assertEqual(numel(ax{4}),4)

            hull_hallo_sizes = nbins_all_dims + 3;
            assize = 0;
            j = 1:4;
            for i=1:4
                other_dim = hull_hallo_sizes(j~=i);
                assize = assize + 4*prod(other_dim);
            end

            ax = ab.get_bin_nodes('-hull','-halo');
            assertEqual(size(ax),[4,assize]);
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_load_save_prev_sqw_version(obj)
            sample_file = fullfile(fileparts(obj.working_dir),...
                'test_combine',obj.sample_sqw_file);
            sq_sample = read_sqw(sample_file);
            % we read old class which does not have creation date
            assertFalse(sq_sample.main_header.creation_date_defined);


            test_write = fullfile(obj.out_dir,'AxesBlockBase_conv_test.sqw');
            %
            clob = onCleanup(@()delete(test_write));

            write_sqw(sq_sample,test_write);
            assertTrue(is_file(test_write))
            sq_req = read_sqw(test_write);
            % we wrote sqw file in new format and now the creation date is
            % defined
            assertTrue(sq_req.main_header.creation_date_defined);
            % to compare objects, we need to set up the same values for the
            % creation date. Undefined Creation date does not exist,
            % (function returns current date -- this checked in main_header)
            % so we need to assign it explicitly:
            sq_sample.main_header.creation_date= sq_req.main_header.creation_date;
            assertEqualToTol(sq_sample,sq_req,1.e-15,'ignore_str',true);

        end
        function test_save_load_prev_version(obj)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin2D = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab2D = ortho_axes(bin2D{:});
            bin4D = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab4D = ortho_axes(bin4D{:});
            %--------------------------------------------------------------
            % check version 1
            sample_file = fullfile(obj.working_dir,obj.ortho_axes_v1_file);

            ld = load(sample_file);
            assertEqual(ld.ab2D,ab2D);
            assertEqual(ld.ab4D,ab4D);
            %--------------------------------------------------------------
            % Check version 2
            sample_file = fullfile(obj.working_dir,obj.ortho_axes_v2_file);
            if obj.save_sample
                save(sample_file,'ab2D','ab4D')
            end
            ld = load(sample_file);
            assertEqual(ld.ab2D,ab2D);
            assertEqual(ld.ab4D,ab4D);
        end
        %------------------------------------------------------------------
        function test_set_nbin_all_dim_all_2D(~)
            range = [0,0,0,0;1,2,3,4];
            nbins = [1;4;1;2];
            ab = ortho_axes();
            ab.nbins_all_dims = nbins;
            ab.img_range = range;
            assertEqual(ab.nbins_all_dims,nbins')

            assertEqual(ab.dimensions,2)
            assertEqual(ab.iax,[1,3])
            assertEqual(ab.pax,[2,4])

            assertEqual(ab.iint,[0,0;1,3])
            assertEqual(numel(ab.p),2);
            assertEqual(ab.p{1},linspace(0,2,5))
            assertEqual(ab.p{2},linspace(0,4,3));
            assertEqual(ab.ulen,ones(1,4));
        end

        function test_set_nbin_all_dim_all_1D(~)
            nbins = [1;1;1;2];
            ab = ortho_axes();
            ab.nbins_all_dims = nbins ;
            assertEqual(ab.nbins_all_dims,nbins')

            assertEqual(ab.dimensions,1)
            assertEqual(ab.iax,1:3)
            assertEqual(ab.pax,4)
            %
            er = PixelDataBase.EMPTY_RANGE_();
            assertEqual(ab.iint,er(:,1:3))
            assertEqual(ab.p{1},[inf,0,-inf])
            assertEqual(ab.ulen,ones(1,4));
        end

        function test_set_nbin_all_dim_wrong(~)
            ab = ortho_axes();
            function set_wrong_nbin(ax,val)
                ax.nbins_all_dims = val;
            end
            assertExceptionThrown(@()set_wrong_nbin(ab,1),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,'a'),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,[0,0,0,0]),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,[1,10,-1,5]),...
                'HORACE:AxesBlockBase:invalid_argument');
        end
        %------------------------------------------------------------------
        function test_set_nbins_range_one(~)
            range = [-1,0,0,0;1,2,3,10];
            ab = ortho_axes();
            ab.img_range = range ;
            assertEqual(ab.img_range,range)


            ab.img_range(1,1) = 0;
            range = [0,0,0,0;1,2,3,10];
            assertEqual(ab.img_range,range)
        end

        function test_set_img_range_one(~)
            range = [-1,0,0,0;1,2,3,10];
            ab = ortho_axes();
            ab.img_range = range ;
            assertEqual(ab.img_range,range)
            assertEqual(ab.nbins_all_dims,[1,1,1,1])


            ab.img_range(1,1) = 0;
            range = [0,0,0,0;1,2,3,10];
            assertEqual(ab.img_range,range)
        end
        %
        function test_set_img_range_all(~)
            range = [-1,0,0,0;1,2,3,10];
            ab = ortho_axes();
            ab.img_range = range ;
            assertEqual(ab.img_range,range)

            assertEqual(ab.dimensions,0)
            assertEqual(ab.iax,1:4)
            assertEqual(ab.iint,range)
            assertTrue(isempty(ab.pax))
            assertTrue(isempty(ab.p))
            assertEqual(ab.ulen,ones(1,4));
        end
        %
        function test_set_img_range_wrong(~)
            ab = ortho_axes();
            function set_wrong_img_range(ax,val)
                ax.img_range = val;
            end
            assertExceptionThrown(@()set_wrong_img_range(ab,1),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()set_wrong_img_range(ab,'a'),...
                'HORACE:AxesBlockBase:invalid_argument');
            assertExceptionThrown(@()set_wrong_img_range(ab,[1,1,1,1;0,0,0,0]),...
                'HORACE:AxesBlockBase:invalid_argument');
        end
        %
        function test_default_constructor(~)
            ab = ortho_axes();
            assertEqual(ab.img_range,PixelDataBase.EMPTY_RANGE_)
            assertEqual(ab.nbins_all_dims,ones(1,4))

            assertEqual(ab.dimensions,0)
            assertEqual(ab.iax,1:4)
            assertEqual(ab.iint,PixelDataBase.EMPTY_RANGE_)
            assertTrue(isempty(ab.pax))
            assertTrue(isempty(ab.p))

            assertEqual(ab.ulen,ones(1,4));
        end
    end
end

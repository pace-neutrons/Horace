classdef test_axes_block_properties < TestCase
    % Series of tests exposing axes_block old interface and
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
        axes_block_v1_file = 'axes_block_sample_v1.mat'; % savobj/loadobj reference file for version 1
        axes_block_v2_file = 'axes_block_sample_v2.mat'; % savobj/loadobj reference file for version 2
        sample_sqw_file = 'w2d_qq_sqw.sqw'
        % save sample -- simlified TestWithSave interface. 
        % Generates v2 test files when save_sample = true
        save_sample = false;
    end

    methods
        function obj=test_axes_block_properties(varargin)
            if nargin<1
                name = 'test_axes_block_properties';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.working_dir = fileparts(mfilename("fullpath"));
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_load_save_prev_sqw_version(obj)
            sample_file = fullfile(fileparts(obj.working_dir),...
                'test_combine',obj.sample_sqw_file);
            sq_sample = read_sqw(sample_file);
            test_write = fullfile(obj.out_dir,'axes_block_conv_test.sqw');
            %
            clob = onCleanup(@()delete(test_write));

            write_sqw(sq_sample,test_write);
            assertTrue(is_file(test_write))
            sq_req = read_sqw(test_write);

            assertEqualToTol(sq_sample,sq_req,'ignore_str',true);

        end
        function test_save_load_prev_version(obj)
            dbr = [-1,-2,-3,0;1,2,3,10];
            bin2D = {[dbr(1,1),dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab2D = axes_block(bin2D{:});
            bin4D = {[dbr(1,1),0.1,dbr(2,1)];[dbr(1,2),0.2,dbr(2,2)];...
                [dbr(1,3),0.3,dbr(2,3)];[dbr(1,4),1,dbr(2,4)]};
            ab4D = axes_block(bin4D{:});
            %--------------------------------------------------------------
            % check version 1
            sample_file = fullfile(obj.working_dir,obj.axes_block_v1_file);

            ld = load(sample_file);
            assertEqual(ld.ab2D,ab2D);
            assertEqual(ld.ab4D,ab4D);
            %--------------------------------------------------------------
            % Check version 2
            sample_file = fullfile(obj.working_dir,obj.axes_block_v2_file);
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
            ab = axes_block();
            ab.nbins_all_dims = nbins;
            ab.img_range = range;
            assertEqual(ab.nbins_all_dims,nbins')

            assertEqual(ab.n_dims,2)
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
            ab = axes_block();
            ab.nbins_all_dims = nbins ;
            assertEqual(ab.nbins_all_dims,nbins')

            assertEqual(ab.n_dims,1)
            assertEqual(ab.iax,1:3)
            assertEqual(ab.pax,4)
            %
            assertEqual(ab.iint,zeros(2,3))
            assertEqual(ab.p{1},[0,0,0])
            assertEqual(ab.ulen,ones(1,4));
        end

        function test_set_nbin_all_dim_wrong(~)
            ab = axes_block();
            function set_wrong_nbin(ax,val)
                ax.nbins_all_dims = val;
            end
            assertExceptionThrown(@()set_wrong_nbin(ab,1),...
                'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,'a'),...
                'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,[0,0,0,0]),...
                'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()set_wrong_nbin(ab,[1,10,-1,5]),...
                'HORACE:axes_block:invalid_argument');
        end
        %------------------------------------------------------------------
        function test_set_nbins_range_one(~)
            range = [-1,0,0,0;1,2,3,10];
            ab = axes_block();
            ab.img_range = range ;
            assertEqual(ab.img_range,range)


            ab.img_range(1,1) = 0;
            range = [0,0,0,0;1,2,3,10];
            assertEqual(ab.img_range,range)
        end

        function test_set_img_range_one(~)
            range = [-1,0,0,0;1,2,3,10];
            ab = axes_block();
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
            ab = axes_block();
            ab.img_range = range ;
            assertEqual(ab.img_range,range)

            assertEqual(ab.n_dims,0)
            assertEqual(ab.iax,1:4)
            assertEqual(ab.iint,range)
            assertTrue(isempty(ab.pax))
            assertTrue(isempty(ab.p))
            assertEqual(ab.ulen,ones(1,4));
        end
        %
        function test_set_img_range_wrong(~)
            ab = axes_block();
            function set_wrong_img_range(ax,val)
                ax.img_range = val;
            end
            assertExceptionThrown(@()set_wrong_img_range(ab,1),...
                'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()set_wrong_img_range(ab,'a'),...
                'HORACE:axes_block:invalid_argument');
            assertExceptionThrown(@()set_wrong_img_range(ab,[1,1,1,1;0,0,0,0]),...
                'HORACE:axes_block:invalid_argument');
        end
        %
        function test_default_constructor(~)
            ab = axes_block();
            assertEqual(ab.img_range,zeros(2,4))
            assertEqual(ab.nbins_all_dims,ones(1,4))

            assertEqual(ab.n_dims,0)
            assertEqual(ab.iax,1:4)
            assertEqual(ab.iint,zeros(2,4))
            assertTrue(isempty(ab.pax))
            assertTrue(isempty(ab.p))

            assertEqual(ab.ulen,ones(1,4));
        end
    end
end

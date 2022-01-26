classdef test_axes_block_properties < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir=tmp_dir();
    end

    methods
        function obj=test_axes_block_properties(varargin)
            if nargin<1
                name = 'test_axes_block_properties';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end
        %------------------------------------------------------------------
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

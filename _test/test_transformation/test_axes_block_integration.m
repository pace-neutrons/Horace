classdef test_axes_block_integration < TestCase
    % Series of tests for data rebinning using the axes_block class
    %
    % The Horace V4.xxx basis for the legacy dnd cut operations
    % implemented in Horace v3.xxx
    properties
    end

    methods
        function obj=test_axes_block_integration(varargin)
            if nargin<1
                name = 'test_axes_block_integration';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_4d_to2D_partial_region(~)
            clOb = set_temporary_warning('off', 'HORACE:realign_bin_edges:invalid_argument');

            dbr0 = [ -1,1;-2,2;-3,3;0,10]';
            dbr1 = [  0,1;-2,0;-2,2;2,8]';
            bin0 = {[dbr0(1,1),0.1,dbr0(2,1)];[dbr0(1,2),0.2,dbr0(2,2)];
                [dbr0(1,3),0.15,dbr0(2,3)];[dbr0(1,4),0.5,dbr0(2,4)]};
            bin1 = {[dbr1(1,1),0.2,dbr1(2,1)];[dbr1(1,2),dbr1(2,2)];
                [dbr1(1,3),0.2,dbr1(2,3)];[dbr1(1,4),dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            ab_r = ab_base.realign_bin_edges(ab_sample);
            assertElementsAlmostEqual(ab_r.img_range,[-0.15,1.05;-2.1,0.1; ...
                -2.175,2.175;1.75,8.25]');


            data = ones(ab_base.dims_as_ssize);

            reb_data = ab_base.rebin_data({data},ab_r);

            %assertEqual(2*sum(data(1:numel(reb_data{1}))),sum(reb_data{1}));
            assertEqual(reb_data{1},286*ones(ab_r.dims_as_ssize))

        end
        function test_ab_indexes_1D_double_bin_partial_region(~)
            dbr0 = [ 0,10;-2,2;-3,3;0,10]';
            dbr1 = [ 0,5;-2,2;-3,3;0,10]';
            bin0 = {[dbr0(1,1),0.1,dbr0(2,1)];[dbr0(1,2),dbr0(2,2)];[dbr0(1,3),dbr0(2,3)];[dbr0(1,4),dbr0(2,4)]};
            bin1 = {[dbr1(1,1),0.2,dbr1(2,1)];[dbr1(1,2),dbr1(2,2)];[dbr1(1,3),dbr1(2,3)];[dbr1(1,4),dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            ab_r = ab_base.realign_bin_edges(ab_sample);
            assertElementsAlmostEqual(ab_r.img_range,[[-0.05;5.15],ab_sample.img_range(:,2:4)]);


            data = ones(ab_base.dims_as_ssize);

            reb_data = ab_base.rebin_data({data},ab_r);

            assertEqual(2*sum(data(1:numel(reb_data{1}))),sum(reb_data{1}));

            assertEqual(reb_data{1},2*ones(ab_r.dims_as_ssize))
        end

        function test_ab_indexes_1D_same_bin_partial_region(~)
            dbr0 = [ 0,10;-2,2;-3,3;0,10]';
            dbr1 = [ 0,5;-2,2;-3,3;0,10]';
            bin0 = {[dbr0(1,1),0.1,dbr0(2,1)];[dbr0(1,2),dbr0(2,2)];[dbr0(1,3),dbr0(2,3)];[dbr0(1,4),dbr0(2,4)]};
            bin1 = {[dbr1(1,1),0.1,dbr1(2,1)];[dbr1(1,2),dbr1(2,2)];[dbr1(1,3),dbr1(2,3)];[dbr1(1,4),dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            ab_r = ab_base.realign_bin_edges(ab_sample);
            assertEqual(ab_r,ab_sample);


            data = ones(ab_base.dims_as_ssize);

            reb_data = ab_base.rebin_data({data},ab_r);

            assertEqual(sum(data),2*sum(reb_data{1})-1);

            assertEqual(reb_data{1},ones(ab_r.dims_as_ssize))
        end
        function test_ab_alignment_iax_aligned(~)
            clOb = set_temporary_warning('off','HORACE:realign_bin_edges:invalid_argument');

            dbr0 = [-1,1;-2,2;-3,3;0,10]';
            dbr1 = [ 0,1;-1,1; -0.25,0.25; 0,1]';
            bin0 = {[dbr0(1,1),dbr0(2,1)];[dbr0(1,2),dbr0(2,2)];[dbr0(1,3),0.2,dbr0(2,3)];[dbr0(1,4),1,dbr0(2,4)]};
            bin1 = {[dbr1(1,1),dbr1(2,1)];[dbr1(1,2),0.2,dbr1(2,2)];[dbr1(1,3),0.05,dbr1(2,3)];[dbr1(1,4),5,dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            ab_r = ab_base.realign_bin_edges(ab_sample);

            assertElementsAlmostEqual(ab_r.img_range(:,1),ab_base.img_range(:,1));
            assertEqual(ab_r.nbins_all_dims(1),1);

            assertElementsAlmostEqual(ab_r.img_range(:,2),ab_base.img_range(:,2));
            assertEqual(ab_r.nbins_all_dims(2),1);

            assertElementsAlmostEqual(ab_r.img_range(:,3),[-0.3;0.3]);
            assertEqual(ab_r.nbins_all_dims(3),3);

            assertElementsAlmostEqual(ab_r.img_range(:,4),[-0.5;9.5]);
            assertEqual(ab_r.nbins_all_dims(4),2);
        end

        function test_non_overlapping_ranges_throw(~)
            dbr0 = [-1,1;-2,2;-3,3;-1,11]';
            dbr1 = [ 2,3;-2,2;-5,5; 0,10]';
            bin0 = {[dbr0(1,1),0.1,dbr0(2,1)];[dbr0(1,2),0.1,dbr0(2,2)];[dbr0(1,3),0.1,dbr0(2,3)];[dbr0(1,4),1,dbr0(2,4)]};
            bin1 = {[dbr1(1,1),0.1,dbr1(2,1)];[dbr1(1,2),0.2,dbr1(2,2)];[dbr1(1,3),0.05,dbr1(2,3)];[dbr1(1,4),2,dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            assertExceptionThrown(@()realign_bin_edges(ab_base,ab_sample),...
                'HORACE:realign_bin_edges:invalid_argument');
        end
        %
        function test_ab_alignment_pax_selected(~)
            clOb = set_temporary_warning('off','HORACE:realign_bin_edges:invalid_argument');

            dbr0 = [-1,1;-2,2;-3,3;-1,11]';
            dbr1 = [ 0,1;-2,2;-5,5; 0,10]';
            bin0 = {[dbr0(1,1),0.1,dbr0(2,1)];[dbr0(1,2),0.1,dbr0(2,2)];[dbr0(1,3),0.1,dbr0(2,3)];[dbr0(1,4),1,dbr0(2,4)]};
            bin1 = {[dbr1(1,1),0.1,dbr1(2,1)];[dbr1(1,2),0.2,dbr1(2,2)];[dbr1(1,3),0.05,dbr1(2,3)];[dbr1(1,4),2,dbr1(2,4)]};

            ab_base = line_axes(bin0{:});
            ab_sample = line_axes(bin1{:});

            ab_r = ab_base.realign_bin_edges(ab_sample);

            assertElementsAlmostEqual(ab_r.img_range(:,1),ab_sample.img_range(:,1));
            assertEqual(ab_r.nbins_all_dims(1),ab_sample.nbins_all_dims(1));

            assertElementsAlmostEqual(ab_r.img_range(:,2),[-2.05;2.15]);
            assertEqual(ab_r.nbins_all_dims(2),ab_sample.nbins_all_dims(2));

            assertElementsAlmostEqual(ab_r.img_range(:,3),ab_base.img_range(:,3));
            assertEqual(ab_r.nbins_all_dims(3),ab_base.nbins_all_dims(3));

            assertElementsAlmostEqual(ab_r.img_range(:,4),[-1.5;12.5]);
            assertEqual(ab_r.nbins_all_dims(4),7);
        end
    end
end

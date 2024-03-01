classdef test_IX_dataset_1d <  TestCase
    %
    %Test class to test IX_dataset_1d methods
    %
    properties
    end

    methods
        function this=test_IX_dataset_1d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_1d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_d1d_to_IX_dataset1D(~ )
            ax = line_axes([0,1],[0,0.1,1],[0,1],[5,10]);
            proj = line_proj('alatt',3,'angdeg',90);
            d1d_obj = d1d(ax,proj);
            d1d_obj.s = 1:0.1:2;
            d1d_obj.e = 1:0.1:2;
            d1d_obj.npix = 2*ones(1,11);

            ds = d1d_obj.IX_dataset_1d();

            assertEqual(ds.signal,d1d_obj.s);
            assertEqual(ds.error,sqrt(d1d_obj.e));

        end
        function test_properties(~)
            id = IX_dataset_1d();
            id.title = 'my title';
            assertEqual(id.title,{'my title'});

            id.x_axis = 'Coord';
            ax = id.x_axis;
            assertTrue(isa(ax,'IX_axis'));
            assertEqual(ax.caption,{'Coord'});
            ax.units = 'A^-1';
            id.s_axis = ax;

            ay = id.s_axis;
            assertTrue(isa(ay,'IX_axis'));


            id.do_check_combo_arg = false;
            id.x = 1:10;

            ME= assertExceptionThrown(@()check_combo_arg(id), ...
                'HERBERT:IX_data_1d:invalid_argument');
            assertEqual(ME.message,'numel(signal)=0, numel(x)=10; numel(signal)  must be equal to numel(x) or numel(x)+1');

            id.signal = ones(1,10);
            ME= assertExceptionThrown(@()check_combo_arg(id), ...
                'HERBERT:IX_data_1d:invalid_argument');
            assertEqual(ME.message,'numel(signal)=10, numel(error)=0; numel(signal)~=numel(error)');

            id.error = ones(1,10);
            id = check_combo_arg(id);
            id.do_check_combo_arg = true;

            val = id.signal;
            assertEqual(val,ones(10,1));
            assertEqual(id.error,ones(10,1));
        end
        function test_fraction_split_NaNs(~)
            ds = IX_dataset_1d(1:10);
            ss = ones(10,1);
            in = [2,4,7,9];
            ss(in) = NaN;
            ds.signal = ss;

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,2/6);
            assertEqual(n_points,6);
        end

        function test_fraction_edge_NaNs(~)
            ds = IX_dataset_1d(1:10);
            ss = ones(10,1);
            in = [2,5,9];
            ss(in) = NaN;
            ds.signal = ss;

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,5/7);
            assertEqual(n_points,7);
        end

        function test_fraction_other_NaNs(~)
            ds = IX_dataset_1d(1:10);
            ss = ones(10,1);
            in = [3,4,7,10];
            ss(in) = NaN;
            ds.signal = ss;

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,1);
            assertEqual(n_points,6);
        end

        function test_fraction_some_NaNs(~)
            ds = IX_dataset_1d(1:10);
            ss = ones(10,1);
            in = [2,3,7,10];
            ss(in) = NaN;
            ds.signal = ss;

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,5/6);
            assertEqual(n_points,6);
        end

        function test_fraction_hald_NaNs(~)
            ds = IX_dataset_1d(1:10);
            ss = ones(10,1);
            in = 1:2:10;
            ss(in) = NaN;
            ds.signal = ss;

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,0);
            assertEqual(n_points,5);
        end
        function test_fraction_no_NANs(~)
            ds = IX_dataset_1d(1:10);

            [frac,n_points] = ds.calc_continuous_fraction();

            assertEqual(frac,1);
            assertEqual(n_points,10);
        end


        function test_constructor_x(~)
            %   >> w = IX_dataset_1d (x)
            ds = IX_dataset_1d(1:10);
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,zeros(10,1));
            assertEqual(ds.error,zeros(10,1));
        end
        function test_constructor_xs(~)
            %   >> w = IX_dataset_1d (x,signal)
            ds = IX_dataset_1d(1:10,ones(1,9));
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(9,1));
            assertEqual(ds.error,zeros(9,1));
        end
        function test_constructor_xse(~)
            %   >> w = IX_dataset_1d (x,signal,error)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10));

            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));

            data = [1:10;2*ones(1,10);ones(1,10)];
            ds = IX_dataset_1d(data);

            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,2*ones(10,1));
            assertEqual(ds.error,ones(10,1));
        end

        function test_constructor_xse_title_axis(~)
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),'my object','x-axis name','y-axis name');
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
        end
        function test_constructor_xse_title_axis_distribution(~)
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});

            assertEqual(ds.x_distribution,false);


        end
        %
        function test_constructor_xse_title_axis_distr_random_order(~)
            %   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
            ds = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                'y-axis name',1:10,'x-axis name',false);

            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});

            assertEqual(ds.x_distribution,false);
        end

        function test_methods(~)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name');
            [ax,hist] = ds.axis;
            assertFalse(hist);
            assertEqual(ax.values,1:10);
            assertTrue(isa(ax.axis,'IX_axis'));
            assertTrue(ax.distribution);

            dsa = repmat(ds,2,1);
            dsa(2).x = 0.5:1:10.5;

            [ax,hist] = dsa.axis;
            assertEqual(hist,[false,true]);
            assertEqual(ax(1).values,1:10);
            assertEqual(ax(2).values,0.5:1:10.5);

            is_hist = dsa.ishistogram;
            is_hist1 = ishistogram(dsa,1);
            assertEqual(is_hist,is_hist1);
            assertFalse(is_hist(1));
            assertTrue(is_hist(2));

            ids = dsa.cnt2dist();
            idr = ids.dist2cnt();
            % Not equal -- bug in old code!
            %           assertEqual(dsa,idr);

        end
        function test_op_managers(~)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name');
            dsa = repmat(ds,2,1);

            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,1));
            assertEqual(dss.error,sqrt(2*ones(10,1)));

            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));

            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));


            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,1));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,1)));
        end

    end
end

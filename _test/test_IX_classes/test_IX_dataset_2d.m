classdef test_IX_dataset_2d <  TestCase
    %
    %Test class to test IX_dataset_1d methods
    %


    properties
    end

    methods
        function this=test_IX_dataset_2d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_2d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        function test_d2d_to_IX_dataset2D(~ )
            ax = line_axes([0,1],[0,0.1,1],[0,1],[5,1,10]);
            proj = line_proj('alatt',3,'angdeg',90);
            d2d_obj = d2d(ax,proj);
            d2d_obj.s = ones(11,6);
            d2d_obj.e = 2*ones(11,6);
            d2d_obj.npix = 2*ones(11,6);

            ds = d2d_obj.IX_dataset_2d();

            assertEqual(ds.signal,d2d_obj.s);
            assertEqual(ds.error,sqrt(d2d_obj.e));

        end

        function test_prop_title(~)
            id = IX_dataset_2d();
            id.title = 'my title';
            assertEqual(id.title,{'my title'});
        end
        function test_prop_x_axis(~)
            id = IX_dataset_2d();
            id.x_axis = 'Coord';
            ax = id.x_axis;
            assertTrue(isa(ax,'IX_axis'));
            assertEqual(ax.caption,{'Coord'});
            ax.units = 'A^-1';
            id.s_axis = ax;

            ay = id.s_axis;
            assertTrue(isa(ay,'IX_axis'));
        end
        function test_prop_y_axis(~)
            id = IX_dataset_2d();
            id.y_axis = 'dist';
            ay = id.y_axis;
            assertTrue(isa(ay,'IX_axis'));
            assertEqual(ay.caption,{'dist'});
            ay.units = 'A^-1';
            id.y_axis = ay;
            assertTrue(isa(id.y_axis,'IX_axis'));
            assertEqual(id.y_axis.caption,{'dist'});
        end

        function test_combo_properties_set(~)
            id = IX_dataset_2d();
            id.do_check_combo_arg = false;
            id.x = 1:10;
            ME= assertExceptionThrown(@()check_combo_arg(id), ...
                'HERBERT:IX_data_2d:invalid_argument');
            assertEqual(ME.message,'size(signal,1)=0, numel(x)=10; size(signal,1) must be equal to numel(x) or numel(x)+1');

            id.signal = ones(20,10);
            ME= assertExceptionThrown(@()check_combo_arg(id), ...
                'HERBERT:IX_data_2d:invalid_argument');
            assertEqual(ME.message,'size(signal)=[20,10], size(error)=[0,1]; size(signal)~=size(error)');

            id.error = ones(20,10);
            ME= assertExceptionThrown(@()check_combo_arg(id), ...
                'HERBERT:IX_data_2d:invalid_argument');
            assertEqual(ME.message,'size(signal,2)=20, numel(y)=0; size(signal,2)  must be equal to numel(y) or numel(y)+1');

            id.y = 1:20;
            id = check_combo_arg(id);
            id.do_check_combo_arg = true;

            val = id.signal;
            assertEqual(val,ones(10,20));
            assertEqual(id.error,ones(10,20));
        end

        function test_constructor_xy(~)
            % >> w = IX_dataset_2d (x,y)
            ds = IX_dataset_2d(1:10,1:20);
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:20);
            assertEqual(ds.signal,zeros(10,20));
            assertEqual(ds.error,zeros(10,20));
        end
        function test_constructor_xys(~)
            %   >> w = IX_dataset_2d (x,y,signal)
            ds = IX_dataset_2d(1:10,1:20,ones(9,19));
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:20);
            assertEqual(ds.signal,ones(9,19));
            assertEqual(ds.error,zeros(9,19));
        end
        function test_constructor_xyse(~)
            %   >> w = IX_dataset_2d (x,y,signal,error)
            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20));
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:20);
            assertEqual(ds.signal,ones(10,20));
            assertEqual(ds.error,ones(10,20));

        end
        function test_constructor_xyse_title_axis(~)
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal');
            assertEqual(ds.x,1:20);
            assertEqual(ds.y,1:10);
            assertEqual(ds.signal,ones(20,10));
            assertEqual(ds.error,ones(20,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
        end

        function test_constructor_xyse_title_axis_no_distr(~)
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis,x_distribution,y_distribution)
            ds = IX_dataset_2d(1:20,1:10,ones(20,10),ones(20,10),...
                'my object','x-axis name','y-axis name','signal',false,false);
            assertEqual(ds.x,1:20);
            assertEqual(ds.y,1:10);
            assertEqual(ds.signal,ones(20,10));
            assertEqual(ds.error,ones(20,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
        end
        function test_constructor_xyse_title_axis_names(~)
            %   >> w = IX_dataset_2d (title, signal, error, s_axis, x, x_axis, x_distribution, y, y_axis, y_distribution)

            ds = IX_dataset_2d('my object',ones(15,10),ones(15,10),...
                'signal',1:15,'x-axis name',false,...
                1:10,'y-axis name',false);
            assertEqual(ds.x,1:15);
            assertEqual(ds.y,1:10);
            assertEqual(ds.signal,ones(15,10));
            assertEqual(ds.error,ones(15,10));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.y_axis.caption,{'y-axis name'});
            assertEqual(ds.s_axis.caption,{'signal'});

            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
        end

        function test_methods(~)
            ds = IX_dataset_2d(1:10,1:15,ones(10,15),ones(10,15),...
                'my object','x-axis name','y-axis name','signal');
            [ax,hist] = ds.axis(2);
            assertFalse(hist);
            assertEqual(ax.values,1:15);
            assertTrue(isa(ax.axis,'IX_axis'));
            assertTrue(ax.distribution);

            dsa = repmat(ds,2,1);
            dsa(2).x = 0.5:1:10.5;

            [ax,hist] = dsa(1).axis;
            assertEqual(hist,false);
            assertEqual(ax(1).values,1:10);
            assertEqual(ax(2).values,1:15);

            is_hist = dsa.ishistogram;
            is_hist1 = ishistogram(dsa,1);
            is_hist2 = ishistogram(dsa,2);
            assertEqual(is_hist,[is_hist1;is_hist2]);
            assertFalse(is_hist(1,1));
            assertTrue(is_hist(1,2));
            assertFalse(is_hist(2,1));
            assertFalse(is_hist(2,2));


            ids = dsa.point2hist();
            idr = ids.hist2point();
            %BUG?
            %           assertEqual(dsa,idr);

        end
        function test_op_managers(~)
            %   >> w = IX_dataset_2d (x,y,signal,error,title,x_axis,y_axis,s_axis)

            ds = IX_dataset_2d(1:10,1:20,ones(10,20),ones(10,20),...
                'my object','x-axis name','y-axis name','signal');
            dsa = repmat(ds,2,1);

            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,20));
            assertEqual(dss.error,sqrt(2*ones(10,20)));

            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));

            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));


            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,20));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,20)));
        end
    end

end


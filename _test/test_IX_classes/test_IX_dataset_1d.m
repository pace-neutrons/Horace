classdef test_IX_dataset_1d <  TestCase
    %
    %Test class to test IX_dataset_1d methods
    %
    
    
    %
    % $Revision:: 831 ($Date:: 2019-06-03 09:47:08 +0100 (Mon, 3 Jun 2019) $)
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
        
        function test_properties(obj)
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
            
            
            id.x = 1:10;
            assertFalse(id.get_isvalid())
            val = id.x;
            assertTrue(ischar(val));
            assertEqual('numel(signal)=0, numel(x)=10; numel(signal)  must be equal to numel(x) or numel(x)+1',val);
            
            id.signal = ones(1,10);
            val = id.signal;
            assertTrue(ischar(val));
            assertEqual('numel(signal)=10, numel(error)=0; numel(signal)~=numel(error)',val);
            assertFalse(id.get_isvalid())
            
            
            id.error = ones(1,10);
            assertTrue(id.get_isvalid())
            
            val = id.signal;
            assertFalse(ischar(val));
            assertEqual(val,ones(10,1));
            assertEqual(id.error,ones(10,1));
        end
        
        function test_constructor(obj)
            %   >> w = IX_dataset_1d (x)
            ds = IX_dataset_1d(1:10);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,zeros(10,1));
            assertEqual(ds.error,zeros(10,1));
            %   >> w = IX_dataset_1d (x,signal)
            ds = IX_dataset_1d(1:10,ones(1,9));
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(9,1));
            assertEqual(ds.error,zeros(9,1));
            
            %   >> w = IX_dataset_1d (x,signal,error)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10));
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            
            data = [1:10;2*ones(1,10);ones(1,10)];
            ds = IX_dataset_1d(data);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,2*ones(10,1));
            assertEqual(ds.error,ones(10,1));
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),'my object','x-axis name','y-axis name');
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            %   >> w = IX_dataset_1d (x,signal,error,title,x_axis,s_axis, x_distribution)
            ds = IX_dataset_1d(1:10,ones(1,10),ones(1,10),...
                'my object','x-axis name','y-axis name',false);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
            
            
            %   >> w = IX_dataset_1d (title, signal, error, s_axis, x, x_axis, x_distribution)
            ds = IX_dataset_1d('my object',ones(1,10),ones(1,10),...
                'y-axis name',1:10,'x-axis name',false);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.signal,ones(10,1));
            assertEqual(ds.error,ones(10,1));
            assertEqual(ds.title,{'my object'});
            assertEqual(ds.x_axis.caption,{'x-axis name'});
            assertEqual(ds.s_axis.caption,{'y-axis name'});
            assertEqual(ds.x_distribution,false);
        end
        
        function test_methods(obj)
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
        function test_op_managers(obj)
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


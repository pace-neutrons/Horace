classdef test_IX_dataset_3d <  TestCase
    %
    %Test class to test IX_dataset_1d methods
    %
    
    
    %
    % $Revision$ ($Date$)
    %
    
    properties
    end
    
    methods
        function this=test_IX_dataset_3d(varargin)
            if nargin == 0
                name = 'test_IX_dataset_3d';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        function test_properties(obj)
            id = IX_dataset_3d();
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
            
            id.y_axis = 'dist';
            ay = id.y_axis;
            assertTrue(isa(ay,'IX_axis'));
            assertEqual(ay.caption,{'dist'});
            ay.units = 'A^-1';
            id.y_axis = ay;
            assertTrue(isa(id.y_axis,'IX_axis'));
            assertEqual(id.y_axis.caption,{'dist'});
            
            id.x = 1:10;
            assertFalse(id.get_isvalid())
            val = id.x;
            assertTrue(ischar(val));
            assertEqual('size(signal,1)=0, numel(x)=10; size(signal,1) must be equal to numel(x) or numel(x)+1',val);
            
            
            
            id.signal = ones(10,20);
            val = id.signal;
            assertTrue(ischar(val));
            assertEqual('size(signal)=[10,20,1], size(error)=[0,0,0]; size(signal)~=size(error)',val);
            assertFalse(id.get_isvalid())
            
            
            id.error = ones(20,10);
            assertFalse(id.get_isvalid())
            val = id.x;
            assertTrue(ischar(val));
            assertEqual('size(signal)=[10,20,1], size(error)=[20,10,1]; size(signal)~=size(error)',val)
            
            
            id.error = ones(10,20);
            id.y = 1:20;
            assertFalse(id.get_isvalid())
            val = id.x;
            assertEqual('size(signal,3)=1, numel(z)=0; size(signal,3) must be equal to numel(z) or numel(z)+1',val);
            
            id.z = 0.5;
            assertTrue(id.get_isvalid())
            
            
            val = id.signal;
            assertFalse(ischar(val));
            assertEqual(val,ones(10,20));
            assertEqual(id.error,ones(10,20));
        end
        
        function test_constructor(obj)
            %   >> w = IX_dataset_3d (x,y,z)
            ds = IX_dataset_3d(1:10,1:5,1:7);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,zeros(10,5,7));
            assertEqual(ds.error,zeros(10,5,7));
            
            %   >> w = IX_dataset_3d (x,y,z,signal)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(9,4,6));
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,ones(9,4,6));
            assertEqual(ds.error,zeros(9,4,6));
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7));
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my 3D obj','x-axis','y-axis','z-axis','signal');
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,z_axis,s_axis,x_distribution,y_distribution,z_distribution)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my 3D obj','x-axis','y-axis','z-axis','signal',...
                false,false,false);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
            assertEqual(ds.z_distribution,false);
            
            %   >> w = IX_dataset_3d (title, signal, error, s_axis, x, x_axis, x_distribution,...
            %                                          y, y_axis, y_distribution, z, z-axis, z_distribution)
            
            ds = IX_dataset_3d('my 3D obj',ones(10,5,7),ones(10,5,7),...
                'signal',1:10,'x-axis',false,...
                1:5,'y-axis',false,...
                1:7,'z-axis',false);
            assertTrue(ds.get_isvalid());
            assertEqual(ds.x,1:10);
            assertEqual(ds.y,1:5);
            assertEqual(ds.z,1:7);
            assertEqual(ds.signal,ones(10,5,7));
            assertEqual(ds.error,ones(10,5,7));
            assertEqual(ds.title,{'my 3D obj'});
            assertEqual(ds.x_axis.caption,{'x-axis'});
            assertEqual(ds.y_axis.caption,{'y-axis'});
            assertEqual(ds.z_axis.caption,{'z-axis'});
            assertEqual(ds.s_axis.caption,{'signal'});
            assertEqual(ds.x_distribution,false);
            assertEqual(ds.y_distribution,false);
            assertEqual(ds.z_distribution,false);
        end
        
        function test_methods(obj)
            ds = IX_dataset_3d(1:10,1:5,1:7,ones(10,5,7),ones(10,5,7),...
                'my object','x-axis','y-axis','z-axis','signal');
            [ax,hist] = ds.axis(2);
            assertFalse(hist);
            assertEqual(ax.values,1:5);
            assertTrue(isa(ax.axis,'IX_axis'));
            assertTrue(ax.distribution);
            
            dsa = repmat(ds,2,1);
            dsa(2).x = 0.5:1:10.5;
            
            [ax,hist] = dsa(1).axis;
            assertEqual(hist,false);
            assertEqual(ax(1).values,1:10);
            assertEqual(ax(2).values,1:5);
            assertEqual(ax(3).values,1:7);
            
            is_hist = dsa.ishistogram;
            is_hist1 = ishistogram(dsa,1);
            is_hist2 = ishistogram(dsa,2);
            is_hist3 = ishistogram(dsa,3);
            assertEqual(is_hist,[is_hist1;is_hist2;is_hist3]);
            assertFalse(is_hist(1,1));
            assertTrue(is_hist(1,2));
            assertFalse(is_hist(2,1));
            assertFalse(is_hist(2,2));
            assertFalse(is_hist(3,1));
            assertFalse(is_hist(3,2));
            
            
            ids = dsa.point2hist();
            idr = ids.hist2point();
            %BUG?
            %           assertEqual(dsa,idr);
            
        end
        function test_op_managers(obj)
            %   >> w = IX_dataset_3d (x,y,z,signal,error,title,x_axis,y_axis,s_axis)
            
            ds = IX_dataset_3d(1:10,1:5,1:15,ones(10,5,15),ones(10,5,15),...
                'test 3D object','x-axis','y-axis','z-axis','signal');
            dsa = repmat(ds,2,1);
            
            dss = dsa(1) + dsa(2);
            assertEqual(dss.signal,2*ones(10,5,15));
            assertEqual(dss.error,sqrt(2*ones(10,5,15)));
            
            dsm = -ds;
            dss  = dss+dsm;
            assertEqual(dss.signal,ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
            dss  = dss+1;
            assertEqual(dss.signal,2*ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
            
            dss  = 1+ dss;
            assertEqual(dss.signal,3*ones(10,5,15));
            assertElementsAlmostEqual(dss.error,sqrt(3*ones(10,5,15)));
            
        end
        
        
    end
    
end


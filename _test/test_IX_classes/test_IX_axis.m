classdef test_IX_axis <  TestCase
    %
    %Test class to test IX_axis methods
    %
    
    
    %
    % $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
    %
    
    properties
    end
    
    methods
        function this=test_IX_axis(varargin)
            if nargin == 0
                name = 'test_IX_axis';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        function test_methods(obj)
            ia = IX_axis();
            ia.caption = 'my axis name';
            assertEqual(ia.caption,{'my axis name'});
            
            ia.units = 'mEv';
            ia.code = 'blabla';
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'blabla');
            
            ia.ticks =[];
            assertEqual(ia.ticks,'');
            
            %
            op = struct('type','.','subs','ticks');
            f = @()subsasgn(ia,op,struct());
            assertExceptionThrown(f,'IX_axis:invalid_argument');
            
            %
            data =  struct('positions',[],'labels',{{}});
            ia.ticks =data;
            assertEqual(ia.ticks,data);
            %
            data.labels= {'1','2','3'};
            
            f = @()subsasgn(ia,op,data);
            assertExceptionThrown(f,'IX_axis:invalid_argument');
            %
            data.labels= {};
            data.positions = [1,2,3];
            ia.ticks =data;
            da = ia.ticks;
            assertEqual(da.positions,data.positions)
            %
            
            data.labels = {'a','b','c'};
            ia.ticks =data;
            assertEqual(ia.ticks.positions,data.positions);
            assertEqual(ia.ticks.labels,data.labels(:));
            
        end
        function test_constructor(obj)
            ia = IX_axis('my axis name');
            assertEqual(ia.caption,{'my axis name'});
            
            ia = IX_axis('my axis name','mEv');
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            
            
            ia = IX_axis('my axis name','mEv','code');
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'code');
            
            
            ia = IX_axis('my axis name','mEv','',[1,2,3]);
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'');
            da = ia.ticks;
            assertEqual(da.positions,[1,2,3])
            assertTrue(iscell(da.labels));
            assertEqual(numel(da.labels),3);
            
            data.positions = [1,2,3];
            data.labels = {'a','b','c'};
            %
            ia = IX_axis('my axis name','mEv','',data.positions,data.labels);
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'');
            da = ia.ticks;
            assertEqual(da.positions,[1,2,3])
            assertEqual(ia.ticks.labels,data.labels(:)');
            
            
            ia = IX_axis('my axis name','mEv','',data);
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'');
            da = ia.ticks;
            assertEqual(da.positions,[1,2,3])
            assertEqual(ia.ticks.labels,data.labels(:));
            
            
            
            ias = struct(ia);
            ia = IX_axis(ias);
            assertEqual(ia.caption,{'my axis name'});
            assertEqual(ia.units,'mEv');
            assertEqual(ia.code,'');
            da = ia.ticks;
            assertEqual(da.positions,[1,2,3])
            assertEqual(ia.ticks.labels,data.labels(:)');
            
        end
        
    end
    
end


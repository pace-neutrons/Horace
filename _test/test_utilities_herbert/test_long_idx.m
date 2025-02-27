classdef test_long_idx < TestCase
    properties
    end
    methods
        function obj = test_long_idx(varargin)
            if nargin<1
                name = 'test_long_idx';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
        end
        function test_long_idx_convertable(~)

            run_id0 = 500:550;
            det_id0  = 1:200;
            en_id0 = 100:120;

            [idx,mm_all] = long_idx({run_id0,det_id0,en_id0});
            assertEqual(mm_all,[500,550;1,200;100,120]);

            sid = short_from_long_idx(idx,mm_all);
            assertEqual(size(sid),[3,51*200*21]);

            assertEqual(unique(sid(1,:)),run_id0);
            assertEqual(unique(sid(2,:)),det_id0);
            assertEqual(unique(sid(3,:)),en_id0);
        end

        function test_long_idx_working(~)

            run_id0 = 500:550;
            det_id0  = 1:200;
            en_id0 = 100:1100;

            [idx,mm_all] = long_idx({run_id0,det_id0,en_id0});

            assertEqual(mm_all,[500,550;1,200;100,1100]);


            assertEqual(min_max(idx),uint64([0,51*200*1001-1]));
            assertEqual(numel(idx),51*200*1001);

            [X,Y,Z] = ndgrid( ...
                run_id0-mm_all(1,1)+1,det_id0-mm_all(2,1)+1,en_id0-mm_all(3,1)+1);
            [x,y,z] = ind2sub([51,200,1001],idx+1);
            assertEqual(X(:),x')
            assertEqual(Y(:),y')
            assertEqual(Z(:),z')
        end

        function test_simple_long_idx(~)

            run_id0 = 1:10;
            en_id0  = 1:100;
            det_id0 = 1:200;
            [X,Y,Z] = ndgrid(run_id0,en_id0,det_id0);

            idx = [X(:),Y(:),Z(:)]';
            [idx,mm_all] = long_idx(idx);

            assertEqual(mm_all,[1,10;1,100;1,200]);

            assertEqual(numel(idx),numel(X));
            assertEqual(min_max(idx),uint64([0,10*100*200-1]));

            [x,y,z] = ind2sub([10,100,200],idx+1);
            assertEqual(X(:),x')
            assertEqual(Y(:),y')
            assertEqual(Z(:),z')

        end
    end
end
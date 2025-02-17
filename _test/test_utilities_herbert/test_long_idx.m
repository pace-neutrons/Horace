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
        function test_long_idx_working(~)

            run_id0 = 500:550;
            en_id0  = 1:200;
            det_id0 = 100:1100;
            run_id = repmat(run_id0,1,numel(en_id0)*numel(det_id0));
            en_id  = repmat(en_id0,1,numel(run_id0 )*numel(det_id0));
            det_id = repmat(det_id0,1,numel(run_id0 )*numel(en_id0));

            [idx,mm_run,mm_en,mm_det] = long_idx(run_id,en_id,det_id);

            assertEqual(mm_run,[500,550]);
            assertEqual(mm_en,[1,200]);
            assertEqual(mm_det,[100,1100]);

            assertEqual(numel(idx),numel(run_id));
            assertEqual(min_max(idx),uint64([0,51*200*1001-1]));

        end

    end
end
classdef test_in_ranges < TestCase
    %
    properties
    end

    methods
        %--------------------------------------------------------------------------
        function self = test_in_ranges(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_in_ranges';
            end
            self = self@TestCase(name);
        end

        %--------------------------------------------------------------------------
        function test_four_vectors_around_no_details(~)
            box = [-1,-2,-3;1,2,3];
            vec = zeros(3,4);
            vec(1,2) = 2;
            vec(3,3) = 3;
            vec(:,4) = 5;

            [in,in_details] = in_range(box,vec);

            assertEqual(in,[1,-1,0,-1]);
            assertTrue(isempty(in_details));
        end

        function test_four_vectors_around(~)
            box = [-1,-2,-3;1,2,3];
            vec = zeros(3,4);
            vec(1,2) = 2;
            vec(3,3) = 3;
            vec(:,4) = 5;

            [in,in_details] = in_range(box,vec,true);

            assertEqual(in,[1,-1,0,-1]);
            assertEqual(in_details,[1,1,1;-1,1,1;1,1,0;-1,-1,-1]');
        end

        function test_one_vector_inside(~)
            box = [-1,-2,-3;1,2,3];
            vec = zeros(3,1);

            [in,in_details] = in_range(box,vec,true);

            assertEqual(in,1);
            assertEqual(in_details,ones(3,1));
        end
        %--------------------------------------------------------------------------
    end
end

classdef test_bin_inside < TestCase
    %
    properties
        sz
        coord
    end

    methods
        %------------------------------------------------------------------
        function self = test_bin_inside(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_bin_inside';
            end
            self = self@TestCase(name);
            self.sz = [10,20,30];
            ax{1} = 1:self.sz(1);
            ax{2} = 1:self.sz(2);
            ax{3} = 1:self.sz(3);
            [x,y,z] = ndgrid(ax{:});
            self.coord = [x(:)';y(:)';z(:)'];

        end
        %------------------------------------------------------------------
        function test_edges_inside_simple(self)
            img_range = [3,3,3;6,6,6];

            ref_dat = false(self.sz);
            ref_dat(2:7,2:7,2:7) = true;

            td = bin_inside(self.coord,self.sz,img_range,true);

            assertEqual(ref_dat,td);
        end
        
        function test_bin_inside_simple(self)
            img_range = [3,3,3;6,6,6];

            ref_dat = false(self.sz-1);
            ref_dat(2:6,2:6,2:6)= true;

            td = bin_inside(self.coord,self.sz,img_range);

            assertEqual(ref_dat,td);
        end
    end
end

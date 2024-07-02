classdef test_grid_volume < TestCase
    %
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_grid_volume(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_grid_volume';
            end
            self = self@TestCase(name);
        end
        
        %--------------------------------------------------------------------------
        function test_4D_cells_volume(~)
            xc = [1,2,4,8];
            [gridX,gridY,gridZ,gridE] = ndgrid(xc,xc,xc,xc);
            coord = [gridX(:),gridY(:),gridZ(:),gridE(:)]';
            vol = calc_bin_volume(coord,size(gridX));

            tVol3 = repmat([1,2,4].*[1,2,4]',1,1,3).*cat(3,ones(3),2*ones(3),4*ones(3));            
            tVol = repmat(tVol3,1,1,1,3).*cat(4,ones(3,3,3),2*ones(3,3,3),4*ones(3,3,3));
            assertEqual(vol,tVol(:)')
        end
        
        function test_3D_cells_volume(~)
            xc = [1,2,4,8];
            [gridX,gridY,gridZ] = ndgrid(xc,xc,xc);
            coord = [gridX(:),gridY(:),gridZ(:)]';
            vol = calc_bin_volume(coord,size(gridX));

            tVol = repmat([1,2,4].*[1,2,4]',1,1,3).*cat(3,ones(3),2*ones(3),4*ones(3));
            assertEqual(vol,tVol(:)')
        end
        
        function test_2D_cells_volume(~)
            xc = [1,2,4,8];
            [gridX,gridY] = ndgrid(xc,xc);
            coord = [gridX(:),gridY(:)]';
            vol = calc_bin_volume(coord,size(gridX));

            tVol = [1,2,4].*[1,2,4]';
            assertEqual(vol,tVol(:)')
        end
        
        function test_1D_cells_volume(~)
            xc = [1,2,4,8];
            vol = calc_bin_volume(xc,size(xc));
            assertEqual(vol,[1,2,4])
        end
    end
end

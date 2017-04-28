classdef aProjectionTester < aProjection
    %  class to test abstract class aProjection
    %
    % Also defines generic operations on sqw object, which may be useful
    % and can be used by any projection class.
    %
    % $Revision: 1462 $ ($Date: 2017-04-04 13:04:12 +0100 (Tue, 04 Apr 2017) $)
    %
    methods
        function proj=aProjectionTester(varargin)
            %
            proj = proj@aProjection(varargin{:});
        end
        %----------------------------------------------
        function  img_coord = pix_to_img(obj,pix_coord)
            img_coord = pix_coord;
        end
        function pix_coord = img_to_pix(obj,img_coord)
            pix_coord = img_coord;
        end
        
    end
end

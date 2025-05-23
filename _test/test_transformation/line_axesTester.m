classdef line_axesTester < line_axes
    % Used to test protected access_block methods
    
    methods
        function obj = line_axesTester(varargin)
            obj = obj@line_axes(varargin{:});
        end
        
        function [npix,s,e,pix_candidates,argi]= ...
                get_bin_inputs(obj,coord_transf,n_argout,varargin)
            
            [npix,s,e,pix_candidates,argi]=...
                obj.normalize_bin_input(coord_transf,n_argout,varargin{:});
        end
    end
end


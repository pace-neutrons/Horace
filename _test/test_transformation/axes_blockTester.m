classdef axes_blockTester < axes_block
    % Used to test protected access_block methods
    
    methods
        function obj = axes_blockTester(varargin)
            obj = obj@axes_block(varargin{:});
        end
        
        function [npix,s,e,pix_candidates,argi]= ...
                get_bin_inputs(obj,coord_transf,n_argout,varargin)
            
            [npix,s,e,pix_candidates,argi]=...
                obj.normalize_bin_input(coord_transf,n_argout,varargin{:});
        end
    end
end


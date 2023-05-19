classdef aProjectionTester < aProjectionBase
    %  Helper class to test non-abstract aProjectionBase methods
    %----------------------------------------------------------------------
    properties(Access=protected)
    end

    methods
        function [proj,extra_param]=aProjectionTester(varargin)
            proj = proj@aProjectionBase();
            if nargin>0
                [proj,extra_param]  = proj.init(varargin{:});
            else
                extra_param = {};
            end
        end
        %----------------------------------------------------------------------
        % EMPTY ABSTRACT INTERFACE DEFINED FOR TESTING
        %----------------------------------------------------------------------
        function urange = find_old_img_range(~,urange)
            % find the whole range of input data which may contribute
            % into the result.
        end
        function pix_cc = transform_pix_to_img(~,pix_cc,varargin)
            % Transform pixels expressed in crystal cartezian coordinate systems
            % into image coordinate system

        end
        function pix_cc = transform_img_to_pix(~,pix_cc,varargin)
            % Transform pixels expressed in image coordinate coordinate systems
            % into crystal cartezian system
        end
        %
        function [u_to_img,shift,ulen,obj]=get_pix_img_transformation(obj,ndim,varargin)
            u_to_img = eye(ndim);
            shift    = zeros(1,ndim);
            ulen     = ones(1,ndim);
        end


    end
    methods(Access = protected)
    end

    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = aProjectionTester();
            obj = loadobj@serializable(S,obj);
        end
    end
    %
    methods(Access = protected)
        %
        function isit= can_mex_cut_(~)
            isit = false;
        end
    end
end


classdef spher_proj<aProjection
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts
    %
    properties(Dependent)
        ez; %[1x3] Vector of Z axis in spherical coordinate system
        % where azimuthal angle phi is counted from (rlu). By default
        % directed along beam direction.
        ex; %[1x3] Vector of axis in spherical coordinate system
        %
        type;  % units of the projection. Default add -- angstrom, degree, degree
        %      % possible options: rrr where first r is responsible for rlu
        %      units and two other -- for radian e.g. 'rdr' or adr are
        %      allowed combinations of letters
        %
        ortho
    end
    properties(Access=private)
        %
        ez_ = [0,0,1]
        ex_ = [1,0,0]
        %
        type_ = 'add' % A, degree, degree
        %------------------------------------
        % For the future. See if we want 
        %orhtonormal_ = true;
    end

    methods
        function obj=spher_proj(varargin)
            obj = obj@aProjection();
            obj.label = {'\theta','\phi','\ro','En'};
            if nargin>0
                return;
            end

        end
        %
        function u = get.ex(obj)
            u = obj.ex_;
        end
        function v = get.ez(obj)
            v=obj.ez_;
        end
        %
        function type = get.type(obj)
            type = obj.type_;
        end
        function obj = set.type(obj,val)

        end

        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        %------------------------------------------------------------------
        %
        % Transform pixels expressed in crystal Cartesian or any source
        % coordinate systems defined by projection into image coordinate system
        [pix_transformed,varargout] = transform_pix_to_img(obj,pix_cc,varargin);
        % Transform pixels expressed in image coordinate coordinate systems
        % into crystal Cartesian system or other source coordinate system,
        % defined by projection
        [pix_cc,varargout] = transform_img_to_pix(obj,pix_transformed,varargin);

    end
end

classdef spher_proj<aProjection
    % Class defines spherical coordinate projection, used by cut_sqw
    % to make spherical cuts.
    %
    % TODO: #954 NEEDS verification:
    % The angular coordinates names and meanings are chosen according
    % to the conventions of inelastic spectrometry, i.e.:
    % |Q|     -- coordinate 1 is the module of the scattering momentum,
    % theta   -- coordinate 2, the angle between the beam direction (k_i)
    %            and the direction of the Q,
    % phi     -- coordinate 3 is the angle between the projection of the
    %            scattering vector to the instrument plain (perpendicular
    %            to k_i) and the crystal rotation plain.
    % dE      -- coordinate 4 the energy transfer direction
    %
    %
    properties(Dependent)
        ez; %[1x3] Unit vector of Z axis in spherical coordinate system
        % where the elevation angle (Matlab convention) is counted from.
        % In Horace/Mantid convention this angle is named pi/2-theta.
        % Default direction [0,0,1] is a beam direction for this coordinate system.
        %
        ey; %[1x3] unit vector of axis in spherical coordinate system
        % where the theta angle is counted from. The direction coincides
        % with the crystal rotation axis here.

        %
        type;  % units of the projection. Default add -- inverse Angstrom, degree, degree
        %      % possible options: rrr where first r is responsible for rlu
        %      units and two other -- for radian e.g. 'rdr' or adr are
        %      allowed combinations of letters
        %
    end
    properties(Access=private)
        %
        ez_ = [0,0,1]
        ey_ = [0,1,0]
        %
        type_ = 'add' % A^{-1}, degree, degree
        %------------------------------------
        % For the future. See if we want spherical projection in hkl,
        % non-orthogonal
        %orhtonormal_ = true;
        hor2matlab_transf_ = [0,0,1;1,0,0;0,1,0]; % The transformation from
        % Horace pixel coordinate system to the axes above to
        % allow to use Matlab sph2cart/cart2sph functions.
        pix_to_matlab_transf_ ; % the transformation used for conversion
        % from pix coordinate system to spherical coordinate system
        % if unit vectors are the default, it equal to hor2matlab_transf_.
        % If not, multiplied by rotation from default to the selected
        % coordinate system.
    end

    methods
        function obj=spher_proj(varargin)
            obj = obj@aProjection();
            obj.pix_to_matlab_transf_ = obj.hor2matlab_transf_;
            obj.label = {'\|Q\|','\theta','\phi','En'};

            obj = obj.init(varargin{:});
        end
        function obj = init(obj,varargin)
            % initialization routine taking any parameters non-default
            % constructor would take and initiating internal state of the
            % projection class.
            %
            if nargin == 1
                return
            end
            nargi = numel(varargin);
            if nargi== 1 && (isstruct(varargin{1})||isa(varargin{1},'aProjection'))
                if isstruct(varargin{1})
                    obj = serializable.loadobj(varargin{1});
                else
                    obj = obj.from_bare_struct(varargin{1});
                end
            else
                opt =  [ortho_proj.fields_to_save_(:);aProjection.init_params(:)];
                [obj,remains] = ...
                    set_positional_and_key_val_arguments(obj,...
                    opt,false,varargin{:});
                if ~isempty(remains)
                    error('HORACE:spher_proj:invalid_argument',...
                        'The parameters: "%s" provided as input to spher_proj initialization have not been recognized',...
                        disp2str(remains));
                end
            end
        end
        %
        function v = get.ez(obj)
            v=obj.ez_;
        end
        function obj = set.ez(obj,val)
            val = aProjection.check_and_brush3vector(val);
            obj.ez_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %
        function u = get.ey(obj)
            u = obj.ey_;
        end
        function obj = set.ey(obj,val)
            val = aProjection.check_and_brush3vector(val);
            obj.ey_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function type = get.type(obj)
            type = obj.type_;
        end
        function obj = set.type(obj,val)
            if ~(istext(val) && strlength(val) ~=3)
                error('HORACE:spher_proj:invalid_argument',...
                    'The type parameter has to be a text string with 3 elements. It is: "%s"',...
                    disp2str(val));
            end
            if ~strmp(val,'add')
                error('HORACE:spher_proj:not_implemented',...
                    'Spherical projection types differetn from "add" have not yet been implemented')
            end
            obj.type_ = val;
        end
        function [rot_to_img,offset]=get_pix_img_transformation(obj,ndim)
            rot_to_img = obj.pix_to_matlab_transf_;
            if ndim == 3
                offset   = obj.offset(1:3);
            elseif ndim == 4
                rot_to_img = [rot_to_img,[0;0;0];[0,0,0,1]];
                offset   = obj.offset;
            else
                error('HORACE:spher_proj:invalid_argument', ...
                    'ndims can only be 3 and 4. Provided: %s', ...
                    disp2str(ndim));
            end
        end
        %------------------------------------------------------------------
        % Particular implementation of aProjection abstract interface
        %------------------------------------------------------------------
        function ax_bl = get_proj_axes_block(obj,default_binning_ranges,req_binning_ranges)
            % return the axes block, corresponding to this projection class.
            ax_bl = get_proj_axes_block@aProjection(obj,default_binning_ranges,req_binning_ranges);
            %
            %ax_bl.ulen  = [1,1,1,1]; ??? Usage not yet clear
            % TODO, delete this, mutate axes_block
            axca = spher_proj_caption();
            axca.proj_type = obj.type;
            ax_bl.axis_caption=axca;
        end


        function pix_transformed = transform_pix_to_img(obj,pix_data,varargin)
            % Transform pixels expressed in crystal Cartesian coordinate systems
            % into spherical coordinate system defined by the object
            % properties
            %
            % Input:
            % pix_data -- [3xNpix] or [4xNpix] array of pix coordinates
            %             expressed in crystal Cartesian coordinate system
            %             or instance of PixelDatBase class containing this
            %             information.
            % Returns:
            % pix_out -- [3xNpix or [4xNpix]Array the pixels coordinates
            %            transformed into spherical coordinate system
            %            defined by object properties
            %
            pix_transformed = transform_pix_to_spher_(obj,pix_data);
        end
        function pix_cc = transform_img_to_pix(obj,pix_transformed,varargin)
            % Transform pixels in image (spherical) coordinate system
            % into crystal Cartesian system of pixels
            pix_cc = transform_spher_to_pix_(obj,pix_transformed,varargin{:});
        end

    end

    %=====================================================================
    % SERIALIZABLE INTERFACE
    %----------------------------------------------------------------------
    methods
        % check interdependent projection arguments
        function obj = check_combo_arg (obj)
            % Check validity of interdependent fields
            %
            %   >> obj = check_combo_arg(w)
            %
            % Throws HORACE:spher_proj:invalid_argument with the message
            % suggesting the reason for failure if the inputs are incorrect
            % w.r.t. each other.
            %
            % Normalizes input vectors to unity and constructs the
            % transformation to new coordinate system when operation is
            % successful
            %
            obj = check_combo_arg_(obj);
        end
        %------------------------------------------------------------------
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = saveableFields(obj)
            flds = saveableFields@aProjection(obj);
            flds = [flds(:);obj.fields_to_save_(:)];
        end
    end
    properties(Constant, Access=private)
        fields_to_save_ = {'ez','ey','type'}
    end
    methods(Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % savable class. Useful for recovering class from a structure
            obj = spher_proj();
            obj = loadobj@serializable(S,obj);
        end
    end
    methods(Access=protected)
    end
end

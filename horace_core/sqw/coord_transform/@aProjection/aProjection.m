classdef aProjection < serializable
    %  Abstract class, defining interface and common properties used for
    %  transforming pixels from crystal Cartesian
    %  to the coordinate system defined by sqw image (dnd-object)
    %  and vice-versa.
    %
    % Common (non-virtual) properties
    %  alatt       3-element vector, containing lattice parameters
    %  angdeg      3-element vector, containing lattice angles
    %
    %   offset     Row or column vector of offset of origin of a projection axes (rlu)
    %
    %   lab         Short labels for u1,u2,u3,u4 as cell array
    %               e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
    %                   *OR*
    %   lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
    %   lab2        Short label for u2 axis
    %   lab3        Short label for u3 axis
    %   lab4        Short label for u4 axis (e.g. 'E' or 'En')
    
    properties(Dependent)
        %---------------------------------
        % the lattice parameters
        alatt
        % angles between the lattice edges
        angdeg
        %---------------------------------
        %TODO: Will be refactored to axes_caption and transferred to axes
        %block?
        lab
        
        %Offset of origin of the projection in r.l.u. and energy ie. [h; k; l; en] [row vector]
        offset;
        %
        % the target projection, used by cut to transform from
        % source to target coordinate system
        targ_proj
    end
    properties(Dependent,Hidden)
        % property mainly used in testing. If set to true,
        % the class will always use generic projection transformation
        % instead of may be optimized transformation, specific for
        % particular projection-projection transformation, optimized for
        % specific projection-projection pair of classes
        do_generic;
    end
    
    properties(Constant, Access=private)
        fields_to_save_ = {'alatt','angdeg','lab','offset'}
    end
    properties(Constant, Access=protected)
        % minimal value of a vector norm e.g. how close couple of vectors
        % should be to be considered parallel u*v are orthogonal if u*v'<tol
        % or what vector should be consigdered a
        % null vector (e.g. abs([9.e-13,0,0,0]) will be converted to [0,0,0,0]
        % at setup
        tol_=1e-12;
    end
    %----------------------------------------------------------------------
    properties(Access=protected)
        alatt_=[1,1,1];
        angdeg_= [90,90,90];
        %------------------------------------
        %  u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
        offset_  = [0,0,0,0] %Offset of origin of projection axes in r.l.u. and energy ie. [h; k; l; en] [column vector]
        %
        labels_={'Q_h','Q_k','Q_l','En'};
        %
        % target projection holder
        targ_proj_;
        % if true, disable optimized transformation over specific parirs of
        % the projection types if such optimizaition is available
        do_generic_ = false;
    end
    
    methods
        function [obj,par]=aProjection(varargin)
            % aProjection constructor.
            %
            % Accepts any combination (including empty) of aProjection
            % class properties containing setters in the form:
            % {property_name1, value1, property_name2, value2....}
            %
            % Returns:
            %
            % obj  -- Instance of aProjection class
            % par  -- if input arguments contains key-value pairs, which do
            %         not describe aProjection class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projecton parameters.
            if nargin == 0
                par = {};
                return;
            end
            [obj,par] = init(obj,varargin{:});
        end
        function [obj,par] = init(obj,varargin)
            % Method to initialize empty constructor
            % Inputs:
            % A combination (including empty) of aProjection
            % class properties containing setters in the form:
            % {property_name1, value1, property_name2, value2....}
            % Returns:
            % obj  -- Initialized instance of aProjection class
            % par  -- if input arguments contains key-value pairs, which do
            %         not describe aProjection class, the output contains
            %         cellarray of such parameters. Empty, if all inputs
            %         define the projecton parameters.
            %
            [obj,par] = init_(obj,varargin{:});
        end
        
        %------------------------------------------------------------------
        %
        %------------------------------------------------------------------
        function [npix,s,e,pix_ok,pix_indx] = bin_pixels(obj,axes,pix_candidates,npix,s,e,varargin)
            % Convert pixels into the coordinate system, defined by the
            % projection and bin them into the coordinate system, defined
            % by the axes block, specified as input.
            %
            % Inputs:
            % axes -- the instance of axes_block class, defining the
            %         shape and the binning of the target coodinate system
            % pix_candidates -- the 4xNpix array of pixel coordinates or
            %         PixelData object or pixel data accessor from file
            %         providing access to the full pixel information
            % Optional:
            % npix    -- the array, containing the numbers of pixels
            %            contributing into each axes grid cell
            % s       -- array, containing the accumulated signal for each
            %            axes grid cell
            % e       -- aray, containing the accumulated error for each
            %            axes grid cell
            % Outputs:
            %  The same npix, s, e arrays as inputs modified with added
            %  information from pix_candidates if npix, s, e arrays were
            %  present or axes class - shaped arrays of this information
            %  if there were no inputs.
            % Optional:
            % pix_ok -- the pixel coordinate array or
            %           PixelData object (as input pix_candidates) containing
            %           pixels contributing to the grid and sorted according
            %           to the axes block grid.
            % pix_indx--indexes of the pix_ok coordinates according to the
            %           bin
            pix_transformed = obj.transform_pix_to_img(pix_candidates);
            if nargout == 5
                [npix,s,e,pix_ok,pix_indx]=...
                    axes.bin_pixels(pix_transformed,...
                    npix,s,e,pix_candidates,varargin{:});
            elseif nargout == 4
                [npix,s,e,pix_ok]=axes.bin_pixels(pix_transformed,...
                    npix,s,e,pix_candidates,varargin{:});
            elseif nargout == 3
                [npix,s,e]=axes.bin_pixels(pix_transformed,...
                    npix,s,e,pix_candidates,varargin{:});
            elseif nargout ==1
                npix=axes.bin_pixels(pix_transformed,...
                    npix,varargin{:});
            else
                error('HORACE:aProjection:invalid_argument',...
                    'This function requests 1,3 or 4 output arguments');
            end
        end
        %
        function [bl_start,bl_size] = get_nrange(obj,npix,cur_axes_block,...
                targ_axes_block,targ_proj)
            % return the the positions and the sizes of the pixels blocks
            % belonging to the cells, which may contribute to the final cut defined by the
            % projections and axes_block-s, provided as input.
            %
            % Generic (less efficient) implementation
            if ~exist('targ_proj','var')
                targ_proj = [];
            end
            [bl_start,bl_size] = get_nrange_(obj,...
                npix,cur_axes_block,targ_proj,targ_axes_block);
            
        end
        %------------------------------------------------------------------
        function pix_target = from_cur_to_targ_coord(obj,pix_origin,varargin)
            % Converts from current to target projection coordinate system.
            %
            % Should be overloaded to optimize for a particular case to
            % improve efficiency.
            % (e.g. two orthogonal projections do shift and rotation
            % as the result, so worth combining them into one operation)
            % Inputs:
            % obj       -- current projection, describing the system of
            %              coordinates where the input pixels vector is
            %              expressed in. The target projection has to be
            %              set up
            %
            % pix_origin   4xNpix vector of pixels coordinates expressed in
            %              the coordinate system, defined by current
            %              projection
            targproj = obj.targ_proj;
            if isempty(targproj)
                error('HORACE:aProjection:runtime_error',...
                    'Target projection property has to be set up to convert to target coordinate system')
            end
            pic_cc = obj.transform_img_to_pix(pix_origin,varargin{:});
            pix_target  = targproj.transform_pix_to_img(pic_cc,varargin{:});
        end
        %------------------------------------------------------------------
        % accessors
        %------------------------------------------------------------------
        function alat = get.alatt(obj)
            alat = obj.alatt_;
        end
        function obj = set.alatt(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % parameters or vector of 3 different lattice parameters
            %
            % The parameters expected to be in A
            %
            obj = check_and_set_alatt(obj,val);
        end
        %
        function angl = get.angdeg(obj)
            angl = obj.angdeg_;
        end
        function obj = set.angdeg(obj,val)
            % set lattice parameters as single value, defining 3 equal
            % lattice angles or vector of 3 different lattice angles
            %
            % All angles are in degrees.
            %
            obj = check_and_set_andgdeg(obj,val);
        end
        %
        function lab=get.lab(obj)
            lab = obj.labels_;
        end
        function obj=set.lab(obj,val)
            obj = check_and_set_labels_(obj,val);
        end
        %
        function uoffset = get.offset(this)
            uoffset = this.offset_;
        end
        function obj = set.offset(obj,val)
            obj = check_and_set_offset_(obj,val);
        end
        %------------------------------------------------------------------
        function proj = get.targ_proj(obj)
            proj = obj.targ_proj_;
        end
        %
        function obj = set.targ_proj(obj,val)
            obj = obj.check_and_set_targ_proj(val);
        end
        function gen = get.do_generic(obj)
            gen = obj.do_generic_;
        end
        function obj = set.do_generic(obj,val)
            obj = obj.check_and_set_do_generic(val);
        end
        
        %------------------------------------------------------------------
        % Serializable interface
        function ver  = classVersion(~)
            ver = 1;
        end
        function  flds = indepFields(obj)
            flds = obj.fields_to_save_;
        end
    end
    %
    methods(Access = protected)
        function obj = check_and_set_alatt(obj,val)
            obj.alatt_ = check_alatt_return_standard_val_(obj,val);
        end
        function obj = check_and_set_andgdeg(obj,val)
            obj.angdeg_ = check_angdeg_return_standard_val_(obj,val);
        end
        %
        function obj = check_and_set_targ_proj(obj,val)
            % generic overloadable setter for target proj.
            %
            % made protected to allow overloading for special
            % types of projection optimization
            if ~isa(val,'aProjection')
                error('HORACE:aProjection:invalid_argument',...
                    'only member of aProjection family can be set up as target projection. Attempted to use: %s',...
                    evalc('disp(type(val))'))
            end
            obj.targ_proj_ = val;
        end
        function obj = check_and_set_do_generic(obj,val)
            % setter for do_generic method
            if ~((islogical(val) || isnumeric(val)) && numel(val)==1)
                error('HORACE:aProjection:invalid_argument',...
                    'you may set do_generic property into true or false state only');
            end
            obj.do_generic_ = logical(val);
        end
    end
    %----------------------------------------------------------------------
    %  ABSTRACT INTERFACE
    %----------------------------------------------------------------------
    methods(Abstract)
        % Transform pixels expressed in crystal cartezian coordinate systems
        % into image coordinate system
        pix_transformed = transform_pix_to_img(obj,pix_cc,varargin);
        % Transform pixels expressed in image coordinate coordinate systems
        % into crystal cartezian system
        pix_cc = transform_img_to_pix(obj,pix_transformed,varargin);
        
    end
    
end

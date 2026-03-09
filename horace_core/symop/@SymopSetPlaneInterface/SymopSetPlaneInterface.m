classdef SymopSetPlaneInterface < Symop
    %SYMOPSETPLANEINTERFACE Helper class used to initialize reflection
    %plane in case of SymopReflection or RotationPlane in case of
    %SymopRotation

    properties(Dependent)
        u; % first vector lying in and defining reflection plane
        v; % second vector lying in and defining reflection plane
        normvec; % unit vector in CC system, orthogonal to the reflection
        %          plane. Input normvector defines it but does not equal to
        %          it, as input may be expressed in rlu
    end
    properties(Dependent,Hidden)
        input_nrmv_in_rlu; % boolean variable which defines units of input
        %       normvec.  The property affects only case when you set up
        %       reflection plane by providing its normvec. Normally
        %       the vector is treated as the vector defined in Crystal
        %       Cartesian coordinate system, which does not matter for
        %       orthogonal lattice. For non-orthogonal lattice this value
        %       have to be defined as true of false, which defines the way,
        %       normvector have to be treated when B-matrix becomes
        %       available
    end
    properties(Access=protected)
        u_ = [1;0;0];
        v_ = [0;1;0];
        normvec_ = [0;0;1];
        input_nrmv_in_rlu_;  %
        set_from_normvec_ = false % true if the reflection plane is set
        % by defining the normal vector to the plane.
    end

    methods
        function is = get.input_nrmv_in_rlu(obj)
            if isempty(obj.input_nrmv_in_rlu_)
                is  = true;
            else
                is = obj.input_nrmv_in_rlu_;
            end
        end
        function obj= set.input_nrmv_in_rlu(obj,val)
            if ~obj.set_from_normvec_
                return;
            end
            obj = obj.set_input_nrmv_in_rlu(val);
        end

        function u = get.u(obj)
            u = obj.u_;
        end
        function obj = set.u(obj, val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:SymopSetPlaneIntrerface:invalid_argument', ...
                    'Reflection vector u must be a three vector');
            end
            obj.set_from_normvec_ = false;
            obj.u_ = val(:);    % make col vector
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function v = get.v(obj)
            v = obj.v_;
        end
        function obj = set.v(obj, val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:SymopSetPlaneIntrerface:invalid_argument', ...
                    'Reflection vector v must be a three vector');
            end
            obj.set_from_normvec_ = false;
            obj.v_ = val(:);    % make col vector
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function normvec = get.normvec(obj)
            % method always returns normvec in Crystal Cartesian as this is
            % the system of coordinates, all calculations are performed in.
            normvec = obj.normvec_;
        end
        function obj = set.normvec(obj,val)
            [is,val] = obj.check_and_brush_3vector(val);
            if  ~is
                error('HORACE:SymopSetPlaneIntrerface:invalid_argument', ...
                    'plane-normal vector normvec must be a three-elements vector');
            end
            obj.set_from_normvec_ = true;
            obj.normvec_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
    end
    %----------------------------------------------------------------------
    methods(Static,Access=protected)
        function [argi,input_nrmv_in_rlu] = check_and_sanitize_coord(varargin)
            % check if option cc or rlu, which defines coordinate system
            % used for input normvector is provided and extract its value
            % if it indeed provided

            % Inputs:
            % varargin  -- inputs, used by Rotation or Reflection
            %
            % Returns:
            % argi      -- varargin with 'cc' or 'rlu' stripped-off the
            %              vararin if found
            % input_nrmv_in_rlu
            %           -- logical containin true if varargin contains
            %           'rlu', false if 'cc' and empty if not found.
            is_coord_def = cellfun(@(prop)(istext(prop)&&ismember(prop,{'cc','rlu'})),varargin);
            def_at = find(is_coord_def);
            input_nrmv_in_rlu = [];
            if isempty(def_at)
                argi = varargin;
            else
                argi = varargin(~is_coord_def);
                input_nrmv_in_rlu = strcmp(varargin{def_at},'rlu');
            end
        end
        
        function  [u,v,normvec,normvec_in_rlu] = get_uv_from_normvec(normvec,normvec_in_rlu,bmat)
            %SET_UV_FROM_NORMVEC Given normvec to a plane, and assuming that
            % main part (the longest component) of this vector is parallel
            % to z-axis of some coordinate system, identify this coordinate
            % system and return u,v vectors of this system, which belong to
            % a plane, orthogonal to this vector.
            %
            % This is unambiguous operation in orthogonal system, but for
            % non-orthogonal coordinate system may return unexpected
            % results, so it is better to use u,v to define plane in
            % non-orthogonal system.
            %
            % Inputs:
            % normvec         -- normal vector used to identify plane of
            %                    interest
            % normvec_in_rlu  -- boolean set to true if input vector is
            %                    expressed in rlu
            % bmat            -- b-matrix used for conversion from rlu to
            %                    Crystal Cartesian coordinate system
            %
            % Returns:
            % u               -- first vector located in plane of interest,
            %                    orthogonal to normvect
            % v               -- second vector located in plane of
            %                    interest, orthogonal to normvect.
            % normvec         -- unit vector in CC coordinate system
            %                    defined by input normvect but normalized
            %                    so that its CC projection has unit length.
            %                    if "normvec_in_rlu" is true, this vector
            %                    is converted to rlu.

            [u,v,normvec,normvec_in_rlu] = get_uv_from_normvec_(normvec,normvec_in_rlu,bmat);
        end
    end

    methods
        function obj = check_combo_arg(obj,input_in_rlu)
            if nargin>1
                obj.input_nrmv_in_rlu_ = input_in_rlu;
            end
            obj = check_and_caclulate_vectors_and_R_(obj);
            obj = obj.check_offset_b_matrix_consistency();
        end
    end
    
    methods(Access = protected)        
        function obj = set_input_nrmv_in_rlu(obj,val)
            % main part of the nrmv_in_rlu setter used by reflection and
            % rotation.
            %
            % If you set up operation using normvector, changning this
            % parameter also changes normvector units between rlu and cc
            %
            if istext(val)
                is_rlu = ismember({'rlu','cc'},val);
                if all(~is_rlu)
                    error('HORACE:SymopSetPlaneIntrerface:invalid_argument', ...
                        ['you can set up "input_nrmv_in_rlu" using "rlu" or "cc" strings or true|false values\n' ...
                        'provided: %s'],disp2str(val));
                end
                input_is_rlu = is_rlu(1);
            else
                input_is_rlu = logical(val);
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(input_is_rlu);
            end
        end

        function   obj = set_R(obj,varargin)
            error('HORACE:SymopSetPlaneIntrerface:invalid_argument',[ ...
                'You can not set up rotation matrix directly.\n' ...
                'Use SymopGeneral or input properties of SymopRotation class'])
        end
    end
end
classdef IX_detector_bank < serializable
    % IX_detector_bank    Defines a detector bank for detectors of one type
    % The object contains detector positional information and the detector
    % information for a detector bank of a single detector type (for example an
    % array of 3He tubes, or an array of slab deteectors).
    
    properties (Access=private)
        % Detector identifiers, integers greater than 0 (column vector)
        id_  = 1;
        % Sample-detector distance (m) (column vector)
        x2_  = 0;
        % Scattering angle (degrees, in range 0 to 180) (column vector)
        phi_ = 0;
        % Azimuthal angle (degrees) (column vector)
        azim_= 0;
        % Detector orientation matrix [3,3,ndet]
        dmat_= eye(3);
        % Scalar object of IX_det_abstractType
        det_ = IX_det_slab;
    end
    
    properties (Dependent)
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        % Detector identifiers, integers greater than 0 (column vector)
        id
        % Sample-detector distance (m) (column vector)
        x2
        % Scattering angle (degrees, in range 0 to 180) (column vector)
        phi
        % Azimuthal angle (degrees) (column vector)
        % The sense of rotation is that sitting on the beamstop and looking
        % at the sample, azim = 0 is to the east i.e. to the right, 
        % azim = 90 is north i.e. vertically up etc.
        azim
        % Detector orientation matrix (size [3,3,ndet])
        % The matrix gives components in the secondary spectrometer coordinate
        % frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Detector rotation vectors (size [3,ndet])
        % The detector frame is obtained by rotation according to the vector
        % which has components in the secondary spectrometer coordinate frame.
        % This is an alternative representation of the information in dmat
        rotvec
        % Detector array object (scalar instance of IX_det_abstractType)
        % Information about an array of detector elements of the same type e.g.
        % IX_det_He3tube. The detector type inherits from IX_det_abstractType 
        det

        % Other dependent properties:
        % ---------------------------
        % Number of detectors (get access only) (scalar)
        ndet
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = IX_detector_bank (varargin)
            % Construct a detector bank
            %
            %   >> obj = IX_detector_bank (id, x2, phi, azim, det)
            %
            %   >> obj = IX_detector_bank (..., 'rotvec', V)
            % *OR*
            %   >> obj = IX_detector_bank (..., 'dmat', D)
            %
            % Input:
            % ------
            % Required:
            %   id          Array of detector identifiers (integer values)
            %   x2          Sample - detector distances
            %   phi         Scattering angles (degrees) (in range 0 - 180 degrees)
            %   azim        Azimuthal angles (degrees)
            %   det         Properties for a detector or array of detectors.
            %               An instance of a class such as IX_det_He3tube
            %              or IX_det_slab that inherits IX_det_abstractType
            %
            % Optional arguments:
            %
            % The detector orientation can be defined using one and only one
            % of the following:
            %
            %   'rotvec',V  Rotation vector(s) that gives the orientation
            %              of the detector coordinate frame(s) with respect
            %               to the secondary spectrometer frame.
            %               Vector length 3 or array size [3,ndet] (degrees)
            %               The detector frame is obtained by rotation according
            %              to the vector which has components in the secondary
            %              spectrometer coordinate frame given by V.
            %
            %   'dmat',D    Rotation matrix that returns the components of
            %              a vector in the secondary spectrometer coordinate
            %              frame given those in the detector coordinate frame:
            %                       xf(i) = Sum_j [D(i,j) xdet(j)]
            %               Array size [3,3] or [3,3,ndet]
            %
            % The default if neither is given is that the detector coordinate
            % frame is the same as the secondary spectrometer coordinate
            % frame i.e. the default is: 'dmat',eye(3)
            
            if nargin>0
                % Define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                property_names = {'id', 'x2', 'phi', 'azim', 'det' 'dmat', 'rotvec'};
                mandatory = [true, true, true, true, true, false, false];
                
                % Set positional parameters and key-value pairs and check their
                % consistency using public setters interface. Run
                % check_combo_arg after all settings have been done.
                % All is done within set_positional_and_key_val_arguments
                options = struct('key_dash', true, 'mandatory_props', mandatory);
                [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                    property_names, options, varargin{:});
                
                if ~isempty(remains)
                    error('HERBERT:IX_det_He3tube:invalid_argument', ...
                        ['Unrecognised extra parameters provided as input to ',...
                        'IX_det_He3tube constructor:\n %s'], disp2str(remains));
                end
            end

        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj = set.id (obj, val)
            [ok, mess] = is_integer_id (val);   % this also checks numel(val)>=1
            if ~ok
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Detector ', mess])
            end
            obj.id_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.x2 (obj, val)
            if any(val(:)<0)
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'Sample - detector distance(s) must be greater or equal to zero')
            end
            obj.x2_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.phi (obj, val)
            if any(val(:)<0) || any(val(:)>180)
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Scattering angle(s) must lie in the range 0 inclusive ',...
                    'to 180 degrees exclusive'])
            end
            obj.phi_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.azim (obj, val)
            if ~isnumeric(val)
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'Azimuthal angle(s) must be numeric')
            end
            obj.azim_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.dmat (obj, val)
            [~, obj.dmat_] = det_orient_trans (val, 'dmat');
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.rotvec (obj, val)
            [~, obj.dmat_] = det_orient_trans (val, 'rotvec', 'dmat');
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        function obj = set.det (obj, val)
            if ~isa(val,'IX_det_abstractType') || ~isscalar(val)
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'Detector type must be a single IX_det_abstractType object')
            end
            obj.det_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.id(obj)
            val = obj.id_;
        end
        
        function val = get.x2(obj)
            val = obj.x2_;
        end
        
        function val = get.phi(obj)
            val = obj.phi_;
        end
        
        function val = get.azim(obj)
            val = obj.azim_;
        end
        
        function val = get.dmat(obj)
            val = obj.dmat_;
        end
        
        function val = get.rotvec(obj)
            val = rotmat_to_rotvec (permute (obj.dmat_, [2,1,3]));
        end
        
        function val = get.det(obj)
            val = obj.det_;
        end
        
        function val = get.ndet(obj)
            val = obj.det_.ndet;
        end
        
        %------------------------------------------------------------------
        
    end
    
    %======================================================================
    % SERIALIZABLE INTERFACE
    %======================================================================
    
    methods
        function ver = classVersion(~)
            % Current version of class definition
            ver = 1;
        end
        
        function flds = saveableFields(~)
            % Return cellarray of properties defining the class
            flds = {'id', 'x2', 'phi', 'azim', 'dmat', 'det'};
        end

        function obj = check_combo_arg(obj)
            % Verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check.
            %
            % Recompute any cached arguments.
            %
            % Throw an error if the properties are inconsistent and return
            % without problem it they are not.

            nd = numel(obj.id_);  % indices are unique, so this defines ndet

            try
                [obj.x2_, obj.phi_, obj.azim_] = expand_args_by_ref (obj.id_, obj.x2_, obj.phi_, obj.azim_);
            catch
                error ('HERBERT:IX_detector_bank:invalid_argument',...
                    ['One or more of the sample-detector distance ''x2'' and ',...
                    'scattering angles ''phi'' and ''azim'' are non-scalar or ',...
                    'arrays with length different to the number of detector indices'])
            end
            
            if size(obj.dmat_,3)==1 && nd>1
                obj.dmat_ = repmat(obj.dmat_, [1,1,nd]);
            elseif size(obj.dmat_,3)~=nd
                error ('HERBERT:IX_detector_bank:invalid_argument',...
                    ['The number of detector orientations must be unity or ',...
                    'match the number of detector identifiers'])
            end
            
            if obj.det_.ndet==1 && nd>1
                obj.det_ = obj.det_.replicate(nd);
            elseif obj.det_.ndet~=nd
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['The number of detectors must be unity or match the ',...
                    'number of detector identifiers'])
            end
        end
        
    end
    
    %----------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = IX_detector_bank();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end

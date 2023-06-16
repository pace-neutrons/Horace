classdef IX_detector_bank < serializable
    % Defines a detector bank for detectors of one type, for example, helium
    % tubes, or slab detectors. The object contains detector positional
    % information and the detector information for a detector bank of a single
    % detector type.
    
    properties (Access=private)
        % Class version number
        class_version_ = 1;
        % Detector identifiers, integers greater than 0 (column vector)
        id_  = zeros(0,1);
        % Sample-detector distance (m) (column vector)
        x2_  = zeros(0,1);
        % Scattering angle (degrees, in range 0 to 180) (column vector)
        phi_ = zeros(0,1);
        % Azimuthal angle (degrees) (column vector)
        azim_= zeros(0,1);
        % Detector orientation matrix [3,3,ndet]
        dmat_= zeros(3,3,0);
        % Scalar object of IX_det_abstractType 
        det_ = repmat(IX_det_slab,[1,0]);
    end
    
    properties (Dependent)
        % Detector identifiers, integers greater than 0 (column vector)
        id
        % Sample-detector distance (m) (column vector)
        x2
        % Scattering angle (degrees, in range 0 to 180) (column vector)
        phi
        % Azimuthal angle (degrees) (column vector)
        % The sense of rotation is that sitting on the beamstop and looking at the
        % sample, azim = 0 is east, azim = 90 is north
        azim
        % Detector orientation matrix [3,3,ndet]
        % The matrix gives components in the secondary spectrometer coordinate
        % frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Detector objects (column vector)
        % Each element of the array gives the detector information. The class
        % inherits from IX_det_abstractType e.g. IX_det_He3tube
        det
        % Number of detectors (get access only):
        ndet
        % Combined - all the above in one field
        % Bypasses the expand_args_by_ref of the individual sets
        combined
    end
    
    properties(Constant, Access=private)
        fields_to_save_ = {'combined'};
    end
    
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = IX_detector_bank (id, x2, phi, azim, det, varargin)
            % Construct a detector bank
            %
            %   >> obj = IX_detector_bank (id, x2, phi, azim, det)
            %
            %   >> obj = IX_detector_bank (..., 'rotvec', V)
            % *OR*
            %   >> obj = IX_detector_bank (..., 'dmat, D)
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
            
            if nargin==0, return, end   % Default single detector
            
            % Parse detector orientation. Must have one and just one of the keyval
            % present, and no other parameters
            if numel(varargin)==0
                dmat = eye(3);
                ndet0 = 1;
            else
                types = det_orient_trans();
                type_in = varargin{1};
                if numel(varargin)==2 && is_string(type_in) && ~isempty(type_in)
                    iout = stringmatchi(varargin{1},types);
                    if isscalar(iout)
                        [ok, mess, ndet0, dmat] = det_orient_trans (varargin{2},...
                            types{iout}, 'dmat');
                        if ~ok
                            error('HERBERT:IX_detector_bank:invalid_argument',...
                                mess);
                        end
                    else
                        error('HERBERT:IX_detector_bank:invalid_argument',...
                            'Unrecognised or ambiguous orientation type')
                    end
                else
                    error('HERBERT:IX_detector_bank:invalid_argument',...
                        'Must supply one and only one detector orientation description')
                end
            end
            
            % Check detector identifiers
            [ok, mess, ix] = is_integer_id (id);
            if ok
                ndet = numel(id);
                if ndet>=1
                    obj.id_ = id(:);
                else
                    error('HERBERT:IX_detector_bank:invalid_argument',...
                        'There must be at least one detector identifier')
                end
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Detector ',mess])
            end
            
            % Check position coordinates
            [x2_exp, phi_exp, azim_exp] = expand_args_by_ref (id, x2, phi, azim);
            obj.x2_   = x2_exp;
            obj.phi_  = phi_exp;
            obj.azim_ = azim_exp;
            
            % Check detector orientation
            if ndet==ndet0
                if ~isempty(ix)
                    obj.dmat_ = dmat(:,:,ix);
                else
                    obj.dmat_ = dmat;
                end
            elseif ndet0==1 % must have ndet>1, as scalar case already caught
                obj.dmat_ = repmat(dmat,[1,1,ndet]);
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['The number of detector orientations must be unity or ',...
                    'match the number of detector identifiers'])
            end
            
            % Check detector parameters
            obj.det_ = det;     % this assignment will check correct class of det
            if det.ndet==ndet
                if ~isempty(ix)
                    obj.det_  = obj.det_.reorder(ix);
                end
            elseif det.ndet==1  % must have ndet>1, as scalar case already caught
                obj.det_ = obj.det_.replicate(ndet);
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['The number of detectors must be unity or match the ',...
                    'number of detector identifiers'])
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods
        %
        % Test the validity where there is no dependency on other private properties
        
        function obj = set.id_(obj,val)
            % Will have put val through checks before reaching here, either in the
            % constructor or the setting of dependent property id
            obj.id_ = val;
        end
        
        function obj = set.x2_(obj,val)
            if isempty(val)
                % keeps shape of val as shape of empty val(:) is different
                obj.x2_ = val;
                return;
            end
            if all(val(:) >= 0)
                obj.x2_ = val(:);
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'Sample - detector distance(s) must be greater or equal to zero')
            end
        end
        
        function obj = set.phi_(obj,val)
            if isempty(val)
                % keeps shape of val as shape of empty val(:) is different
                obj.phi_ = val;
                return;
            end
            if all(val(:) >= 0) && all(val(:)<180)
                obj.phi_ = val(:);
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    ['Scattering angle(s) must lie in the range 0 inclusive ',...
                    'to 180 degrees exclusive'])
            end
        end
        
        function obj = set.azim_(obj,val)
            if isempty(val)
                % keeps shape of val as shape of empty val(:) is different
                obj.azim_ = val;
                return;
            end
            obj.azim_ = val(:);
        end
        
        function obj = set.dmat_(obj,val)
            % Will have put val through checks before reaching here, either in the
            % constructor or the setting of dependent property id
            obj.dmat_ = val;
        end
        
        function obj = set.det_(obj,val)
            if isa(val,'IX_det_abstractType') && isscalar(val)
                obj.det_ = val;
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'Detector type must be a single IX_det_abstractType object')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % Checks that rely on interdependencies must go here
        
        function val = get.combined(obj)
            val = struct();
            val.id = obj.id_;
            val.x2 = obj.x2_;
            val.phi = obj.phi_;
            val.azim = obj.azim_;
            val.dmat = obj.dmat_;
            val.det = obj.det_;
        end
        
        function obj = set.combined(obj,val)
            obj.id_ = val.id;
            obj.x2_ = val.x2;
            obj.phi_ = val.phi;
            obj.azim_ = val.azim;
            obj.dmat_ = val.dmat;
            obj.det_ = val.det;
        end
        
        function obj = set.id (obj,val)
            if numel(val)==numel(obj.id_)
                [ok,mess,ix] = is_integer_id(val);
                if ok
                    obj.id_ = val(:);
                    if ~isempty(ix)
                        obj.x2_   = x2_exp(ix);
                        obj.phi_  = phi_exp(ix);
                        obj.azim_ = azim_exp(ix);
                        obj.dmat_ = obj.dmat_(:,:,ix);
                        obj.det_  = obj.det_.reorder(ix);
                    end
                else
                    error('HERBERT:IX_detector_bank:invalid_argument',...
                        ['Detector ',mess])
                end
            else
                error('HERBERT:IX_detector_bank:invalid_argument',...
                    'The number of detector identifiers must match the current number')
            end
        end
        
        function obj=set.x2(obj,val)
            obj.x2_ = expand_args_by_ref (obj.x2_, val);
        end
        
        function obj=set.phi(obj,val)
            obj.phi_ = expand_args_by_ref (obj.phi_, val);
        end
        
        function obj=set.azim(obj,val)
            obj.azim_ = expand_args_by_ref (obj.azim_, val);
        end
        
        function obj=set.dmat(obj,val)
            [ok,mess,ndet0] = det_orient_trans (val, 'dmat');
            if ~ok, error(mess), end
            
            if ok
                if obj.ndet == ndet0
                    obj.dmat_ = val;
                elseif ndet0==1
                    obj.dmat_ = repmat(val,[1,1,obj.ndet]);
                else
                    error('HERBERT:IX_detector_bank:invalid_argument',...
                        ['The number of detector orientations must be scalar ',...
                        'or match the number of detector identifiers'])
                end
            else
                error(mess)
            end
        end
        
        function obj=set.det(obj,val)
            obj.det_ = val;     % checks correct type
            if val.ndet~=obj.ndet
                if val.ndet==1
                    obj.det_ = val.replicate(obj.ndet);
                else
                    error('HERBERT:IX_detector_bank:invalid_argument',...
                        ['The number of detectors must match be unity or ',...
                        'equal the number of detector identifiers'])
                end
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
            % Define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        
        function flds = saveableFields(~)
            % Get independent fields, which fully define the state of the
            % serializable object.
            flds = IX_detector_bank.fields_to_save_;
        end
    end
    
    %----------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = IX_detector_bank();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end

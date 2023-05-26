classdef IX_detector_bank < serializable
    % Defines a detector bank for detectors of one type, for example, helium
    % tubes, or slab detectors. The object contains detector positional
    % information and the detector information for a detector bank of a single
    % detector type. 
    
    properties (Access=private)
        class_version_ = 1; % Class version number
        id_  = []        % Detector identifiers, integers greater than 0 (column vector, in ascending order)
        x2_  = []        % Sample-detector distance (m) (column vector)
        phi_ = []        % Scattering angle (degrees, in range 0 to 180) (column vector)
        azim_= []        % Azimuthal angle (degrees) (column vector)
        dmat_= eye(3);  % Detector orientation matrix [3,3,ndet]
        det_ = IX_det_slab     % scalar object of IX_det_abstractType
    end
    
    properties (Dependent)
        % Detector identifiers, integers greater than 0 (column vector, in ascending order)
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
        
        % combined - all the above in one field
        % bypasses the expand_args_by_ref of the individual sets
        combined
    end

    properties(Constant,Access=private)
        % fields_to_save_ = {'id','x2','phi','azim', 'dmat', 'det', 'ndet'};
        fields_to_save_ = {'combined'};
    end
    


    methods
        %------------------------------------------------------------------
        % Constructor
        function obj = IX_detector_bank (id, x2, phi, azim, det, varargin)
            % Construct a detector bank
            %
            %   >> obj = IX_detector_bank (id, x2, phi, azim, detector_type)
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
            %   det         Object (or array of objects, one per detector) of a
            %              class that inherits IX_det_abstractType e.g. IX_det_He3tube
            %
            % Optional arguments defining detector orientations:
            %
            %   One and only one of the follow can be given. The default if none is
            %   The default if none is given is that the detector coordinate frame is
            %  the same as the secondary spectrometer coordinate frame i.e. the default
            %  is: 'dmat',eye(3)
            %
            %   'rotvec',V  Rotation vector(s) that gives the orientation of the detector
            %              coordinate frame(s) with respect to the secondary spectrometer
            %              frame.
            %               Vector length 3 or array size [3,ndet] (degrees).
            %               The detector frame is obtained by rotation according to the vector
            %              which has components in the secondary frame given by V
            %
            %   'dmat',D    Rotation matrix that gives components in secondary spectrometer
            %              coordinate frame given those in the detector coordinate frame:
            %                       xf(i) = Sum_j [D(i,j) xdet(j)]
            %               Array size [3,3] or [3,3,ndet]
            
            
            obj = obj@serializable();
            
            % Default single detector
            if nargin==0
                return
            end   
            
            % Parse detector orientation. Must have one and just one of the keyval
            % present, and no other parameters
            if numel(varargin)==0
                dmat = eye(3);
                ndet0 = 1;
            elseif numel(varargin)~=2
                error('HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                      'must be 2 or 0 optional arguments to describe orientation type and value');
            else
                types = {'dmat','rotvec'}; % unpack this from det_orient_trans(); for ease of reading
                if ~isempty(varargin{1}) && is_string(varargin{1})
                    iout = stringmatchi(varargin{1},types);
                    if ~isempty(iout) % varargin{1} is in types
                        % convert varargin{2} to dmat, either unchanged if
                        % already dmat, or converted from rotvec to dmat.
                        % also extract no. detectors as per dmat
                        [ok,mess,ndet0,dmat] = det_orient_trans (varargin{2}, types{iout}, 'dmat');
                        if ~ok
                            error( ...
                             'HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                             mess); 
                        end
                    else
                        error(HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                          'Unrecognised or ambiguous orientation type')
                    end
                else
                    error('HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                          'first optional argument must be a non-empty char/string');
                end
            end
            % dmat is now a 'dmat' type i.e. with size [3,3,ndet0]
            
            % Check detector identifiers, 
            % and return id converted to column vector, sorted. Return ok==false if ids are
            % empty, not unique, or not positive integer.
            %
            [ok,mess,ix] = is_integer_id_nosort(id);
            if ~ok
                error('HERBERT:IX_detector_bank_constructor:invalid_argument',mess);
            end
            
            % set no. detectors as per id
            ndet = numel(id);
            
            % Expand position coordinates to vectors if input as scalars
            % (i.e. constant over all vectors) and columnize from the shape
            % of id, which is now columnized
            [x2_exp, phi_exp, azim_exp] = expand_args_by_ref (id, x2, phi, azim);
            
            % Set object properties from argument expansion
            % Note that it is now assumed that x2/phi/azim are not empty
            obj.id_   = id; % already sorted if need be in is_integer_id
            if isempty(ix)
                obj.x2_   = x2_exp;
                obj.phi_  = phi_exp;
                obj.azim_ = azim_exp;
            else
                obj.x2_   = x2_exp(ix);
                obj.phi_  = phi_exp(ix);
                obj.azim_ = azim_exp(ix);
            end
            
            % Repeat for detector orientation
            if ndet0==ndet % dmat size matches id size
                if isempty(ix)
                    obj.dmat_ = dmat;
                else
                    obj.dmat_ = dmat(:,:,ix);
                end
            elseif ndet0==1 % dmat is a single [3,3] value
                obj.dmat_ = repmat(dmat,[1,1,ndet]); % expand its size to agree with id
            else
                error('HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                      ['Number of detector orientations must be unity ', ...
                       'or match the number of detector identifiers']);
            end
            
            % Repeat for detector objects
            obj.det_ = det;     % this assignment will check correct class of det
            if det.ndet==ndet
                if ~isempty(ix)
                    obj.det_  = obj.det_.reorder(ix);
                end
            elseif det.ndet==1  % must make ndet>1, as scalar case already caught
                obj.det_ = obj.det_.replicate(ndet);
            else
                error('HERBERT:IX_detector_bank_constructor:invalid_argument', ...
                      ['Number of detectors must be unity ',  ...
                       'or match the number of detector identifiers'])
            end
            
        end
        %------------------------------------------------------------------
        % Set/get methods for dependent properties (combined)
        %
        % Checks that rely on interdependencies must go here
        % first, dealing with the combined variables
        
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
            % this assumes all values are consistent
            obj.id_ = val.id;
            obj.x2_ = val.x2;
            obj.phi_ = val.phi;
            obj.azim_ = val.azim;
            obj.dmat_ = val.dmat;
            obj.det_ = val.det;
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties (individual)
        %
        % Set/get methods that rely on interdependencies between the properties
        % having been resolved before the set must go above.
        % 

        % Set methods continue to be supported for the purposes of
        % (a) recalibrating an instrument
        % (b) changing the detector for instrument design purposes
        % set.combine is still used for load/save
        
        %------------------------------------------------------------------
        % Get/set methods for dependent properties
        
        % ------------------------------
        % property id
         
        function val = get.id(obj)
            val = obj.id_;
        end
        
        function obj = set.id (obj,val)
            
            % NOTE: the new ids must be the same size as the old one; hence
            % the property values do not need to be resized at this point.
            % If the number of detectors changes, then a new bank must be
            % constructed.
            if numel(val)==numel(obj.id_)
                [ok,mess,~] = is_integer_id_nosort(val);
                if ok
                    obj.id_ = val(:);
                else
                    error('HERBERT:IX_detector_bank:invalid_argument', ...
                           ['Detector id state issue',mess]);
                end
            else
                error('HERBERT:IX_detector_bank:invalid_argument', ...
                      'The new number of detector identifiers must match the previous number');
            end
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
            
        end
        
        % -----------------------------
        % property x2
        
        function val = get.x2(obj)
            val = obj.x2_;
        end
        
        function obj=set.x2(obj,val)
            obj.x2_ = expand_args_by_ref (obj.id_, val);
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
        end

        % -----------------------------
        % property phi
        
        function val = get.phi(obj)
            val = obj.phi_;
        end
        
        function obj=set.phi(obj,val)
            obj.phi_ = expand_args_by_ref (obj.id_, val);
            
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
        end

        % -----------------------------
        % property azim
        
        function val = get.azim(obj)
            val = obj.azim_;
        end
        
        function obj=set.azim(obj,val)
            obj.azim_ = expand_args_by_ref (obj.id_, val);
            
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
        end

        % -----------------------------
        % property dmat
        
        function val = get.dmat(obj)
            val = obj.dmat_;
        end
        
        function obj=set.dmat(obj,val)
            [ok,mess,ndet0] = det_orient_trans (val, 'dmat');
            if ~ok, error('HERBERT:IX_detector_bank:invalid_argument',mess), end
            
            if obj.ndet == ndet0
                obj.dmat_ = val; % assign as-is
            elseif ndet0==1
                obj.dmat_ = repmat(val,[1,1,obj.ndet]); % scalar input, make duplicates
            else
                error('HERBERT:IX_detector_bank:invalid_argument', ...
                       ['Number of detector orientations must be scalar ', ...
                        'or match the number of detector identifiers']);
            end
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
        end
        
        % -----------------------------
        % property det
        
        function val = get.det(obj)
            val = obj.det_;
        end
        
        function obj=set.det(obj,val)
            % check correct type
            if isa(val,'IX_det_abstractType') && isscalar(val)
                obj.det_ = val;
            else
                error('HERBERT:IX_detector_bank:invalid_argument', ...
                      'Detector type must be a single IX_det_abstractType object')
            end
            
            if val.ndet==obj.ndet
                obj.det_=val;
            else
                if val.ndet==1
                    obj.det_ = val.replicate(obj.ndet);
                else
                    error('HERBERT:IX_detector_bank:invalid_argument', ...
                          ['The number of detectors must match be unity or ', ...
                           'equal the number of detector identifiers']);
                end
            end
            
            if obj.do_check_combo_arg()
                obj.check_combo_arg();
            end
        end
        

        function val = get.ndet(obj)
            val = obj.det_.ndet;
        end
        
        %------------------------------------------------------------------
        
    end
    
    methods
            % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 1;
        end
        %
        function flds = saveableFields(~)
            % get independent fields, which fully define the state of the
            % serializable object.
            flds = IX_detector_bank.fields_to_save_;
        end
    end
        
    %------------------------------------------------------------------
    methods (Static)
        %{
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %}
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class 
            obj = IX_detector_bank();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

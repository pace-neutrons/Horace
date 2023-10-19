classdef IX_detector_array < serializable
    % Full description of a set of detector banks. Each bank is made up of
    % an array of detectors of a single type e.g. one can contain an array
    % of 3He tubes (an object of class IX_det_He3tube), another an array of
    % slab detectors (an object of class IX_det_slab) etc. There can be an
    % arbitrary number of banks of each type in any order.
    %
    % An IX_detector_array object is essentially an array of
    % IX_detector_bank objects, but with two essential differences:
    %
    %   (1) IX_detector_array ensures that the detector indices are unique
    %       across all of the detector banks, not just within one detector
    %       bank (which is all that an instance of IX_detector_bank will
    %       ensure).
    %   (2) Methods such as calculation of detector efficieny will operate
    %       on the entire IX_detector_array, calling the correct functions
    %       for each of the different detector types in the different
    %       banks.
    %
    % Accessing and changing properties
    % ---------------------------------
    % In most applications, an IX_detector_array object can be considered as a
    % single detector bank of heterogeneous detector types. For example, get
    % methods of IX_detector_bank which are generic for all detector types, such
    % as x2 (sample-detector distance) and phi and azim (scattering angles),
    % return the values for all detectors in the array of detectgor banks.
    % Similarly, the set methods for these properties apply across all of the
    % detectors. This is useful, for example, when setting the distances and
    % scattering angles after a recalibration.
    %
    % To get or set properties that are specific to a particular detector type,
    % you need to get a particular detector bank, and get or set its properties
    % using the approperiate getter and setter methods. For example, it has no
    % meaning to ask for the 3He pressure for an IX_detector_array if it
    % contains banks of scintillator detectors. Once you have changed the
    % properties of a particular detector bank, you can then set the detector
    % bank within the IX_detector_array using a set method:
    %
    %   detarray = IX_detector_array (...<arguments>...);
    %       :
    %   my_He3bank = detarray.det_bank(3);  % get 3rd detector bank
    %   my_bank.atms = 6.3;                 % set all gas pressures to 6.3 atms
    %   det_array.det_bank(3) = my_He3bank; % reset the detector bank
    
    
    properties (Access=private)
        % Array of IX_detector_bank objects (column vector, length = number
        % of detector banks)
        det_bank_ = IX_detector_bank()
        
        % Path to file source, if any
        filepath_ = ''
        
        % Name of file source, if any
        filename_ = ''
    end
    
    properties (Dependent)
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        % Array of detector banks
        % (Column vector, length = number of detector banks)
        det_bank
        % Path to file source, if any.
        filepath
        % Name of file source, if any.
        filename
        
        % Generic properties across all detector banks:
        % ---------------------------------------------
        % Detector identifiers, unique integers greater or equal to one.
        % (Column vector, length = total number of detectors)
        id
        % Alias for id, field as used in Horace detpar-struct
        group
        % Sample-detector distances (m)
        % (Column vector, length = total number of detectors)
        x2
        % Scattering angles (degrees, in range 0 to 180)
        % (Column vector, length = total number of detectors)
        phi
        % Azimuthal angles (degrees)
        % (Column vector, length = total number of detectors)
        % The sense of rotation is that sitting on the beamstop and looking
        % at the sample, azim = 0 is to the east i.e. to the right,
        % azim = 90 is north i.e. vertically up etc.
        azim
        % Detector orientation matrices (size [3,3,ndet])
        % The matrix gives components in the secondary spectrometer coordinate
        % frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Detector rotation vectors (size [3,ndet])
        % The detector frame is obtained by rotation according to the vector
        % which has components in the secondary spectrometer coordinate frame.
        % This is an alternative representation of the information in dmat
        rotvec
        
        % Other dependent properties:
        % ---------------------------
        % Number of detectors summed across all the detector banks (get access
        % only) (scalar)
        ndet
        % Number of detectors in each of the detector banks (get access
        % only) (column vector length equal to number of detector banks)
        ndet_bank
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_detector_array (varargin)
            % Create an IX_detector_array
            %
            % From existing IX_detector_bank objects or array of objects:
            %   >> obj = IX_detector_array (bank1, bank2, ...)
            %
            % Create an instance with just a single detector bank:
            %   >> obj = IX_detector_array (id, x2, ...)
            %
            % From a detpar structure (legacy constructor)
            %   >> obj = IX_detector_array (detpar_struct)
            %
            % Input:
            % ------
            %   bank1, bank2,...    Arrays of IX_detector_bank objects
            %
            % *OR*
            %
            %   id, x2, ...         Arguments as needed to create a single
            %                       detector bank object. For more details
            %                       see <a href="matlab:help('IX_detector_bank');">IX_detector_bank</a>
            % *OR*
            %   detpar_struct       Scalar structure with the required fields
            %                       for a detpar:
            %                       'filename','filepath','group','x2','phi',...
            %                       'azim', 'width', 'height'
            
            if nargin>0
                is_detector_bank = cellfun(@(x)(isa(x,'IX_detector_bank')), varargin);
                if all(is_detector_bank)
                    % All inputs have class IX_detector_bank
                    % Concatenate into a single array
                    tmp = cellfun (@(x)(x(:)), varargin, 'uniformOutput', false);
                    obj.det_bank_ = cat(1,tmp{:});
                    clear tmp
                    
                    % Check that the detector identifiers are all unique
                    id = arrayfun (@(O)(O.id), obj.det_bank_, 'uniformOutput', false);
                    id_all = cat(1,id{:});
                    if ~is_integer_id (id_all)
                        error ('HERBERT:IX_detector_array:invalid_argument',...
                            'Detector identifiers must all be unique')
                    end
                    
                elseif numel(varargin)==1 && isstruct(varargin{1})
                    % Single argument that is a structure. Assume attempt to
                    % initialise with a detpar structure
                    S = varargin{1};
                    if ~isscalar(S)
                        error ('HERBERT:IX_detector_array:invalid_argument',...
                            'Detpar structure must be a scalar structure')
                    elseif all( isfield(S, {'filename','filepath',...
                            'group','x2','phi','azim', 'width', 'height'}))
                        
                        % get the default types and parameters for a detector - these should have been
                        % set by the user before use here. 
                        % NOTE - this is an interim solution to obtain
                        % detector parameter values until they are
                        % available in nxspe. #1338 tracks the need to
                        % update this.
                        [dtype,dparms] = IX_det_abstractType.tobyfit_defaults();
                        if strcmp(dtype,'IX_det_He3tube')
                            obj.det_bank_ = IX_detector_bank ( ...
                                S.group, S.x2, S.phi, S.azim, ...
                                IX_det_He3tube (S.width, S.height, ...
                                dparms.wall, dparms.p));
                        elseif strcmp(dtype,'IX_det_TobyfitClassic')
                            obj.det_bank_ = IX_detector_bank ( ...
                                S.group, S.x2, S.phi, S.azim, ...
                                IX_det_TobyfitClassic (S.width, S.height));
                        elseif isempty(dtype)
                            %{
                            % omitting this warning for the moment as it
                            % causes problems with
                            % test_admin/upgrade_file_formats, but it may be
                            % useful to reinstate it at some stage
                            warning("HORACE:IX_detector_array:empty detector type", ...
                                    "probably on load from detpar");
                            %}
                            obj.det_bank_ = IX_detector_bank ( ...
                                S.group, S.x2, S.phi, S.azim, ...
                                IX_det_TobyfitClassic (S.width, S.height));
                        else
                            error('HORACE:IX_detector_array:invalid_type', ...
                                  'unsupported detector type');
                        end
                        
                        obj.filename_ = S.filename;
                        obj.filepath_ = S.filepath;
                    else
                        error ('HERBERT:IX_detector_array:invalid_argument',...
                            ['Detpar structure must have fields \n',...
                            '''filename'',''filepath'',''group'',''x2'','...
                            '''phi'',''azim'', ''width'', ''height'''])
                    end
                    
                else
                    % Delegate processing of varargin to IX_detector_bank.
                    % This implies that varargin is the whole set of
                    % detector bank constructor arguments.
                    obj.det_bank_ = IX_detector_bank (varargin{:});
                end
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties; these define object state:
        % ---------------------------------------------------------
        function obj = set.det_bank (obj, val)
            if ~isa(val,'IX_detector_bank') || isempty(val)
                error('HERBERT:IX_detector_array:invalid_argument',...
                    'Detector bank(s) must be a non-empty IX_detector_bank array')
            end
            obj.det_bank_ = val(:);
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.filepath (obj, val)
            if isempty(val)
                val = '';
            elseif ~is_string(val)
                error('HERBERT:IX_detector_array:invalid_argument',...
                    'Filepath must be a string ')
            end
            obj.filepath_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.filename (obj, val)
            if isempty(val)
                val = '';
            elseif ~is_string(val)
                error('HERBERT:IX_detector_array:invalid_argument',...
                    'Filename must be a string ')
            end
            obj.filename_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        % Generic properties across all detector banks:
        % ---------------------------------------------
        function obj = set.id (obj, val)
            ndets = obj.ndet_bank;
            % Input must be an array with ndet elements
            if ~isnumeric(val) || numel(val)~=sum(ndets)
                error('HERBERT:IX_detector_array:invalid_argument',...
                    'Detector indices must be a numeric array with %d elements', ...
                    sum(ndets))
            end
            % Check all id are unique positive integers
            [ok, mess] = is_integer_id (val);
            if ~ok
                error('HERBERT:IX_detector_array:invalid_argument',...
                    ['Detector ', mess])
            end
            % Alter every bank
            tmp = obj.det_bank_;
            nend = cumsum(ndets);
            nbeg = nend - ndets + 1;
            for i=1:numel(tmp)
                tmp(i).id = val(nbeg(i):nend(i));
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.x2 (obj, val)
            ndets = obj.ndet_bank;
            % Input must be scalar or an array with ndet elements
            if ~isnumeric(val) || ~(numel(val)==sum(ndets) || isscalar(val))
                error('HERBERT:IX_detector_array:invalid_argument',...
                    ['Sample - detector distance(s) must be a scalar or a ',...
                    'numeric array with %d elements'], sum(ndets))
            end
            % Alter every bank
            tmp = obj.det_bank_;
            if numel(val)>1
                nend = cumsum(ndets);
                nbeg = nend - ndets + 1;
                for i=1:numel(tmp)
                    tmp(i).x2 = val(nbeg(i):nend(i));
                end
            else
                for i=1:numel(tmp)
                    tmp(i).x2 = val;
                end
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.phi (obj, val)
            ndets = obj.ndet_bank;
            % Input must be scalar or an array with ndet elements
            if ~isnumeric(val) || ~(numel(val)==sum(ndets) || isscalar(val))
                error('HERBERT:IX_detector_array:invalid_argument',...
                    ['Scattering angle(s) must be a scalar or a ',...
                    'numeric array with %d elements'], sum(ndets))
            end
            % Alter every bank
            tmp = obj.det_bank_;
            if numel(val)>1
                nend = cumsum(ndets);
                nbeg = nend - ndets + 1;
                for i=1:numel(tmp)
                    tmp(i).phi = val(nbeg(i):nend(i));
                end
            else
                for i=1:numel(tmp)
                    tmp(i).phi = val;
                end
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.azim (obj, val)
            ndets = obj.ndet_bank;
            % Input must be scalar or an array with ndet elements
            if ~isnumeric(val) || ~(numel(val)==sum(ndets) || isscalar(val))
                error('HERBERT:IX_detector_array:invalid_argument',...
                    ['Azimuthal angle(s) must be a scalar or a ',...
                    'numeric array with %d elements'], sum(ndets))
            end
            % Alter every bank
            tmp = obj.det_bank_;
            if numel(val)>1
                nend = cumsum(ndets);
                nbeg = nend - ndets + 1;
                for i=1:numel(tmp)
                    tmp(i).azim = val(nbeg(i):nend(i));
                end
            else
                for i=1:numel(tmp)
                    tmp(i).azim = val;
                end
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.dmat (obj, val)
            ndets = obj.ndet_bank;
            % Input must have size [3,3,ndet] or [3,3] (==[3,3,1])
            ndetTot = sum(ndets);
            if ~(isnumeric(val) || (isequal(size(val), [3,3]) || isequal(size(val), [3,3,ndetTot])))
                if ndetTot>1
                    error('HERBERT:IX_detector_array:invalid_argument',...
                        ['Detector orientation matrices must be a numeric array ',...
                        'with size [3,3] or [3,3,%d]'], ndetTot)
                else
                    error('HERBERT:IX_detector_array:invalid_argument',...
                        ['Detector orientation matrix must be a numeric array ',...
                        'with size [3,3]'])
                end
            end
            % Alter every bank
            tmp = obj.det_bank_;
            if size(val,3)>1
                nend = cumsum(ndets);
                nbeg = nend - ndets + 1;
                for i=1:numel(tmp)
                    tmp(i).dmat = val(:,:,nbeg(i):nend(i));
                end
            else
                for i=1:numel(tmp)
                    tmp(i).dmat = val;
                end
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        %---------------------------
        function obj = set.rotvec (obj, val)
            ndets = obj.ndet_bank;
            % Input must have size [3,ndet], [3,1] or [1,3]
            if ~isnumeric(val) || ~((isvector(val) && numel(val)==3) || ...
                    isequal(size(val), [3,sum(ndets)]))
                if sum(ndets)>1
                    error('HERBERT:IX_detector_array:invalid_argument',...
                        ['Detector orientation rotation vectors must be a numeric ',...
                        'array with size [3,%d]'], sum(ndets))
                else
                    error('HERBERT:IX_detector_array:invalid_argument',...
                        ['Detector orientation rotation vector must be a numeric ',...
                        'vector length 3'])
                end
            end
            % Alter every bank
            tmp = obj.det_bank_;
            if numel(val)>3     % must have size [3,ndet] and ndet>1
                nend = cumsum(ndets);
                nbeg = nend - ndets + 1;
                for i=1:numel(tmp)
                    tmp(i).rotvec = val(:,nbeg(i):nend(i));
                end
            else
                for i=1:numel(tmp)
                    tmp(i).rotvec = val(:);     % make val a column
                end
            end
            obj.det_bank_ = tmp;
            
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        %------------------------------------------------------------------
        
        % Mirrors of private properties; these define object state:
        function val = get.det_bank (obj)
            val = obj.det_bank_;
        end
        
        function val = get.filename (obj)
            val = obj.filename_;
        end
        
        function val = get.filepath (obj)
            val = obj.filepath_;
        end
        
        % Generic properties across all detector banks:
        function val = get.id(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun (@(O)(O.id), obj.det_bank_, 'uniformOutput', false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.id;
            end
        end
        
        function val = get.group(obj)
            val = obj.id';
        end

        function val = get.x2(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun (@(O)(O.x2), obj.det_bank_, 'uniformOutput' ,false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.x2;
            end
        end
        
        function val = get.phi(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun (@(O)(O.phi), obj.det_bank_, 'uniformOutput', false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.phi;
            end
        end
        
        function val = get.azim(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun (@(O)(O.azim), obj.det_bank_, 'uniformOutput', false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.azim;
            end
        end
        
        function val = get.dmat(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(O)(O.dmat), obj.det_bank_, 'uniformOutput', false);
                val = cat(3,tmp{:});
            else
                val = obj.det_bank_.dmat;
            end
        end
        
        function val = get.rotvec(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(O)(O.rotvec), obj.det_bank_, 'uniformOutput', false);
                val = cat(2,tmp{:});
            else
                val = obj.det_bank_.rotvec;
            end
        end
        
        function val = get.ndet(obj)
            if numel(obj.det_bank_)>1
                val = sum(arrayfun (@(O)(O.ndet), obj.det_bank_));
            else
                val = obj.det_bank_.ndet;
            end
        end
        
        function val = get.ndet_bank(obj)
            if numel(obj.det_bank_)>1
                val = arrayfun (@(O)(O.ndet), obj.det_bank_);
            else
                val = obj.det_bank_.ndet;
            end
        end
        
    end
    
    methods(Static)
        function is_dp_struct = check_detpar_parms(dp)
            % checks input dp to see if it is a proper old-style detpar struct.
            % the recipe for such a struct is given in the isdetpar= line
            % below. Such a struct can be consumed by the IX_detector_array
            % constructor. Other inputs may also be interpretable by the
            % constructor but are not handled here.
            %{
             is_dp_struct = false;
            if ~isstruct(dp)
                return;
            end

            is_dp_struct = isfield(dp,'group') && isfield(dp,'x2') && isfield(dp,'phi') ...
                    && isfield(dp,'azim') && isfield(dp,'filename') && isfield(dp,'filepath') ...
                    && isfield(dp, 'width') && isfield(dp, 'height');
            %}

            is_dp_struct = isstruct(dp) && all( isfield(dp,{'group','x2','phi','azim', ...
                'filename','filepath','width','height'}));
                end
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
            flds = {'det_bank', 'filename', 'filepath'};
        end
        
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Boilerplate loadobj method, calling the generic loadobj method of
            % the serializable class
            obj = IX_detector_array();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================
    
end

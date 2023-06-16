classdef IX_detector_array < serializable
    % Full description of a set of detector banks. Each bank is made up of
    % an array of detectors of a single type e.g. one can contain an array
    % of 3He tubes (an object of class IX_det_He3tube), another an array of
    % slab detectors (an object of class IX_det_slab) etc. There can be an
    % arbitrary number of banks of each type in any order.
    %
    % An IX_detector_array object is essentially an array of
    % IX_detector_bank objects, but with two essential differences:
    %   (1) IX_detector_array ensures that the detector indices are unique
    %       across all of the detector banks, not just within one detector
    %       bank (which is all that an instance of IX_detector_bank will
    %       ensure).
    %   (2) Methods such as calculation of detector efficieny will operate
    %       on the entire IX_detector_array, calling the correct functions
    %       for each of the different detector types in the different
    %       banks.

    properties (Access=private)
        % Array of IX_detector_bank objects (column vector, length = number
        % of detector banks)
        det_bank_ = IX_detector_bank
        
        % Name of file source, if any
        filename_ = ''
        
        % Path to file source, if any
        filepath_ = ''
    end

    properties (Dependent)
        % Detector identifiers, unique integers greater or equal to one.
        % (Column vector, length = total number of detectors)
        id
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
        % Detector orientation matrices.
        % Array size [3,3,ndet], where ndet is the total number of
        % detectors.
        % The matrix gives components in the secondary spectrometer
        % coordinate frame given those in the detector coordinate frame:
        %       xf(i) = Sum_j [D(i,j) xdet(j)]
        dmat
        % Array of detector banks.
        % (Column vector, length = number of detector banks)
        det_bank
        % Number of detectors summed across all the detector banks
        ndet
        % Name of file source, if any.
        filename
        % Path to file source, if any.
        filepath
    end

    properties(Constant, Access=private)
        fields_to_save_ = {'det_bank', 'filename', 'filepath'};
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
            %   detpar_struct       Structure


            if nargin>0
                is_detector_bank = cellfun(@(x)(isa(x,'IX_detector_bank')), varargin);
                if all(is_detector_bank)
                    % All inputs have class IX_detector_bank
                    % Concatenate into a single array
                    tmp = cellfun (@(x)(x(:)), varargin, 'uniformOutput', false);
                    obj.det_bank_ = cat(1,tmp{:});
                    clear tmp
                    
                    % Check that the detector identifiers are all unique
                    id = arrayfun (@(x)(x.id), obj.det_bank_, 'uniformOutput', false);
                    id_all = cat(1,id{:});
                    if ~is_integer_id (id_all)
                        error ('HERBERT:IX_detector_array:invalid_argument',...
                            'Detector identifiers must all be unique')
                    end
                else
                    dp = varargin{1};
                    is_detpar_struct = IX_detector_array.check_detpar_parms(dp);
                    if is_detpar_struct
                        % The struct has the full recipe for constructing
                        % the detector bank and the origin filepath.
                        % Splitting it up and passing it to the object
                        % components
                        obj.det_bank_ = IX_detector_bank( ...
                            dp.group, dp.x2, dp.phi, dp.azim, ...
                            IX_det_TobyfitClassic (dp.width, dp.height));
                        obj.filename_ = dp.filename;
                        obj.filepath_ = dp.filepath;
                    else
                        % if varargin{1} isn't a detpar struct, delegate
                        % processing of varargin to the detector bank.
                        % This implies that varargin is the whole set of
                        % detector bank constructor arguments.
                        obj.det_bank_ = IX_detector_bank(varargin{:});
                    end
                end
            end

        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %------------------------------------------------------------------
        
        function obj = set.det_bank(obj,val)
            obj.det_bank_ = val;
        end

        function obj = set.filename(obj,val)
            obj.filename_ = val;
        end

        function obj = set.filepath(obj,val)
            obj.filepath_ = val;
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        %------------------------------------------------------------------

        function val = get.filename(obj)
            val = obj.filename_;
        end

        function val = get.filepath(obj)
            val = obj.filepath_;
        end

        function val = get.id(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.id), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.id;
            end
        end

        function val = get.x2(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.x2), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.x2;
            end
        end

        function val = get.phi(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.phi), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.phi;
            end
        end

        function val = get.azim(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.azim), obj.det_bank_,'uniformOutput',false);
                val = cell2mat(tmp);
            else
                val = obj.det_bank_.azim;
            end
        end

        function obj = set.azim(obj, val)
            obj.det_bank_.azim = val;
        end

        function val = get.dmat(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(x.dmat), obj.det_bank_,'uniformOutput',false);
                val = cat(3,tmp{:});
            else
                val = obj.det_bank_.dmat;
            end
        end

        function val = get.det_bank(obj)
            val = obj.det_bank_;
        end

        function val = get.ndet(obj)
            if numel(obj.det_bank_)>1
                tmp = arrayfun(@(x)(numel(x.id)), obj.det_bank_);
                val = sum(tmp);
            else
                val = obj.det_bank_.ndet;
            end
        end

        %------------------------------------------------------------------

        function detpar = convert_to_old_detpar(obj)
            detpar = struct();
            if size(obj.det_bank.id,1)==1
                detpar.group = obj.det_bank.id;
                detpar.x2    = obj.det_bank.x2;
                detpar.phi   = obj.det_bank.phi;
                detpar.azim  = obj.det_bank.azim;
                detpar.width = obj.det_bank.det.dia;
                detpar.height = obj.det_bank.det.height;
            else
                detpar.group = obj.det_bank.id';
                detpar.x2    = obj.det_bank.x2';
                detpar.phi   = obj.det_bank.phi';
                detpar.azim  = obj.det_bank.azim';
                detpar.width = obj.det_bank.det.dia';
                detpar.height = obj.det_bank.det.height';
            end
            detpar.filename = obj.filename;
            detpar.filepath = obj.filepath;
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
            flds = IX_detector_array.fields_to_save_;
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % boilerplate loadobj method, calling generic method of
            % saveable class
            obj = IX_detector_array();
            obj = loadobj@serializable(S,obj);
        end
    end
    %======================================================================

end

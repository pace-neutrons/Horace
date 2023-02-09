classdef sigvar < serializable
    % Signal array and associated variances (standard errors squared)

    properties (Access=private)
        % Signal array
        % Numeric array of any size (including any size empty array)
        signal_ = []

        % Variance array
        % An array same size as signal array (all elements >=0 or NaN)
        % If all variances are zero, then = [] (to save memory)
        variance_ = []

        % Mask array
        % Logical array same size as signal array (0 = mask, 1 = retain)
        % If all elements are retained then = [] (to save memory)
        mask_ = []
        %
        initialized_ = false;
    end

    properties (Dependent)
        n_elements % number of elements in signal, error and mask arrays
        s       % Signal array (numeric array)
        e       % Variance array (numeric array, same size as signal array)
        msk     % Mask array (logical array, same size as signal array, 0=mask, 1=retain)
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = sigvar (varargin)
            % Create sigvar object
            %
            %   >> w = sigvar           % Empty object
            %   >> w = sigvar(s)        % Signal but no variance
            %   >> w = sigvar(s,e)      % Signal and variance
            %   >> w = sigvar(s,e,msk)  % Signal and variance
            %
            % Input:
            % ------
            %   s       Signal (numeric array)
            %
            % Optional arguments:
            %   e       Variance array (same size as signal array)
            %           All elements must be greater or equal to zero
            %           If an empty array, then variances are assumed to all be zero
            %           If scalar (and signal non-empty) then all elements assumed to be same
            %
            %   msk     Mask array (logical array same size as signal array)
            %           Elements are 0 (mask) or 1 (keep)
            %           If an empty array, then assumed all points are retained
            %           If scalar (and signal non-empty) then all elements assumed to be same

            narg = numel(varargin);
            if narg == 0
                return;
            end
            if narg ==1
                if isa(varargin{1},'sigvar')
                    % Need to catch the case of input being a sigvar object for
                    % generic binary and unary operations to work (they require
                    % that a sigvar object be returned from an instance of the
                    % class; in this case that a sigvar object be returned from
                    % a signvar object - a dummy operation)
                    obj = varargin{1};
                elseif isstruct(varargin{1})
                    % local copy of input struct to fill in with missing
                    % items as needed
                    obj = sigvar.loadobj(varargin{1});
                else % probably only signal given
                    obj.s = varargin{1};
                end
            else
                flds = obj.saveableFields();
                [obj,remains] = obj.set_positional_and_key_val_arguments(...
                    flds,false,varargin{:});
                if ~isempty(remains)
                    error('HERBERT:sigvar:invalid_argument', ...
                        'Sigval constructor inputs: %s have not been recognized',...
                        disp2str(remains));
                end
            end

        end

        %------------------------------------------------------------------
        % Set methods for dependent properties

        function obj=set.s(obj,val)
            if isempty(val)
                obj.signal_ = [];
            elseif ~isnumeric(val)
                error('HERBERT:sigvar:invalid_argument', ...
                    'signal has to be numeric')
            end
            obj.signal_ = val;
            obj.initialized_ = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.e(obj,val)
            if isempty(val)
                obj.variance_ = [];
            elseif ~isnumeric(val) || any(val(:)<0)
                error('HERBERT:sigvar:invalid_argument', ...
                    'variance has to be numeric non-negative array')
            end
            obj.variance_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        function obj=set.msk(obj,val)
            if isempty(val)
                val = [];
            elseif isnumeric(val)
                if any(isnan(val(:)))
                    val(isnan(val)) = false;    % ensure NaN interpreted as false
                end
                if logical(val)     % if converted to true
                    val = [];
                else
                    val = false;
                end

            elseif ~islogical(val)
                error('HERBERT:sigvar:invalid_argument', ...
                    'mask must be be numeric or logical array')
            end
            if all(val(:))
                val = [];
            end
            obj.mask_ = val;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function nm = get.n_elements(obj)
            if isempty(obj.signal_)
                nm = 0;
            else
                nm = numel(obj.signal_);
            end
        end

        function val=get.s(obj)
            % Return signal array
            val=obj.signal_;
        end

        function val=get.e(obj)
            % Return variance array, expanding [] as required
            if isempty(obj.variance_)  % i.e. variance_ == []
                val = zeros(size(obj.signal_));
            else
                val = obj.variance_;
            end
        end

        function val=get.msk(obj)
            % Return mask array, expanding [] as required
            if isempty(obj.mask_)
                val = true(size(obj.signal_));
            else
                val = obj.mask_;
            end
        end
        %------------------------------------------------------------------
    end

    %======================================================================
    % SERIALIZABLE INTERFACE
    methods
        function obj =check_combo_arg(obj)
            if isempty(obj.signal_)
                obj.variance_ = [];
                obj.mask_ = [];
                return;
            end
            if isscalar(obj.variance_) && ~isscalar(obj.signal_)
                obj.variance_ = obj.variance_*ones(size(obj.signal_));
            end
            if ~isempty(obj.variance_) && ...
                    ~isequal(size(obj.signal_), size(obj.variance_))
                if numel(obj.signal_) == numel(obj.variance_)
                    obj.variance_ = reshape(obj.variance_,size(obj.signal_));
                else
                    error('HERBERT:sigvar:invalid_argument', ...
                        'Error array should contain single element or its size to be equal the size signal array: %s. It is: %d ', ...
                        disp2str(size(obj.signal_)),disp2str(size(obj.variance_)));
                end
            end
            if ~isempty(obj.mask_)
                if isscalar(obj.mask_) && ~isscalar(obj.signal_)
                    obj.mask_ = false(size(obj.signal_));
                elseif ~isequal(size(obj.signal_),size(obj.mask_))
                    if numel(obj.signal_) == numel(obj.mask_)
                        obj.mask_ = reshape(obj.mask_,size(obj.signal_));
                    else
                        error('HERBERT:sigvar:invalid_argument', ...
                            'Mask array should contain single element or its size be equal to the size of signal array: %s. It is: %s ', ...
                            disp2str(size(obj.signal_)),disp2str(size(obj.mask_)));
                    end
                end
            end
        end
        function ver  = classVersion(~)
            % define version of the class to store in mat-files
            % and nxsqw data format. Each new version would presumably read
            % the older version, so version substitution is based on this
            % number
            ver = 2;
        end

        function flds = saveableFields(obj)
            flds = {'s','e','msk'};
            if ~obj.initialized_
                return;
            end
            fld_keep = [true,~isempty(obj.variance_),~isempty(obj.mask_)];
            flds  = flds(fld_keep);
        end
    end
    methods(Access = protected)
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version(s) of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % Input:
            % ------
            %   S       An instance of this object or struct
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            %
            if isfield(inputs,'signal_')
                inputs.s = inputs.signal_;
                inputs.e = inputs.variance_;
                inputs.msk = inputs.mask_;
            end
            if isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);
            else
                obj = obj.from_bare_struct(inputs);
            end
        end
    end

    methods(Static)
        function obj = loadobj(S)
            % loadobj method, calling generic method of
            % saveable class. Provides empty sqw class instance to
            obj = sigvar();
            obj = loadobj@serializable(S,obj);
        end
    end



end

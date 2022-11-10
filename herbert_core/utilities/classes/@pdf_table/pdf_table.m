classdef pdf_table < serializable
    % Probability distribution function table in one independent variable
    %
    % The constructor creates a probability distribution lookup table from a set
    % of x-axis values and associated function values. Methods that generate
    % random samples from the distribution or compute properties such as the mean
    % or variance use an underlying pdf that is obtained by linear interpolation
    % between the supplied x-axis values and function values.
    %
    % pdf_table Methods:
    %   pdf_table     - constructor
    %
    %   mean          - mean of probability distribution function (pdf)
    %   var           - variance of pdf
    %   width         - full width and peak of the distribution
    %
    %   rand          - generate random numbers from the pdf
    %   retain        - retain x-values rom an array according to the pdf
    %
    %   IX_dataset_1d - return plottable objects with the pdf and the
    %                   cumulative distribution function
    %
    % See also pdf_table_array pdf_table_lookup


    properties (Access=private)
        % x values
        x_ = zeros(0,1)
        % Normalised values of pdf
        f_ = zeros(0,1)
        % Maximum value of the noramlised values of pdf
        fmax_ = []
        % Normalised cumulative distribution function:
        % A(i) is the cdf up to x(i); A(1)=0 and A(end)=1
        A_ = zeros(0,1)
        % Gradient m(i) = (f(i+1)-f(i))/(x(i+1)-x(i))
        m_ = zeros(0,1)
        % Temporary variable which holds function parameters at
        % construction. (could we modify lambda function not to use it?)
        func_par_ = [];
    end

    properties (Dependent)
        x       % x values (column vector)
        f       % Normalised probability distribution function (pdf) at x (column vector)
        fmax    % Maximum value of the probability distribution function (pdf)
        A       % Cumulative distribution function at x values (A(1)=0, A(end)=1)) (column vector)
        m       % Gradient m(i) is gradient betwee x(i) and x(i+1) (column vector)
        filled  % True or false according as the object containing a pdf or not
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = pdf_table (x,pdf,varargin)
            % Create a probability distribution function table
            %
            %   >> obj = pdf_table (x, pdf_values)
            %
            %   >> obj = pdf_table (x, pdf_handle)
            %   >> obj = pdf_table (x, pdf_handle, p1, p2,...)
            %
            % Input:
            % ------
            %   x           Absicissae. Must be monotonically increasing
            %
            %   pdf_values  Array of values of theprobability distribution function
            %               at the values of x
            %     *OR*
            %   pdf_handle  Function handle that returns the probability distribution
            %              function at the values of x.
            %                   The function must have the form:
            %                   pdf = my_function (x)
            %               or:
            %                   pdf = my_function (x, p1, p2,...)
            %               where p1, p2, ... are parameters as needed by the function
            %              to compute the probability distribution function
            %
            %               EXAMPLE:
            %                   pdf = gauss (x, p);     p=[height, centre, st_dev]
            %
            %   p1, p2,...  Any arguments needed by the function. In the example
            %              function gauss above, p1 = [height, centre, st_dev]
            %
            % Output:
            % -------
            %   obj         pdf_table object
            %
            %
            % In either case of the pdf being provided as a numerical array or computed
            % by a function, all values of the pdf must be greater or equal to zero.
            % The pdf need not be normalised to unit area, as normalisation will be
            % performed internally.
            %
            % The suppied function values do not need to be continuous. For example,
            % to define the function x=[0,1,1,2]; pdf_values = [1,1,2,2] defines
            % a step at x=0 that jumps at x=1 to twice the height:
            %
            %                _
            %              _| |
            %          ___|   |___


            if nargin==1 && isstruct(x)
                % Assume trying to initialise from a structure array of properties
                obj = pdf_table.loadobj(x);

            elseif nargin>0
                if isa(pdf,'function_handle') && numel(varargin)>0
                    obj.func_par_ = varargin;
                end
                argi = {x,pdf};
                pos_params = obj.saveableFields();
                % set positional parameters and key-value pairs and check their
                % consistency using public setters interface. check_compo_arg
                % after all settings are done.
                [obj,remains] = set_positional_and_key_val_arguments(obj,pos_params,...
                    false,argi{:});
                if ~isempty(remains)
                    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_fermi_chopper constructor: %s',...
                        disp2str(remains));
                end
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.x(obj)
            val=obj.x_;
        end

        function val=get.f(obj)
            val=obj.f_;
        end

        function val=get.fmax(obj)
            val=obj.fmax_;
        end

        function val=get.A(obj)
            val=obj.A_;
        end

        function val=get.m(obj)
            val=obj.m_;
        end

        function val=get.filled(obj)
            val=~isempty(obj.x_);
        end
        %------------------------------------------------------------------
        function obj = set.x(obj,val)
            % Check x values
            if ~isnumeric(val) || ~isvector(val) || numel(val)==0 ||...
                    ~all(isfinite(val)) || any(diff(val)<0)
                error('HERBERT:pdf_table:non_monotonic',...
                    'x values must be a monotonic increasing vector')
            else
                obj.x_ = val(:);   % ensure column array
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function obj = set.f(obj,pdf)
            if isnumeric(pdf)
                obj.f_ = pdf(:); % ensure column array
            elseif isa(pdf,'function_handle')
                obj.f_ = pdf;
            else
                error('HERBERT:pdf_table:bad_pdf', ...
                    'The pdf must be a numeric vector or function handle and arguments. It is %s',...
                    class(pdf))
            end

            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
    end

    %======================================================================
    methods
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end

        function flds = saveableFields(~)
            flds = {'x','f'};
        end

        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing dependent variables
            % if requested.
            if isnumeric(obj.f_)
                if numel(obj.f_)~=numel(obj.x_)
                    error('HERBERT:pdf_table:bad_pdf', ...
                        'The number of values of the pdf (%d) must equal the number of x values (%d).', ...
                        numel(obj.f_),numel(obj.x_))
                end
                ff = obj.f_;
            else % function handle, no other options here
                if isempty(obj.func_par_)
                    ff = obj.f_(obj.x_);
                else
                    ff = obj.f_(obj.x_,obj.func_par_{:});
                    obj.func_par_ = [];
                end
            end
            if ~isvector(ff) || any(ff<0) ||...
                    ~(all(isfinite(ff))||(numel(obj.x_)==1 && ff==Inf))    % special case of a delta-function
                error('HERBERT:pdf_table:bad_pdf', ['The pdf values must ',...
                    'all be finite and greater or equal to zero\n',...
                    'or a single point with value +Inf (i.e. a delta function)'])
            end
            % Derived quantities to speed up random sampling
            if numel(obj.x_)>1
                xx = obj.x_;
                % Properly defined pdf
                dA = 0.5*diff(xx).*(ff(2:end)+ff(1:end-1));
                if all(dA==0)
                    error('HERBERT:pdf_table:bad_pdf', ['The pdf has zero ',...
                        'integrated area. The area must be non-zero.'])
                end
                AA = cumsum(dA);
                Atot = AA(end);
                obj.f_ = ff/Atot;                % to give normalised area
                obj.fmax_ = max(obj.f_);        % handy to save time elsewhere
                obj.A_ = [0;AA(1:end-1)/Atot;1]; % normalise the area
                obj.m_ = diff(obj.f_)./diff(obj.x_);
            else
                % delta function
                obj.f_ = ff;
                obj.fmax_ = ff;
                obj.A_ = 1;
                obj.m_ = NaN;
            end
        end
    end

    methods(Access=protected)
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_struct
            % function, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
            if isfield(inputs,'x')&&isempty(inputs.x)
                return
            end
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);

        end
    end

    %------------------------------------------------------------------
    methods (Static)
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
            obj = pdf_table();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------

    end
    %======================================================================


end

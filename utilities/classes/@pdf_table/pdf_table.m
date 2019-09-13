classdef pdf_table
    % Probability distribution function table
    % Given a set of x-values and associated function values, a normalised
    % probability distribution lookup table is created. The method named rand
    % will return random samples from the probability distribution function (pdf)
    % if called on the resulting object. The random numbers are drawn from the
    % function defined by linear interpolation between the supplied x-values
    % and function values.
    %
    % See also pdf_table_array pdf_table_lookup
    
    
    properties (Access=private)
        % Class version number
        class_version_ = 1;
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
    end
    
    properties (Dependent)
        x       % x values (column vector)
        f       % Values of the probability distribution function (pdf) at the x values (column vector)
        fmax    % Maximum value of the values of the probability distribution function (pdf) (column vector)
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
            %           	The function must have the form:
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
            % performed internally by this constructor.
            %
            % The suppied function values do not need to be continuous. For example,
            % to define the function x=[0,1,1,2]; pdf_values = [1,1,2,2] defines
            % a step at x=0 that jumps at x=1 to twice the height.
            
            
            if nargin==1 && isstruct(x)
                % Assume trying to initialise from a structure array of properties
                obj = pdf_table.loadobj(x);
                
            elseif nargin>0
                % Check x values
                if ~isnumeric(x) || ~isvector(x) || numel(x)<2 || any(diff(x)<0)
                    error('x values must be a vector length at least two and monotonic increasing')
                else
                    x = x(:);   % ensure column array
                end
                
                % Check pdf
                if isnumeric(pdf)
                    if numel(varargin)==0
                        f = pdf;
                    else
                        error('Check the number and type of input arguments')
                    end
                elseif isa(pdf,'function_handle')
                    f = pdf (x, varargin{:});
                else
                    error('The pdf must be a numeric vector or function handle and arguments')
                end
                
                if numel(f)~=numel(x)
                    error('The number of values of the pdf must equal the number of x values.')
                elseif ~isvector(f) || ~all(isfinite(f)) || any(f<0)
                    error('The pdf values must all be finite and greater or equal to zero')
                else
                    f = f(:);   % ensure column array
                end
                
                % Derived quantities to speed up random sampling
                dA = 0.5*diff(x).*(f(2:end)+f(1:end-1));
                if all(dA==0)
                    error('The pdf has zero integrated area. The area must be non zero.')
                end
                A = cumsum(dA);
                Atot = A(end);
                obj.x_ = x;
                obj.f_ = f/Atot;                % to give normalised area
                obj.fmax_ = max(obj.f_);        % handy to save time elsewhere
                obj.A_ = [0;A(1:end-1)/Atot;1]; % normalise the area
                obj.m_ = diff(obj.f_)./diff(obj.x_);
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
    end
    
    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
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
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

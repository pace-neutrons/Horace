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
            % The suppied function values do not need to be continuous. FOr example,
            % to define the function x=[0,1,1,2]; pdf_values = [1,1,2,2] defines
            % a step at x=0 that jumps at x=1 to twice the height.
            
            
            if nargin>0
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
                elseif ~isvector(f) || ~all(isfinite(f)) || any(f)<0
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
end

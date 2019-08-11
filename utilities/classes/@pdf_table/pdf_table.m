classdef pdf_table
    % Probability distribution function table
    
    properties (Access=private)
        % x values
        x_ = [];
        % Normalised values of pdf
        f_ = [];
        % Normalised cumulative distribution function:
        % A(i) is the cdf up to x(i); A(1)=0 and A(end)=1
        A_ = [];
        % Gradient m(i) = (f(i+1)-f(i))/(x(i+1)-x(i))
        m_ = [];
    end
    
    properties (Dependent)
        x       % x values
        f       % Values of the probability distribution function (pdf) at the x values
        A       % Cumulative distribution function at x values (A(1)=0, A(end)=1))
        m       % Gradient m(i) is gradient betwee x(i) anbd x(i+1)
        valid   % True or false according as the object being a valid pdf or not
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = pdf_table (x,pdf,varargin)
            % Create a probability distribution function table
            %
            %   >> pdf_table (x, pdf_values)
            %
            %   >> pdf_table (x, pdf_handle)
            %   >> pdf_table (x, pdf_handle, p1, p2,...)
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
            %                   pdf = my_funchandle (x)
            %               or:
            %                   pdf = my_funchandle (x, p1, p2,...)
            %               where p1, p2, ... are parameters as needed by the function
            %              to compute the probability distribution function
            %
            %               EXAMPLE:
            %                   pdf = gauss (x, p);     p=[height, centre, st_dev]
            %
            %   p1, p2,...  Arguments needed by the function
            %
            %
            % In either case of the pdf being provided as a numerical array or computed
            % by a function, all values of the pdf must be greater or equal to zero.
            % The pdf need not be normalised to unit area, as normalisation will be
            % performed by this constructor.
            
            
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
        
        function val=get.A(obj)
            val=obj.A_;
        end
        
        function val=get.m(obj)
            val=obj.m_;
        end
        
        function val=get.valid(obj)
            val=~isempty(obj.x_);
        end
        
        %------------------------------------------------------------------
        function X = rand (obj, varargin)
            % Generate random numbers from the probability distribution function
            %
            %   >> X = rand (obj)                % generate a single random number
            %   >> X = rand (obj, n)             % n x n matrix of random numbers
            %   >> X = rand (obj, sz)            % array od size sz
            %   >> X = rand (obj, sz1, sz2,...)  % array of size [sz1,sz2,...]
            %
            % Input:
            % ------
            %   n           Return square array of random numbers with size n x n
            %      *OR*
            %   sz          Size of array of output array of random numbers
            %      *OR*
            %   sz1,sz2...  Extent along each dimension of random number array
            %
            % Output:
            % -------
            %   X           Array of random numbers
            
            if ~obj.valid
                error('The probability distribution function is not initialised')
            end
            
            Asamp = rand(varargin{:});
            
            xx = obj.x_; ff = obj.f_; AA = obj.A_; mm = obj.m_;
            ix = upper_index (AA, Asamp(:));
            X = xx(ix) + 2*(Asamp(:) - AA(ix))./...
                (ff(ix) + sqrt(ff(ix).^2 + 2*mm(ix).*(Asamp(:)-AA(ix))));
            X = reshape(X,size(Asamp));
            
        end
        %------------------------------------------------------------------
    end
end

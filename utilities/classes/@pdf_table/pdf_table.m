classdef pdf_table
    % Probability distribution function table
    properties (Access=private)
        % x values
        x_
        % Normalised values of pdf
        f_
        % Normalised cumulative distribution function:
        % A(i) is the cdf up to x(i); A(1)=0 and A(end)=1
        A_
        % Gradient m(i) = (f(i+1)-f(i))/(x(i+1)-x(i))
        m_
    end
    
    properties (Dependent)
        x   % x values
        f   % Values of probability distribution function (pdf) at x values
        A   % Cumulative distribution function at x values (A(1)=0, A(end)=1))
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = pdf_table (x,pdf,varargin)
            % Create a probability distribution function
            %
            %   >> pdf_table (x, pdf_values)
            %
            %   >> pdf_table (x, pdf_handle)
            %   >> pdf_table (x, pdf_handle, p1, p2,...)
            %
            % Input:
            % ------
            %   x       Absicissae. Must be monotonically increasing
            %   pdf     Array of values or a function handle that returns the
            %          probability distribution function at the values of x. All
            %          values must be greater or equal to zero. The values need
            %          not be normalised to unit area as normalisation will be
            %          performed inside the object.
            %           If a function handle is given, the function must have the
            %          form:
            %           pdf = my_funchandle (x)
            %          or:
            %           pdf = my_funchandle (x, p1, p2,...)
            %          where p1, p2, ... are parameters as needed by the function
            %          to compute the probability distribution function
            %        EXAMPLE:
            %           pdf = gauss (x, p);     p=[height, centre, st_dev]
            
            % Check x values
            if ~isnumeric(x) || ~isvector(x) || numel(x)<2 || any(diff(x)<0)
                error('x values must be a vector length at last two and monotonic increasing')
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
                error('The pdf values must all be finite, greater or equal to zero')
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
        
        %------------------------------------------------------------------
        function X = rand (obj, varargin)
            % Generate random numbers from the pdf
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
            
            Asamp = rand(varargin{:});
            
            xx = obj.x_; ff = obj.f_; AA = obj.A_; mm = obj.m_;
            ix = upper_index (AA, Asamp(:));
            xsamp = xx(ix) + 2*(Asamp(:) - AA(ix))./...
                (ff(ix) + sqrt(ff(ix).^2 + 2*mm(ix).*(Asamp(:)-AA(ix))));
            X = reshape(xsamp,size(Asamp));
            
        end
        %------------------------------------------------------------------
    end
end

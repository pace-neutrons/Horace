classdef pdf_table_array
    % Array of probability distributions from which to pull random samples
    % The object is not simply an array of pdf_table objects. Instead, it
    % reorganises the contents of an array of pdf_table objects to optimise
    % the random sampling from the array for a large list of indicies into the
    % array, one random point per index.
    
    properties (Access=private)
        % Number of points in each distribution. Array size [npdf,1]
        npnt_
        
        % x values; array size [sum(npnt),1] where npnt_max is the maximum
        % number of points in any of the npdf probability distribution fuinctions
        x_
        
        % Normalised values of pdf; array size [sum(npnt),1]
        f_
        
        % Normalised cumulative distribution function; array size [sum(npnt),1]
        % A(i) is the cdf up to x(i); A(1)=0 and A(npnt)=1
        A_ = [];
        
        % cdf offset by pdf index number; array size [sum(npnt),1]
        Acum_ = [];
        
        % Gradient m(i) = (f(i+1)-f(i))/(x(i+1)-x(i)); array size [sum(npnt),1]
        % Each distribution has npnt-1 entries; excess ones are set to NaN
        m_ = [];
    end
    
    properties (Dependent)
        % Number of probability distributions
        npdf
        
        % Number of points in each of the probability distribution functions
        npnt
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = pdf_table_array (pdf)
            % Create a probability distribution function array
            %
            %   >> obj = pdf_table_array (pdf)
            %
            % Input:
            % ------
            %   pdf     Array of pdf_table objects
            %
            % Output:
            % -------
            %   obj     pdf_table_array object
            
            if isa(pdf,'pdf_table')
                if numel(pdf)==0
                    error('Empty pdf_table object array is not permitted')
                end
                if ~all(arrayfun(@(x)(x.valid),pdf(:)))
                    error('Not all pdf_table objects are valid - cannot make a table array')
                end
            else
                error('Argument must be an array of pdf_table objects')
            end
            
            npdf = numel(pdf);
            npnt = arrayfun(@(x)(numel(x.f)),pdf);
            nend = cumsum(npnt(:));
            nbeg = nend - npnt(:) + 1;
            
            x = NaN(nend(end),1);
            f = NaN(nend(end),1);
            A = NaN(nend(end),1);
            Acum = NaN(nend(end),1);
            m = NaN(nend(end),1);
            for i=1:npdf
                x(nbeg(i):nend(i)) = pdf(i).x;
                f(nbeg(i):nend(i)) = pdf(i).f;
                A(nbeg(i):nend(i)) = pdf(i).A;
                Acum(nbeg(i):nend(i)) = A(nbeg(i):nend(i)) + (i-1);
                m(nbeg(i):nend(i)-1) = pdf(i).m;
            end
            obj.npnt_ = npnt;
            obj.x_ = x;
            obj.f_ = f;
            obj.A_ = A;
            obj.Acum_ = Acum;
            obj.m_ = m;
            
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.npdf(obj)
            val=numel(obj.npnt_);
        end
        
        function val=get.npnt(obj)
            val=obj.npnt_;
        end
        
        %------------------------------------------------------------------
        function X = rand_ind (obj, ind)
            % Generate random numbers from a lookup table of probability distributions
            %
            %   >> X = rand_ind  (obj, ind)
            %
            % Works by linear interpolation.
            %
            % Input:
            % ------
            %   obj         pdf_table_array object
            %
            %   ind         Array containing the probability distribution function
            %              indicies from which a random number is to be taken.
            %              min(ind(:))>=1, max(ind(:))<=npdf
            %
            % Output:
            % -------
            %   X           Array of random numbers from the distributions, with the
            %              same size as ind.
            
            np = numel(ind);        % number of random points requested
            A_samp = rand(np,1);
            Acum_samp = A_samp + (ind(:)-1);
            
            xx = obj.x_; ff = obj.f_; AA = obj.A_; mm = obj.m_; AAcum = obj.Acum_;
            ix = upper_index (AAcum, Acum_samp(:));
            X = xx(ix) + 2*(A_samp(:) - AA(ix))./...
                (ff(ix) + sqrt(ff(ix).^2 + 2*mm(ix).*(A_samp(:)-AA(ix))));
            X = reshape(X,size(ind));
            
            %------------------------------------------------------------------
        end
    end
end

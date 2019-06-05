classdef pdf_table_array
    % Array of probability distributions from which to pull random samples
    %
    % A pdf_array object reorganises the contents of an array of pdf_table
    % objects to optimise the speed of random sampling from the array for a
    % large list of indices into the array, one random point per index:
    %
    % Useage:
    %  if pdf is an array of pdf_table objects, and ind is a large array of
    %  indices into pdf, then replace:
    %
    %   for i=1:numel(ind)
    %       X(i) = rand(pdf(ind(i)))
    %   end
    %
    % with:
    %   pdfarr = pdf_array(pdf);
    %   X = rand_ind(pdfarr, ind)
    %
    % See also pdf_table pdf_table_lookup
    
    properties (Access=private)
        % Number of points in each distribution. Array size [npdf,1]
        npnt_ = zeros(0,1)
        
        % x values; array size [sum(npnt),1]
        x_ = zeros(0,1)
        
        % Normalised values of pdf; array size [sum(npnt),1]
        f_ = zeros(0,1)
        
        % Normalised cumulative distribution function; array size [sum(npnt),1]
        % A(i) is the cdf up to x(i); A(1)=0 and A(npnt)=1
        A_ =  zeros(0,1)
        
        % cdf offset by pdf index number; array size [sum(npnt),1]
        Acum_  = zeros(0,1)
        
        % Gradient m(i) = (f(i+1)-f(i))/(x(i+1)-x(i)); array size [sum(npnt),1]
        % Each distribution has npnt-1 entries; excess ones are set to NaN
        m_  = zeros(0,1)
    end
    
    properties (Dependent)
        % Number of probability distribution functions
        npdf
        
        % Number of points in each of the probability distribution functions (column vector)
        npnt
        
        % True or false according as the object containing one or more pdfs or not
        filled

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
            
            if nargin>0
                if isa(pdf,'pdf_table')
                    if numel(pdf)==0
                        error('Empty pdf_table object array is not permitted')
                    end
                    if ~all(arrayfun(@(x)(x.filled),pdf(:)))
                        error('Not all pdf_table objects are filled - cannot make a table array')
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
            
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.npdf(obj)
            val=numel(obj.npnt_);
        end
        
        function val=get.npnt(obj)
            val=obj.npnt_;
        end

        function val=get.filled(obj)
            val=(numel(obj.npnt_)>0);
        end

        %------------------------------------------------------------------
    end
end

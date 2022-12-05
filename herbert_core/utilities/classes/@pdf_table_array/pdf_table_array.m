classdef pdf_table_array < serializable
    % Array of one-dimensional probability distribution functions
    %
    % A pdf_table_array object is created from an array of pdf_table objects.
    % Its internal structure optimises the speed of random sampling from that
    % array when random samples are required for a large list of indices into
    % the array, one random point per index.
    %
    % The case when one needs to do this is when the length of the index
    % array is much greater than the number of elements in the pdf_table
    % array. For example, if the number of tables is 100, and the number
    % of indicies is 1e6 (so the index array contains 1e6 values each of
    % which is in the range 1 to 100 in this case, but which may be in any
    % order):
    %
    % Useage:
    % -------
    % If pdf is an array of pdf_table objects, and ind is a large array of
    %  indices into pdf, then replace:
    %
    %   X = zeros(1,numel(ind));
    %   for i=1:numel(ind)
    %       X(i) = rand(pdf(ind(i)))
    %   end
    %
    % with:
    %   pdfarr = pdf_array(pdf);
    %     :
    %   X = rand_ind(pdfarr, ind)
    %
    %
    % pdf_table_array Methods:
    %   pdf_table_array - constructor
    %   rand_ind        - generate random numbers from the pdf_table_array
    %
    %
    % Relationship with pdf_table_lookup and object_lookup:
    % -----------------------------------------------------
    % If you already have an array of one-dimensional probability distributions in
    % the form of pdf_table objects from which you want to draw a large
    % number of random points simultaneously, then create a pdf_table_array
    % object.
    %
    % If you have a large collection of objects which have a method pdf_table
    % that creates a one-dimensional probability distribution table and you
    % do not want to evaluate any other properties of the array of objects,
    % then create a pdf_lookup_table object. It has a further optimisation that
    % reduces memory use.
    %
    % Mostly however, if you have a large collection of objects then the best option
    % is to create an object_lookup object. This gives speed and memory advantages
    % for all methods of your objects. See the help for pdf_table_lookup and
    % object_lookup for more details.
    %
    % See also pdf_table pdf_table_lookup

    properties (Access=private)
        % Class version number
        class_version_ = 1;

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
        % Number of probability distribution functions (numel(npnt)
        npdf

        % Number of points in each of the probability distribution functions (column vector)
        npnt

        % True or false according as the object containing one or more pdfs or not
        filled
        % cellarray of the data defining the distribution function (all x
        % coordinates, all f-values and the array of number of points in
        % each distribution
        dist_functions;
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
            %          (See <a href="matlab:help('pdf_table');">pdf_table</a> for details)
            %
            % Output:
            % -------
            %   obj     pdf_table_array object

            if nargin ~=1
                return
            end
            if isstruct(pdf)
                % Assume trying to initialise from a structure array of properties
                obj = pdf_table_array.loadobj(pdf);
            else
                obj.dist_functions = pdf;
            end
        end
        function obj = set.dist_functions(obj,val)
            obj = set_dist_functions_(obj,val);
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
        function df = get.dist_functions(obj)
            df = {obj.x_,obj.f_,obj.npnt_};
        end
        % Generate random numbers from a set of probability distributions
        X = rand_ind (obj, ind)
    end

    %======================================================================
    % Serializable interface
    methods
        %------------------------------------------------------------------
        function flds = saveableFields(~)
            % Return cellarray of independent properties of the class
            %
            flds = {'dist_functions'};
        end

        function ver = classVersion(~)
            ver = 2;
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
            if isfield(inputs,'class_version_') && inputs.class_version_ == 1
                inputs = rmfield(inputs,'class_version_');
                obj = loadobj_private_v1_ (obj,inputs);
                return;
            end
            obj = from_old_struct@serializable(obj,inputs);

        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = pdf_table_array();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------

    end
end

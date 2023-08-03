classdef pdf_table_lookup < serializable
    % Optimised lookup table of one dimensional probability distribution functions for a set of objects
    %
    % The purpose of this class is twofold:
    %
    %   (1) To minimise the memory requirements and creation time for the pdfs by
    %       creating pdf tables only for unique instances of the objects in the
    %       set of arrays;
    %   (2) to optimise  the speed of selection of random numbers for an array of
    %       indices into one of the original object arrays. The optimisation arises
    %       when the array contains large numbers of repeated indices,
    %       that is, when the number of indices is much larger than the number
    %       of unique objects.
    %
    % For an instance of this class to be created, there must be a method of the
    % input object call pdf_table that returns a <a href="matlab:help('pdf_table');">pdf_table object</a>.
    % This creates a probability distribution function lookup table for the object.
    %
    %
    % Relationship to object_lookup:
    % ------------------------------
    % This class is similar to <a href="matlab:help('object_lookup');">object_lookup</a>
    % That class is more general because it supports random sampling that results
    % in a vector or array e.g. when the object method rand suplies a set of
    % points in 3D volume. This class provides random sampling from a one-
    % dimensional probability distribution function only.
    %
    % Generally, it is better to create an object_lookup object from your set of objects
    % as it is more general, offering optimised evaluation of other properties than just
    % randomly sampling distributions.
    %
    % The reason for using this class rather than object_lookup is when all of
    % the following apply:
    %   (1) The pdf is one dimensional and there is an object method called pdf_table;
    %   (2) Random numbers are expensive to evaluate and the object does not have an
    %       internal cache of the pdf;
    %   (3) No other function evaluation on the originating objects is going to be
    %       needed.
    %
    % See also object_lookup

    properties (Access=private)
        % Class version number
        class_version_ = 1;

        % pdf_table_array object containing the unique probability distribution functions
        pdf_table_array_ = pdf_table_array()

        % Index array (column vector)
        % Cell array of indices into the pdf_table_array object, where
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_ = zeros(0,1)

        method_set_ = false(1,2);
    end

    properties (Dependent)
        % pdf_table_array object containing the unique probability distribution functions
        % For details <a href="matlab:help('pdf_table_array');">Click here</a>
        pdf

        % Cell array (column vector) of indices into the pdf_table_array object.
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx

        % True or false according as the object containing one or more pdfs or not
        filled
    end
    properties(Dependent,Hidden)
        % hidden property used by serializable interface to store/restore
        % indexes
        indx_to_save
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = pdf_table_lookup (objects)
            % Create sampling_table object for an array of objects
            %
            %   >> obj = pdf_table_lookup (objects)
            %
            % Input:
            % ------
            %   objects     Object array, or cell array of object arrays.
            %               There must be a method call pdf_table which
            %              returns a pdf_table object for the object.
            %
            % Output:
            % -------
            %   obj     pdf_table_lookup object

            if nargin==1 && isstruct(objects)
                % Assume trying to initialise from a structure array of properties
                obj = pdf_table_lookup.loadobj(objects);
            elseif nargin>0
                obj.pdf = objects;
            end

        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.pdf(obj)
            val=obj.pdf_table_array_;
        end

        function val=get.indx(obj)
            val=obj.indx_;
        end

        function val=get.filled(obj)
            val = obj.pdf_table_array_.filled;
        end
        %------------------------------------------------------------------
        function obj = set.pdf(obj,val)
            if isa(val,'pdf_table_array')
                obj.pdf_table_array_ = val;
                obj.method_set_(1) = true;
            else
                obj = set_pdf_array_as_input_(obj,val);
                obj.method_set_ = true(1,2);
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end

        end
    end
    %======================================================================
    methods
        % SERIALIZABLE INTERFACE
        %------------------------------------------------------------------
        function val =get.indx_to_save(obj)
            val = obj.indx_;
        end
        function obj =set.indx_to_save(obj,val)
            if ~iscell(val)
                error('HERBERT:pdf_table_lookup:invalid_argument', ...
                    'lookup indexes have to be cellarray of numeric indexes')
            end
            obj.indx_ =  val;
            obj.method_set_(2) = true;
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg();
            end
        end
        %
        function ver = classVersion(~)
            ver = 2;
        end
        function flds = saveableFields(~)
            % Return cellarray of public property names, which fully define
            % the state of the pdf_table_lookup object, so when the property
            % values are provided, the object can be fully restored from
            % these values.
            %
            flds = {'pdf','indx_to_save'};
        end
        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not
            if any(obj.method_set_)
                if ~all(obj.method_set_)
                    flds = obj.saveableFields();
                    error('HERBERT:pdf_table_lookup:runtime_error', ...
                        ['you can not set up only indexes or only pdf_array.\n' ...
                        ' One needs to set up: %s. The property: %s has not been set'],...
                        disp2str(flds),disp2str(flds(~obj.method_set_)) );
                end
            end
        end
    end
    methods(Access=protected)
        %------------------------------------------------------------------
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            inputs = convert_old_struct_(obj,inputs);
        end
    end

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = pdf_table_lookup();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end


end

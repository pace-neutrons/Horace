classdef pdf_table_lookup
    % Create a sampling table for a set of arrays of objects. The purpose of this class
    % is to create a lookup table to optimise the speed of selection of random numbers 
    % from the probability distributions associated with each object in each array of
    % objects while retaining simple use in code. The optimisation arises from the fact
    % that in typical use many of the objects will be repeated, which enables fast
    % sampling from a pdf_table_array object into which the objects are indexed.
    %
    % For an instance of this class to be created, there must be a method of the input
    % object call pdf_table that returns a pdf_table object for the object.
    %
    % This class is similar to <a href="matlab:help('object_lookup');">object_lookup</a>
    % That class is more general because it supports random sampling that results in a
    % vector or arrays e.g. when the object method rand suplies a set of points in 3D volume
    % This class provides random sampling from a one-dimensional probability distribution
    % function only.
    
    properties (Access=private)
        % pdf_table_array object
        pdf_table_array_
        
        % Index array (column vector)
        % Cell array of indicies into the pdf_table_array object, where
        % ind{i} is a column vector of indicies for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_
    end
    
    properties (Dependent)
        % pdf_table_array object
        % For details <a href="matlab:help('pdf_table_array');">Click here</a>
        pdf
        
        % Cell array of indicies into the pdf_table_array object.
        % ind{i} is a column vector of indicies for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function this = pdf_table_lookup (objects)
            % Create sampling_table object for an array of objects
            %
            %   >> this = pdf_table_lookup (objects)
            %
            % Input:
            % ------
            %   objects     Object array, or cell array of object arrays.
            %               There must be a method call pdf_table which
            %              returns a pdf_table object for the object.
            
            % Make a cell array for convenience, if not already
            if ~iscell(objects)
                objects = {objects};    
            end
            
            % Check all arrays have the same class - requirement for sorting later on
            if numel(objects)>1
                class_name = class(objects{1});
                tf = cellfun(@(x)(strcmp(class(x),class_name)),objects);
                if ~all(tf)
                    error('The classes of the object arrays are not all the same')
                end
            end
            
            % Check existence of public property called 'pdf' that is a scalar pdf_table object
            if ~ismethod(objects{1},'pdf_table')
                error('A method with name pdf_table does not exist')
            end

            % Assemble the objects in one array and get unique entries
            nw = numel(objects);
            nel = cellfun(@numel,objects(:));
            if any(nel==0)
                error('Cannot have any empty object arrays')
            end
            nend = cumsum(nel);
            nbeg = nend - nel + 1;
            ntot = nend(end);
            
            obj_all=repmat(objects{1}(1),[ntot,1]);
            for i=1:nw
                obj_all(nbeg(i):nend(i))=objects{i}(:);
            end
            [obj_unique,~,ind] = uniqueObj(obj_all);
            pdf_arr = arrayfun(@pdf_table,obj_unique);
            this.pdf_table_array_ = pdf_table_array(pdf_arr);
            this.indx_ = mat2cell(ind,nel,1);
            
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.indx(obj)
            val=obj.indx_;
        end
        function val=get.pdf(obj)
            val=obj.pdf_table_array_;
        end
            
        %------------------------------------------------------------------
        function X = rand_ind (this, varargin)
            % Generate random numbers from the pdf
            %
            %   >> X = rand_ind (this, iarray, ind)
            %   >> X = rand_ind (this, ind)
            %
            % Input:
            % ------
            %   this        Sampling_table object
            %
            %   iarray      Scalar index of the original object array from the
            %              cell array of object arrays from which the sampling_table
            %              was created.
            %               If there was only one object array, then this is not
            %              necessary (as it assumed iarray=1)
            %
            %   ind         Array containing the probability distribution function
            %              indicies from which a random number is to be taken.
            %              min(ind(:))>=1, max(ind(:))<=number of objects in the
            %              object array selected by iarray
            %
            % Output:
            % -------
            %   X           Array of random numbers, with the same size as ind.
            
            if numel(varargin)==2
                iarray = varargin{1};
                if ~isscalar(iarray)
                    error('Index to original object array, ''iarray'', must be a scalar')
                end
                ind = varargin{2};
            elseif numel(varargin)==1
                if numel(obj.indx_)==1
                    iarray = 1;
                    ind = varargin{1};
                else
                    error('Must give index to the object array from which samples are to be drawn')
                end
            else
                error('Insufficient number of input arguments')
            end
            
            X = rand_ind (this.pdf_table_array_, this.indx_{iarray}(ind));
            
        end
        %------------------------------------------------------------------
    end
end

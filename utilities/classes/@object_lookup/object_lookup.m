classdef object_lookup
    % Create an object sampling table for a set of arrays of objects. The purpose of this
    % class is to optimise the speed of selection of random points from a method of the
    % object with name rand. The optimisation is achieved by creating a lookup table of
    % unique instances of the objects with associated indexing from the input arrays of
    % objects. The optimisation arises from the fact that in typical use many of the objects
    % will be repeated.
    %
    % For an instance of this class to be created, there must be a method of the input
    % object call rand that returns random points from the object.
    %
    % This class is similar to <a href="matlab:help('pdf_table_lookup');">pdf_table_lookup</a>
    % That class provides random sampling from a one-dimensional probability distribution
    % function. This class in more general because random sampling that results in a vector or
    % arrays is supported e.g. when the object method rand suplies a set of points in 3D volume
    
    properties (Access=private)
        % Object array (column vector)
        object_array_
        % Index array (column vector)
        % Cell array of indicies into the object_array_, where
        % ind{i} is a column vector of indicies for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_
    end
    
    properties (Dependent)
        % Object array of unique instance of objects in the input array or cell array
        object_array
        
        % Cell array of indicies into object_array.
        % ind{i} is a column vector of indicies for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function this = object_lookup (objects)
            % Create object lookup from an array of objects
            %
            %   >> this = object_lookup (objects)
            %
            % Input:
            % ------
            %   objects     Object array, or cell array of object arrays

            
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
            this.object_array_ = obj_unique;
            this.indx_ = mat2cell(ind,nel,1);
            
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val=get.indx(obj)
            val=obj.indx_;
        end
        
        function val=get.object_array(obj)
            val=obj.object_array_;
        end
        
        %------------------------------------------------------------------
    end
end

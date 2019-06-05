classdef pdf_table_lookup
    % Create a lookup table of probability distribution functions for a set of object arrays
    % The purpose of this class is twofold:
    %
    %   (1) to minimise the memory requirements and creation time for the pdfs by
    %       creating pdf tables only for unique instances of the objects in the
    %       set of arrays;
    %   (2) to optimise  the speed of selection of random numbers for an array of
    %       indices into one of the original object arrays. The optimisation arises
    %       when the array contains large numbers of repeated indices.
    %
    % For an instance of this class to be created, there must be a method of the
    % input object call pdf_table that returns a <a href="matlab:help('pdf_table');">pdf_table object</a>.
    % This creates a probability distribution function lookup table for the object.
    %
    % This class is similar to <a href="matlab:help('object_lookup');">object_lookup</a>
    % That class is more general because it supports random sampling that results
    % in a vector or array e.g. when the object method rand suplies a set of
    % points in 3D volume. This class provides random sampling from a one-
    % dimensional probability distribution function only.
    %
    % The reason for using this class rather than object_lookup is when all of
    % the following apply:
    %   (1) the pdf is one dimensional
    %   (2) random numbers are expensive to evaluate and so creating a lookup
    %       table will save time in the long run
    %   (3) access to the originating class properties is not going to be
    %       required
    %
    % See also pdf_table object_array
    
    properties (Access=private)
        % pdf_table_array object containing the unique probability distribution functions
        pdf_table_array_ = pdf_table_array()
        
        % Index array (column vector)
        % Cell array of indices into the pdf_table_array object, where
        % ind{i} is a column vector of indices for the ith object array.
        % The length of ind{i} = number of objects in the ith object array
        indx_ = zeros(0,1)
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
            
            if nargin>0
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
                
                % Assemble the objects in one array
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
                
                % Get unique entries
                if fieldsNumLogChar (obj_all, 'indep')
                    [obj_unique,~,ind] = uniqueObj(obj_all);    % simple object
                else
                    [obj_unique,~,ind] = genunique(obj_all,'resolve','indep');
                end
                
                % Compute pdf table array and lookup indexing
                pdf_arr = arrayfun(@pdf_table,obj_unique);
                obj.pdf_table_array_ = pdf_table_array(pdf_arr);
                obj.indx_ = mat2cell(ind,nel,1);
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
        
        %------------------------------------------------------------------
    end
end

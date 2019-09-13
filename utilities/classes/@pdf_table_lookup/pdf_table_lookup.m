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
    % See also pdf_table pdf_table_array object_lookup
    
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
            
            if nargin==1 && isstruct(objects)
                % Assume trying to initialise from a structure array of properties
                obj = pdf_table_lookup.loadobj(objects);
                
            elseif nargin>0
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
        
        function val=get.filled(obj)
            val = obj.pdf_table_array_.filled;
        end

        %------------------------------------------------------------------
    end

    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
        %------------------------------------------------------------------
        function S = saveobj(obj)
            % Method used my Matlab save function to support custom
            % conversion to structure prior to saving.
            %
            %   >> S = saveobj(obj)
            %
            % Input:
            % ------
            %   obj     Scalar instance of the object class
            %
            % Output:
            % -------
            %   S       Structure created from obj that is to be saved
            
            % The following is boilerplate code
            
            S = structIndep(obj);
        end
    end
    
    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

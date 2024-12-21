classdef hashable < serializable
    %
    properties (Access=protected)
        hash_value_ = [];
    end
    properties(Dependent,Hidden)
        % expose internal hash_value_ value for debugging purposes
        hash_value;

        % returns true if hash have been calculated and stored with the object
        % and false otherwise.
        hash_defined; % Provided to simplify possible future hash
        % type replacement, e.g. from char value to uint64 or something
        % similar.
    end

    %---------------------------------------------------------------------------
    %   INTERFACE
    %---------------------------------------------------------------------------
    %   Convert object or array of objects to/from a structure
    %---------------------------------------------------------------------------
    methods
        function flds = hashableFields(obj)
            % function provides set of fields which define hash. By
            % default, equal to saveableFields, but different to give
            % possibility to overload.
            %
            % for example, you may want to store object creation date but
            % want to consider two objects with different creation dates
            % to be the same for data comparison purpose.
            %
            flds = obj.saveableFields();
        end
        function obj = clear_hash(obj)
            % function clears the hash value, stored with the object.
            % Provided as part of interface and should be used
            % to allow simple replacement of hash implementation if we
            % decide to use different hash type in a future.
            obj.hash_value_ = [];
        end
        function val = get.hash_value(obj)
            val = obj.hash_value_;
        end
        function is = get.hash_defined(obj)
            is  = ~isempty(obj.hash_value_);
        end

        function S = to_struct (obj)
            % overload to_struct to add hash to it if hash was available
            S = to_struct@serializable(obj);
            % attach hash value to the resulting structure
            S.hash_value = arrayfun(@(x)x.hash_value_,obj,'UniformOutput',false);
        end

        function [obj,bytestream] = to_hashable_array(obj)
            % Function extracts distinguishable information from the
            % object to use as the basis for the hash which describes this
            % object.
            % Extracts and converts into byte-stream the values of fields,
            % provided by hashableFields method.
            % Input:
            %  obj  --  Object or array of objects which are hashable
            % Returns:
            %  obj  --  input object,modified if has children hashable
            %           objects. These objects have their hashes calculated
            %           recursively.
            %  arr  --  uint8 array of unique data -- basis for building
            %           unique object hash.

            [obj,bytestream] = to_hashable_array_(obj);
        end
        function [obj,hash,is_calculated] = build_hash(obj)
            % Class specific calculation of hash if it is not already present
            % in this object. If it is present, it returns existing value
            % of the hash and unchanged object.
            %
            % Inputs:
            % obj -- hashable object or array of objects
            % Returns:
            % obj  -- hashable object or array of objects with hash value(s)
            %         stored in hash_value_  property(ies).
            % hash -- the value of hash, defining state of the object.
            %         or cellarray of hashes for all objects in array.
            % is_calculated
            %      -- if true, the hash value(s) were calculated at least
            %         for some objects in the array or structure of objects.
            %         If false, all objects have hashes, already attached
            %         to it so the function have returned the stored value.
            %
            nobj = numel(obj);
            is_calculated = false(1,nobj);
            hash = cell(1,nobj);
            for i=1:numel(obj)
                [obj(i),hash{i},is_calculated(i)] = build_single_hash_(obj(i));
            end
            is_calculated = any(is_calculated);
            if numel(hash) == 1
                hash = hash{1};
            end
        end
    end

    methods (Static)
        function obj = from_struct (S, varargin)
            % overload from_struct to restore object and set its hash
            % if hash was present in the structure
            obj = serializable.from_struct(S,varargin{:});
            if isfield(S,'hash_value') % protection against old hashable
                % objects stored without hash values
                hash = S.hash_value;
                for i=1:numel(hash)
                    obj(i).hash_value_ = hash{i};
                end
            end
        end
    end

    %---------------------------------------------------------------------------
    %   Testing equality of hashable objects
    %---------------------------------------------------------------------------
    methods
        % Return logical variable stating if two serializable objects are equal
        % or not
        iseq = eq (obj1, obj2)

        % Return logical variable stating if two serializable objects are
        % unequal or not
        isne = ne (obj1, obj2)
    end
    methods(Access=protected)
        function [iseq,mess]  = equal_to_tol_single(obj,other_obj,opt,varargin)
            % internal procedure used by equal_to_toll method to compare
            % single pair of hashable objects. 
            % 
            % Overloads similar one in serializable class.
            %
            % Input:
            % obj       -- first object to compare
            % other_obj -- second object to compare
            % opt       -- the structure containing fieldnames and their
            %              values as accepted by generic equal_to_tol
            %              procedure or retruned by
            %              process_inputs_for_eq_to_tol function
            %
            % Returns:
            % iseq      -- logical containing true if objects are equal and
            %              false otherwise.
            % mess      -- char array empty if iseq == true or containing
            %              more information on the reason behind the
            %              difference if iseq == false
            [iseq,mess]  = equal_to_tol_single_(obj,other_obj,opt,varargin{:});
        end
    end

    %---------------------------------------------------------------------------
    %   Object validation
    %---------------------------------------------------------------------------
    methods
        function obj = check_combo_arg (obj)
            % overload check_combo_arg. Normally arguments have changed
            % so existing hashes should be destroyed. If they are not,
            % overload this function for your class appropriately
            obj = check_combo_arg@serializable(obj);
            obj = obj.clear_hash();
        end
    end
end

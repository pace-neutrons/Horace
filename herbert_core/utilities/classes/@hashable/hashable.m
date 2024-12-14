classdef hashable < serializable
    %
    properties (Access=protected)
        hash_value_ = [];
    end
    properties(Dependent,Hidden)
        % expose internal hash_value_ value for debugging purposes
        hash_value;
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
        function val = get.hash_value(obj)
            val = obj.hash_value_;
        end

        function S = to_struct (obj)
            % overload to_struct to add hash to it if hash was available
            S = to_struct@serializable(obj);
            % make hash value
            S.hash_value = arrayfun(@(x)x.hash_value_,obj,'UniformOutput',false);
        end

        function [obj,bytestream] = to_hashable_array(obj)
            % Function extracts distignuishable information from the
            % object to use as the basis for the hash which describes this
            % object.
            % Extracts and converts into bytestream the values of fields,
            % provided by hashableFields method.
            % Input:
            %   obj -- Object or array of objects which are hashable
            % Returns:
            %  obj  --  input object,modified if has children hashable
            %           objects. These objects have their hashes calculated
            %           recursively.
            %  arr  --  uint8 array of unique data -- basis for building
            %           unique object hash.

            [obj,bytestream] = to_hashable_array_(obj);
        end
        function [obj,hash,is_calculated] = build_hash(obj)
            % Class specific calculation of hash if it is not available
            % for this object
            %
            % Inputs:
            % obj -- hashable object or array of objects
            % Returns:
            % obj  -- hashable object or array of objects with hash value(s)
            %         stored in hash_value_  property(ies).
            % hash -- the value of hash, defining state of the object.
            %         or cellaray of hashes for all objects in array.
            % is_calculated
            %      -- if true, the hash value(s) were calculated at least
            %         for some objects in the array,
            %         If false, all objects have hashes, already attached
            %         to it so the function have returned stored value.
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
            if isfield(S,'hash_value') % protection agains old hashable
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

    %---------------------------------------------------------------------------
    %   Object validation
    %---------------------------------------------------------------------------
    methods
        function obj = check_combo_arg (obj)
            % overload check_combo_arg. Normally arguments have changed
            % so existihg hashes should be destroyed. If they are not,
            % overload this function for your class appropriately
            obj = check_combo_arg@serializable(obj);
            obj.hash_value_ = [];
        end
    end
end

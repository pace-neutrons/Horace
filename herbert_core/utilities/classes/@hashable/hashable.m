classdef hashable < serializable
    %
    properties (Access=protected)
        hash_value_ = []
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
            if numel(obj)>1
                for i=1:numel(obj)
                    S.array_dat(i).hash_value = obj(i).hash_value_;
                end
            else
                if ~isempty(obj.hash_value_)
                    S.hash_value = obj.hash_value_;
                end
            end
        end
        function [obj,bytestream] = to_hashable_array(obj)
            % Function which extracts distignuishable information from the
            % object to use as basis for the hash which describes this
            % object.
            [obj,bytestream] = to_hashable_array_(obj);
        end


        function [obj,hash,is_calculated] = build_hash(obj)
            % calculate hash if it not available
            % Inputs:
            % obj -- hashable object
            % Returns:
            % obj  -- hashable object with hash value stored inside
            % hash -- value of hash, defining state of the object
            % is_calculated
            %      -- if true, the hash value was calculated for the
            %         object. If false, object have hash, already attached
            %         to it so the only thing we did was restoring this
            %         hash.
            is_calculated = false;
            if ~isempty(obj.hash_value_)
                hash = obj.hash_value_;
                return;
            end
            is_calculated = true;
            [obj,bytestream] = to_hashable_array(obj);
            [~,hash] = build_hash(bytestream);
            obj.hash_value_ = hash;
        end
    end

    methods (Static)
        function obj = from_struct (S, varargin)
            % overload from_struct to restore hash if available
            obj = serializable.from_struct(S,varargin{:});
            if numel(obj)>1
                for i=1:numel(obj)
                    if isfield(S.array_dat(i),'hash_value')
                        obj(i).hash_value_ = S.array_dat(i).hash_value;
                    end
                end
            else
                if isfield(S,'hash_value')
                    obj.hash_value_ = S.hash_value;
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

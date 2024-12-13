classdef hashable < serializable
    %

    properties (Access=protected)
        hash_value_ = []
    end

    %---------------------------------------------------------------------------
    % Constructor
    %---------------------------------------------------------------------------
    methods
        function obj = hashable()
            % Class constructor.
            % Does nothing except enable methods of the base serializable class
            % to be accessed.
        end
    end

    %---------------------------------------------------------------------------
    %   INTERFACE
    %---------------------------------------------------------------------------
    %   Convert object or array of objects to/from a structure
    %---------------------------------------------------------------------------
    methods
        function flds = hashingFields (obj)
            % function provides set of fields which define hash. By
            % default, eqyak ti saveableFields, but different to give
            % possibility to overload
            flds = obj.saveableFields();
        end

        function S = to_struct (obj)
            % overload to_struct to add hash to it if hash was available
            S = to_struct@serializable(obj);
            if ~isempty(obj.hash_value_)
                S.hash_value = obj.hash_value_;
            end
        end
        function [obj,bytestream] = to_hashable_array(obj)
            % Function which extracts distignuishable information from the
            % object to use as basis for the hash which describes this
            % object.
            [obj,bytestream] = to_hashable_array_(obj);
        end


        function [obj,hash] = build_hash(obj)
            % calculate hash if it not available
            if ~isempty(obj.hash_value_)
                hash = obj.hash_value_;
                return;
            end
            [obj,bytestream] = to_hashable_array(obj);
            use_mex = config_store.instance().get_value('hor_config','use_mex');
            persistent Engine;
            % In case the java engine is going to be used, initialise it as
            % a persistent object

            if use_mex
                % mex version to be used, use it
                hash = GetMD5(bytestream);
            else

                if isempty(Engine)
                    Engine = java.security.MessageDigest.getInstance('MD5');
                end


                % mex version not to be used, manually construct from the
                % Java engine
                Engine.update(bytestream);
                hash0 = Engine.digest;

                %using the following typecast to remedy that dec2hex
                %does not work with negative numbers before Matlab 2020b.
                %the typecast moves negative numbers to twos-complement
                %positive representation, as is automatically done by the
                %later dec2hex
                hash1 = typecast(hash0,'uint8');

                hash2 = dec2hex(hash1);
                hash3 = cellstr(hash2);
                hash4 = horzcat(hash3{:});
                hash = lower(hash4); % reduces hash !
            end
        end
    end

    methods (Static)
        function obj = from_struct (S, varargin)
            % overload from_struct to restore hash if available
            obj = serializable.from_struct(S,varargin{:});
            if isfield(S,'hash_value')
                obj.hash_value_ = S.hash_value;
            end
        end
    end


    %---------------------------------------------------------------------------
    %   Testing equality of serializable objects
    %---------------------------------------------------------------------------
    methods
        % Return logical variable stating if two serializable objects are equal
        % or not
        [iseq, mess] = eq (obj1, obj2, varargin)

        % Return logical variable stating if two serializable objects are
        % unequal or not
        [isne, mess] = ne (obj1, obj2, varargin)
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

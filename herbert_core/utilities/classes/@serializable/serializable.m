classdef (Abstract=true) serializable
   
    properties (Dependent, Hidden)
        % this is property for developers who wants to change number of
        % interdependent properties one after another and do not want to
        % overload the class. Use with caution, as you may get invalid
        % object if the property is used incorrectly.
        % It is also necessary to use when building and checking validity
        % of serializable object from other serializable objects. In this
        % case, set_do_check_combo_arg have to be overloaded appropriately.
        do_check_combo_arg;
    end

    properties (Access=protected)
        % Check interdependent properties and throw exception if
        % de-serialized object validation shows that object is invalid
        % Set it to "false" when changing
        do_check_combo_arg_ = true;
    end

    %---------------------------------------------------------------------------
    % Constructor
    %---------------------------------------------------------------------------
    methods
        function obj = serializable()
            % Class constructor. Does nothing except enable static methods of
            % the base serializable class to be accessed
        end
    end
        
    %---------------------------------------------------------------------------
    %   ABSTRACT INTERFACE TO DEFINE IN CHILD CLASS
    %---------------------------------------------------------------------------
    methods (Abstract, Access=public)
        % Returns the version number of the class to store.
        % It is assumed that Each new version would presumably read
        % the older version, so version substitution is based on this
        % number
        ver = classVersion (obj)

        % Return cellarray of public property names, which fully define
        % the state of a serializable object, so when the field values are
        % provided, the object can be fully restored from these values.
        %
        flds = saveableFields (obj)
    end


    %---------------------------------------------------------------------------
    %   INTERFACE
    %---------------------------------------------------------------------------
    %   Convert object or array of objects to/from a structure
    %---------------------------------------------------------------------------
    methods
        % Convert a serializable object or array of objects into a structure
        % The output is a structure array representation of the object array.
        S = to_bare_struct (obj, varargin)

        % Convert a serializable object or array of objects into a structure
        % that includes fields with the class name and version, together with
        % either:
        % - the fields of the object (if scalar object)
        % - a field called array_dat which is an array structure (if object array)
        S = to_struct (obj)

        % Restore object or object array from a structure created by to_bare_struct
        % The input object defines the object class to be recovered, and any
        % missing fields if recovering from an incomplete structure.
        obj = from_bare_struct (obj_template, S)
    end

    methods (Static)
        % Restore object or object array from a structure created by to_struct.
        % The optional input object over-rides the object class type held in the
        % structure, and provides any missing fields if recovering from an
        % incomplete structure.
        obj = from_struct (S, obj_template)
    end

    methods (Access=protected)
        % Restore object from a structure which describes earlier versions of an
        % object. 
        % Overload this method for the class you are writing to be able
        % to read old structures.
        obj = from_old_struct (obj_template, S)
    end


    %---------------------------------------------------------------------------
    %   Save/load object or array of objects to file
    %---------------------------------------------------------------------------
    methods
        % Used by Matlab to perform conversion to the custom serializable
        % structure prior to saving with the Matlab intrinsic save function.
        S = saveobj (obj)
    end

    methods (Static)
        % Used by Matlab to restore an object or array of objects using the
        % Matlab intrinsic load function.
        obj = loadobj (S, varargin)
    end


    %---------------------------------------------------------------------------
    %   Serialization or deserialization of object or array of objects
    %---------------------------------------------------------------------------
    methods
        % Serialize an object or array of objects
        byte_array = serialize (obj)

        % Return the size of the serialized object
        [nbytes, S] = serial_size (obj)
    end

    methods (Static)
        % Recover an object or array of objects that were serialized using the
        % method serialize
        [obj, nbytes] = deserialize (byte_array, pos)
    end

  






    methods

        obj = check_combo_arg (obj)

        [iseq, mess] = eq (obj, other_obj, varargin)

        [isne, mess] = ne (obj, other_obj, varargin)

    end


    methods
        % Developer property. Intended for creating algorithms, which
        % change bunch of interdependent properties one after another
        % without overloading the class.
        % Set this property to false at the beginning, change interdependent
        % properties, run check_combo_arg after setting all interdependent
        % properties to its values so if check_combo_arg throws the error,
        % the interdependent properties are inconsistent and the object is
        % invalid.
        function obj = set.do_check_combo_arg(obj,val)
            %use set function to be able to overload this method by children
            obj = set_do_check_combo_arg(obj,val);
        end

        function do = get.do_check_combo_arg(obj)
            do = obj.do_check_combo_arg_;
        end
    end

    
    methods(Access=protected)
        [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                positional_param_names_list, old_keyval_compat, varargin)

        function obj = set_do_check_combo_arg(obj,val)
            % overloadable setters for checking interdependent properties.
            % May be overloaded by children for example to change the check
            % in compositing properties which values are in turn
            % serializable
            obj.do_check_combo_arg_ = logical(val);
        end
        %------------------------------------------------------------------


    end
end

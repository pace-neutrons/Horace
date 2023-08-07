classdef (Abstract=true) serializable
    % Introduction
    % ------------
    % The serializable class defines a common interface to a class for saving and
    % loading an object or array of objects, both to/from Matlab .mat files and
    % to/from a serialized stream of bytes.
    %
    % The benefits of using the interface are that:
    % (1) It has a framework for managing class version numbering that simplifies
    %    the implementation of backwards compatibility with earlier version of a
    %    class;
    % (2) It defines a protocol for validation of class properties, and utility
    %    functions that simplify the writing of class constructors with a
    %    standardised syntax;
    % (3) The common interface to .mat file I/O and bytestream serialisation
    %    simplifies the development of sophisticated data I/O management of classes
    %    with a complex hierarchy of composition and inheritance, such as the Horace
    %    sqw class.
    %
    % The seriablizable class is an abstract class that needs to be inherited by any
    % class that wants to use these features. In general, it should be the default
    % choice for Horace classes.
    %
    %
    % Class requirements
    % ------------------
    % The following must be satisfied by a class if it is to inherit serializable:
    %
    % (1) The class constructor must be callable with no arguments, in which case it
    %    must create a create a valid instance of the class.
    %
    % (2) There must be a subset of the public properties which fully define the
    %    class state. The set methods for those properties must enable an object to
    %    be created by being called in an arbitrary sequence. (Note: the full set of
    %    public properties may be larger; it is only a subset which is required to
    %    fully define the object.)
    %     Any interdependencies between the values of those properties that need to
    %    be satisfied for the object to be valid will need to be checked outside the
    %    individual property set methods. The serializable class includes a
    %    validation interface that makes this straightforward to implement. Details
    %    on how to do this are given below.
    %
    % (3) Two public methods must be provided:
    %    - A method that returns the class version number:
    %       EXAMPLE:
    %           function ver = classVersion (~)
    %               % Return the class version number
    %               ver = 2;
    %           end
    %
    %    - A method that returns a cell array with the names of the public fields
    %      that fully define the state of an object, and which therefore are the
    %      only fields that need to be saved:
    %       EXAMPLE:
    %           function flds = saveableFields (~)
    %               % Return cellarray of public properties defining the class
    %               flds = {'dia','height','wall','atms'};
    %           end
    %
    %
    % Validation of properties of a serializable object
    % -------------------------------------------------
    % To write a class that satisfies the requirements of properties and their
    % validation in item (2) of "Class requirements" above, use the serializable
    % validation interface as follows:
    %
    %   - Write a public method for your class called check_combo_arg that checks
    %     the mutual validity of interdependent properties, and throws an error
    %     they are not:
    %
    %           function obj = check_combo_arg (obj)
    %               :
    %
    %   - All interdependent properties setters in your class code must contain
    %     the check for validity of interdependent properties implemented as the
    %     following code block:
    %               :
    %           if obj.do_check_combo_arg_
    %               obj = check_combo_arg (obj);
    %           end
    %               :
    %
    % By default, do_check_combo_arg_ is set to true, so that the validation method
    % will be called. However, when loading an object from a .mat file or bytestream
    % serializable sets do_check_combo_arg_ to false before setting properties, and
    % only calls the method check_combo_arg after all properties are set. After this
    % validation do_check_combo_arg_ is reset to true.
    %
    % Your validation method check_combo_arg can be very flexible. For example
    %   - Update property values from the mutual interdepencies
    %   - Recompute any cached properties that are derived from the set properties,
    %     for example a probability distribution lookup table. Additional input
    %     arguments can be provided to check_combo_arg ensure that this is only
    %     done when necessary - for an example, see IX_fermi_chopper/check_combo_arg
    %
    % Serializable also provides a protected method to simplify the code of your
    % class constructor, called set_positional_and_key_val_arguments. It also
    % internally disables validation of interdependent properties until they have
    % all been set.
    %
    % Typically you only need to query the value of do_check_combo_arg_ in your
    % class set methods. Under some circumstances it may be useful to set it to
    % false, set multiple properties, and then reset do_check_combo_arg_ to true.
    % For an example see IX_moderator/set_mod_pulse.
    %
    %
    % Supporting older class versions
    % -------------------------------
    % When serializable objects are written to a bytestream or a .mat file, they are
    % first converted to a structure that also holds the class name and version
    % number. This information is used when recovering the original object.
    %
    % To be able to recover an object from an earlier class version, there are three
    % cases to consider:
    %
    % (1) In the simplest case of missing properties that can be set from the
    %   default property values in the current class. This is handled by
    %   serializable interface and no action is required.
    %
    % (2) In most other cases, all that is needed is to overload the default
    %   serializable method convert_old_struct so that customised conversion is
    %   performed for each of the previous supported class versions. For details see
    %   <a href="matlab:help('serializable/convert_old_struct');">convert_old_struct</a>.
    %
    % (3) If the design pattern for your class is particularly complex, it might be
    %   necessary to have a more sophisticated handling of earlier versions. This
    %   can be done by overloading the default method from_old_struct. For details, see
    %   <a href="matlab:help('serializable/from_old_struct');">from_old_struct</a>).
    %
    % In addition to whichever of the above three cases applies, if your class is
    % going to recover a class from a .mat file in  which the saved object is
    % sufficiently old that it was not based on the serializable class, then you
    % need to overload the loadobj method. In your class definition file, add the
    % following method, substituting the name of your class in place of "my_class"
    % but otherwise leaving the code unchanged:
    %
    %      :
    %   methods (Static)
    %       function obj = loadobj (S)
    %       % Boilerplate loadobj method, calling the generic loadobj method of
    %       % the serializable class
    %           obj = my_class();
    %           obj = loadobj@serializable (S, obj);
    %       end
    %   end
    %    :
    %
    %
    % --------------------------------------------------------------------------
    % Summary of methods a developer may need to customise
    % --------------------------------------------------------------------------
    % Serializable Methods:
    %
    % Required:
    %   classVersion    - Return the current class version number
    %   saveableFields  - Return the names of public properties which fully define the object state.
    %
    % If interdependent property values:
    %   check_combo_arg - Check validity of interdependent properties
    %
    % If reading older class versions, then overload:
    %   convert_old_struct - Update structure created from earlier class versions
    %   from_old_struct    - Update earlier structures in complex design patterns
    %                        (Declare as Access=protected)
    %   loadobj            - If an old class version pre-dates the serializable interface
    %                        (Declare as static; note: it is fixed boilerplate code)

    properties (Access=protected)
        % Flag to control validation checking of interdependent properties
        % - Set to false to disable interdependent property checks for child
        %   property setters
        % - Set to true to enable those checks
        do_check_combo_arg_ = true;
    end

    properties (Dependent, Hidden)
        % Developer property
        % - Use when you wants to change a number of interdependent properties
        %   one after another and do not want to overload the class. Use with
        %   caution, as you may get an invalid object if the property is used
        %   incorrectly.
        % - Use when building and checking the validity of a serializable object
        %   from other serializable objects. In this case, the method
        %   set_do_check_combo_arg has to be overloaded appropriately.
        do_check_combo_arg;
    end


    %---------------------------------------------------------------------------
    % Constructor
    %---------------------------------------------------------------------------
    methods
        function obj = serializable()
            % Class constructor.
            % Does nothing except enable methods of the base serializable class
            % to be accessed.
        end
    end

    %---------------------------------------------------------------------------
    %   ABSTRACT INTERFACE THAT MUST BE DEFINED IN CHILD CLASS
    %---------------------------------------------------------------------------
    methods (Abstract, Access=public)
        % Returns the current class version number.
        % It is presumed that each new version will be able to read older
        % versions. The version number is stored when the object is saved or
        % serialized, so conversion to the current version can be performed
        % based on this number.
        %
        % EXAMPLE:
        %       :
        %   methods
        %       function ver = classVersion(~)
        %           ver = 2;
        %       end
        %        :
        ver = classVersion (obj)

        % Return the names of public properties which fully define the object state.
        %
        % EXAMPLE:
        %       :
        %   methods
        %       function flds = saveableFields(~)
        %           flds = {'xaxis','yaxis','mosaic_pdf_string','parameters'};
        %       end
        %        :
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
        obj = from_struct (S, varargin)
    end

    methods (Access=protected)
        % Restore object from a structure which describes earlier versions of an
        % object.
        % Normally it is sufficient simply to overload convert_old_struct. If
        % the class design is particularly complex it may be necessary to
        % overload this method for the class you are writing to be able
        % to read old structures.
        obj = from_old_struct (obj_template, S)

        % Update structure created from earlier class versions to the current
        % version. Converts the bare structure for a scalar instance of an object.
        % Overload this method for customised conversion. Called within
        % from_old_struct on each element of S and each obj in array of objects
        % (in case of serializable array of objects)
        [S_updated,obj] = convert_old_struct (obj, S, ver)
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
        % Used by Matlab to restore objects using the Matlab intrinsic load
        % function.
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

    methods (Access=protected)
        % Pre-comparison of objects in overloaded method eq for serializable
        % objects in the case when the default method needs to be customised
        [is, mess, name_a, name_b, namer, argi] = process_inputs_for_eq (...
            lhs_obj, rhs_obj, narg_out, names, varargin)
    end


    %---------------------------------------------------------------------------
    %   Object validation
    %---------------------------------------------------------------------------
    methods
        % Check validity of interdependent properties
        obj = check_combo_arg (obj)
    end

    methods (Access=protected)
        % Utility to simplify the code of a class constructor
        [obj, remains] = set_positional_and_key_val_arguments (obj, ...
            positional_param_names_list, old_keyval_compat, varargin)
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
        function obj = set.do_check_combo_arg (obj, val)
            % Use a protected method so can overload this set method by children
            obj = set_do_check_combo_arg (obj, val);
        end

        function val = get.do_check_combo_arg (obj)
            val = obj.do_check_combo_arg_;
        end
    end
    methods(Access=protected)
        function obj = set_do_check_combo_arg (obj, val)
            % Allows overloading the property do_check_combo_arg_ over the tree
            % of serializable objects where each contains its own
            % do_check_combo_ property or inheritance of different serializable
            % objects where parent and a child have their own do_check_combo_arg_
            % property.
            obj.do_check_combo_arg_ = logical (val);
        end
    end
end

classdef serializable
    % SERIALIZABLE interface:
    %----------------------------------------------------------------------
    % Class supports common interface to convert class or array of classes
    % from/to structure used in serialization and defines the
    % standard for any Horace/Herbert custom class loadobj/saveobj methods.
    %
    % The class is necessary to provide common interface to loading and
    % saving classes to Matlab .mat files and Horace sqw objects and to
    % support old versions of the classes
    %----------------------------------------------------------------------
    % VALIDATION interface:
    %----------------------------------------------------------------------
    % In addition to save/load interface the class defines and uses
    % validation interface.
    % two properties and one method, namely "isvalid" and
    % "throw_on_invalid" properties  and "check_combo_arg" method are
    % defined on this public interface.
    %
    % By default, properties return true and false, and method returns
    % ok==true, mess = ''.
    %
    % The validity of the object is verified (if ~obj.isvalid) after
    % construction of a serializable object through it public interface.
    % If property "isvalid" is false, final validation, using  "check_combo_arg"
    % is provided. Depending on the state of the property "throw_on_invalid",
    % the exception is thrown if the object is invalid. If this property is
    % false, the object remains in the state, defined by "check_combo_arg"
    % method.
    %
    % Redefine functions "is = check_validity(obj), "is = get_throw_on_invalid(obj)"
    % and [ok,mess,obj] = check_combo_arg(obj) to use the interface in your
    % objects
    %
    properties(Dependent)
        % property verifies the validity of interdependent properties
        isvalid;
    end
    properties(Dependent,Hidden)
        % Throw exception if deserialized object is invalid
        throw_on_invalid;
    end
    properties(Access=protected)
        % Throw exception if deserialized object validation shows that it
        % is invalid
        throw_on_invalid_ = false;
    end
    %----------------------------------------------------------------------
    %   ABSTRACT INTERFACE TO DEFINE:
    methods(Abstract,Access=public)
        % define version of the class to store in mat-files
        % and nxsqw data format. Each new version would presumably read
        % the older version, so version substitution is based on this
        % number
        ver  = classVersion(obj);
        % get fields, which fully define the state of a serializable object,
        % so when the field values are stored on disk
        % the object can be properly restored from these values.
        flds = saveableFields(obj);
    end
    % To support old class versions, generic static loadob has to be
    % overloaded by the children class (e.g. ChildClass) by uncommenting
    % and appropriately modifying the following code:
    %     methods(Static)
    %         function obj = loadobj(S)
    %            % boilerplate loadobj method, calling generic method of
    %            % saveable class. Put it as it is replacing the
    %            "ChildClass" name by the name of the class the loadobj is
    %            the method of
    %             obj = ChildClass();
    %             obj = loadobj@serializable(S,obj);
    %         end
    %     end
    %----------------------------------------------------------------------
    % OPTIONAL:
    % to support old file versions, one should overload method
    % from_old_strct, which, by default, calls from_bare_struct method.
    %----------------------------------------------------------------------
    methods
        function strc = to_struct(obj)
            % Convert serializable object into a special structure, which allow
            % serialization and recovery using static "serializable.from_struct"
            % operation.
            %
            % Uses internal class structure produced by "to_bare_struct"
            % method and adds more fields, responsible for identifying class,
            % and array information if array of objects is serialized.
            %
            % Adds the following fields to the structure, obtained from
            %to_bare_struct function:
            %.serial_name -- the name of the class to recover from the
            %                structure when doing deserialize, loadobj or
            %                from_struct operations
            %.array_dat   -- this field appears only if conversion is
            %                applied to the array of objects.
            %.version     -- the class version, to be able to recover the
            %                previous versions of the classes
            % One can not add field containing single value to a structure
            % array so this function returns the structure with two fields
            % above  where "array_dat" field contains the structure
            % array, produced by "to_bare_struct" function.
            %
            % Input:
            % obj  -- class or array of classes object.
            % Returns:
            % struc -- structure, or structure, containing structure array
            %          with all information, necessary to restore the
            %          initial object
            %
            strc = to_struct_(obj);
        end


        function strc = to_bare_struct(obj,varargin)
            % Convert serializable object into a special structure, which allow
            % serialization and recovery using "from_bare_struct" operation
            %
            % Uses independent properties obtained from saveableFields method.
            % in assumption that the properties, returned by this method
            % fully define the public interface describing the state of the
            % object.
            %
            % Input:
            % obj  -- class or array of classes objects
            % Optional:
            % '-recursively' -- key-word '-recusrsively' or logical variable.
            %                   true/false
            %                   If provided and true, all 'serializable'
            %                   subfields of the current object are also
            %                   converted to bare structure. If false, or
            %                   absent, they are converted using to_struct
            %                   method
            %
            %
            % Returns:
            % struc -- structure, or structure array, containing the full
            %          information, necessary to restore the initial object
            if nargin>1
                if isnumeric(varargin{1})
                    recursively = logical(varargin{1});
                elseif islogical(varargin{1})
                    recursively = varargin{1};
                elseif ischar(varargin{1}) && strncmpi(varargin{1},'-r',2)
                    recursively = true;
                else
                    recursively = false;
                end
            else
                recursively = false;
            end
            strc = to_bare_struct_(obj,recursively);
        end

        %------------------------------------------------------------------
        function obj = from_bare_struct(obj,inputs,varargin)
            % restore object or array of objects from a plain structure,
            % previously obtained by to_bare_struct operation
            % Inputs:
            % obj    -- non-initialized instance of the object to build
            % inputs -- the structure, obtained by to_bare_struct method,
            %           and used as initialization for the object
            % optional:
            % check_validity -- (default -- true) -- when the object is
            %           fully constructed, check its validity by check_combo_arg
            %           method. Throw if the object is invalid.
            %           If false, the check is still performed, but invalid
            %           objects do not throw.
            if nargin > 2
                obj(1).throw_on_invalid = varargin{1};
            end
            obj = from_bare_struct_(obj,inputs);
        end
        %
        function ser_data = serialize(obj)
            struc = to_struct(obj);
            ser_data = serialise(struc);
        end
        %
        function [size,struc] = serial_size(obj)
            % Returns size of the serialized object
            %
            % Overload with specific function to avoid conversion to a
            % structure, which may be expensive
            struc = to_struct(obj);
            size = serial_size(struc);
        end
        %
        %======================================================================
        % Generic loadobj and saveobj
        % - to enable custom saving to .mat files and bytestreams
        % - to enable older class definition compatibility
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
            %
            % Adds the field "version" to the result of 'to_struct
            %                operation
            %.version     -- containing result of getVersion
            %                function, to distinguish between different
            %                stored versions of a serializable class
            %
            S         = to_struct_(obj);
        end
        %
        function obj = serializable()
            % generic class constructor. Does nothing
        end
        function is = get.isvalid(obj)
            is = check_validity(obj);
        end
        %
        function do = get.throw_on_invalid(obj)
            do = get_throw_on_invalid(obj);
        end
        function obj = set.throw_on_invalid(obj,val)
            obj.throw_on_invalid_ = logical(val);
        end
        %
        function [ok,mess,obj] = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Overload to obtain information about the validity of
            % interdependent properties and information about issues with
            % interdependent properties
            ok = true;
            mess = '';
        end

    end
    methods (Static)
        function obj = from_struct(in_struct,existing_obj)
            % restore object or array of objects from a structure,
            % previously obtained by to_struct operation.
            % To work with a generic structure, the structure should
            % contain fields:
            % serial_name -- containing the name of the class, with empty
            %                constructor
            % Inputs:
            % in_struct    -- the structure, obtained earlier using to_struct
            %                 method of serializable class
            % Optional:
            % existing_obj -- the instance of a serializable
            %                 object to recover from the structure. This
            %                 instance of the object will be set as output to
            %                 the state, defined by in_struct information.
            %                 if such class is provided, the in_struct do
            %                 not have to contain the "serial_name" field.
            %                 Its assumed that the "in_struct" defines the
            %                 state  of the "existing_obj"
            % Returns:
            % obj          -- initialized to the state, defined by in_struct
            %                 structure, instance of the object, which
            if nargin == 1
                existing_obj = [];
            end
            obj = from_struct_(in_struct,existing_obj);
        end

        function [obj,nbytes] = deserialize(byte_array,pos)
            % recover the object from the serialized into array of bytes
            % Inputs:
            % byte_array -- 1D array of bytes, obtained by some
            %               serialization operation
            % pos        -- the location of the initial position of
            %               the sequence to deserialize in the input byte
            %               array. If absent, assumed to be 1;
            % Returns:
            % obj        -- deserialized object
            % nbytes     -- the number of bytes the object occupies in the
            %               input array of bytes
            if nargin==1
                pos = 1;
            end
            [obj,nbytes] = deserialize_(byte_array,pos);
        end
        %
        function obj = loadobj(S,varargin)
            % Generic method, used by particular class loadobj method
            % to recover any serializable class
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array previously obtained by saveobj
            %           method
            %  class_instance -- the instance of a serializable class to
            %          recover from input S
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %           or structure array)
            obj = loadobj_(S,varargin{:});
        end
    end
    methods(Access=protected)
        function is = check_validity(~)
            % overload this property to verify validity of interdependent
            % properties
            is = true;
        end
        function do = get_throw_on_invalid(obj)
            % overloadable accessor to modify throw-on invalid for children
            do = obj.throw_on_invalid_;
        end
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % Restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain a version or the version, stored
            % in the structure does not correspond to the current version
            % of the class.
            %
            % By default, this function interfaces the default from_bare_struct
            % method, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            %
            %if isfield(inputs,'version') % do checks for previous versions
            %   Add appropriate code to convert from specific version to
            %   modern version
            %end
            if isfield(inputs,'array_dat')
                obj = obj.from_bare_struct(inputs.array_dat);
            else
                obj = obj.from_bare_struct(inputs);
            end
        end
        function [obj,remains] = set_positional_and_key_val_arguments(obj,...
                positinal_param_names_list,validators,varargin)
            % Utility method, to use in a serializable class constructor,
            % allowing to specify the constructor parameters in the form:
            %
            % ObjConstructor(positional_par1,positional_par2,positional_par3,...
            % positional_par...,key1,val1,key2,val2,...keyN,valN);
            %
            % All positional parameters should have the type defined in the validators
            % list. If the validator list is shorter then positional_arg_names list or
            % empty, the remaining positional argument values assumed to be numeric.
            %
            % First argument, which type not corresponds to the type, defined by the
            % validator list, assumed to be belonging to key-value pair.
            %
            % Everything not identified as Key-Value pair where the keys,
            % belong to the property names returned by saveableFields function
            % is returned in remains cellarray
            %
            % Inputs:
            % positinal_param_names_list
            %            -- list of positional parameter
            %               names, the target properties should be
            %               associated with
            % validators -- cellarray of the functions, which verify
            %               the types of the input arguments. If empty,
            %               the checks assumes that all input parameters
            %               should be numeric. If the size is smaller then the length of
            %               positional_arg_names, any missing parameters assumed to be
            %               numeric
            % EXAMPLE:
            % if class have the properties {'a1'=1(numeric), 'a2'='blabla'(char),
            % 'a3'=sqw() 'a4=[1,1,1] (numeric), and these properties are independent
            % properties redutned by saveableFields() function as list {'a1','a2','a3','a4'}
            % The list of validators should have form {@isnumeric,@ischar,
            % @(x)isa(x,'sqw'),'@isnumeric} or {@isnumeric,@ischar,
            % @(x)isa(x,'sqw')} (last validator missing as it assumed to be numeric)
            % Then the list of input parameters
            % set_positional_and_key_val_arguments(1,'blabla',an_sqw_obj,'blabla','a4',[1,0,0])
            % sets up the three first arguments as positional parameters, for properties
            % a1,a2 and a3 and a4 is set as key-value pair. 'blabla' is returned in
            % remains.
            %
            [obj,remains] = ...
                set_positional_and_key_val_arguments_(obj,...
                positinal_param_names_list,validators,varargin{:});
        end
    end
end

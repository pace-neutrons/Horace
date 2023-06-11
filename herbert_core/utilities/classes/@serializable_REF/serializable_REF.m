classdef (Abstract=true) serializable_REF
    % SERIALIZABLE interface:
    %----------------------------------------------------------------------
    % Class supports common interface to convert class or array of classes
    % from/to structure used in serialization and defines the
    % standard for any Horace/Herbert custom class loadobj/saveobj methods.
    %
    % The class is necessary to provide common interface to loading and
    % saving classes to Matlab .mat files and Horace sqw objects and to
    % support old versions of the classes
    %
    % A class needs to have two features to be able to become serializable:
    % 1) An empty constructor which creates valid empty instance
    %    of the class
    % 2) A public interface (list of properties) which can fully define
    %    the class contents by setting values of these properties to an
    %    empty class instance.
    %
    % The public interface request (No 2) can be weakened by accurate
    % overloading of to_bare_struct/from_bare_struct methods.
    % (expert usage only)
    %
    %----------------------------------------------------------------------
    % VALIDATION interface:
    %----------------------------------------------------------------------
    % In addition to save/load interface the class defines and uses
    % validation interface.
    %
    % one property and one method, namely protected property "do_check_combo_arg_"
    % and "check_combo_arg" method are defined on this public interface.
    %
    % By default, "do_check_combo_arg_" is set to true and the "check_combo_arg"
    % method does nothing. Overload the "check_combo_arg" to throw if
    % interdependent properties are inconsistent and throw invalid argument
    % exception when this happens.
    %
    % The serializable code sets do_check_combo_arg_ to false before
    % setting the properties and checks interdependent properties after
    % all properties were set. do_check_combo_arg_ is set to true after this.
    %
    % To work correctly, all interdependent properties setters in the child
    % code must contain the check for validity of interdependent properties
    % implemented as the following code block:
    % if obj.do_check_combo_arg_
    %    obj=check_combo_arg(obj);
    % end
    
    properties(Dependent,Hidden)
        % this is property for developers who wants to change number of
        % interdependent properties one after another and do not want to
        % overload the class. Use with caution, as you may get invalid
        % object if the property is used incorrectly.
        % It is also necessary to use when building and checking validity
        % of serializable object from other serializable objects. In this
        % case, set_do_check_combo_arg have to be overloaded appropriately.
        do_check_combo_arg;
    end

    properties(Access=protected)
        % Check interdependent properties and throw exception if
        % de-serialized object validation shows that object is invalid
        % Set it to "false" when changing
        do_check_combo_arg_ = true;
    end

    %---------------------------------------------------------------------------
    % Constructor
    %---------------------------------------------------------------------------
    methods
        function obj = serializable_REF()
            % Class constructor. Does nothing
        end
    end
        
    %---------------------------------------------------------------------------
    %   ABSTRACT INTERFACE TO DEFINE:
    %---------------------------------------------------------------------------
    methods(Abstract,Access=public)
        % Returns the version number of the class to store.
        % It is assumed that Each new version would presumably read
        % the older version, so version substitution is based on this
        % number
        ver  = classVersion(obj);

        % Return cellarray of public property names, which fully define
        % the state of a serializable object, so when the field values are
        % provided, the object can be fully restored from these values.
        %
        flds = saveableFields(obj);
    end


    % To support old class versions, generic static loadobj has to be
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
    % to support old file versions, one should also overload method
    % "from_old_struct", which, by default, calls "from_bare_struct" method.
    %----------------------------------------------------------------------

    methods
        function S = to_bare_struct (obj, varargin)
            % Convert a serializable object or array of objects into a structure
            %
            %   >> S = to_bare_struct (obj)
            %   >> S = to_bare_struct (obj, recursive_bare) 
            %   >> S = to_bare_struct (obj, '-recursive_bare') 
            %
            % To recover the input object, use the method "from_bare_struct"
            % (link below).
            %
            % Uses independent properties obtained from method "saveableFields"
            % on the assumption that the properties returned by this method
            % fully define the public interface describing the state of the
            % object.
            %
            % The object is recursively explored to convert all properties which
            % are serializable objects into structures. Properties that are
            % other objects remain as objects. Note that this means that if 
            % those objects have properties that are serializable, they will not
            % be converted into structures.
            %
            % By default, properties that are serializable objects are 
            % recursively converted using the public method "to_struct", which
            % adds fields that contain the class name and version. To
            % recursively force bare structures use the (deceptively ill-named) 
            % option '-recursive_bare'.
            %
            % OVERLOADING:
            % In some complex class designs, it may be necessary to overload
            % "to_bare_struct". In that case make sure that "from_bare_struct"
            % is also overloaded to invert structure to the object.
            %
            % Input:
            % ------
            %   obj             Object or array of objects which are 
            %                   serializable i.e. which belong to a child class
            %                   of serializable 
            %
            % Optional:
            %   recursive_bare  Logical true or false
            %                       OR
            % '-recursive_bare' Keyword; if present then recursive_bare is true
            %
            %                   Default if no option given: false
            % 
            %                   If false, nested properties are converted using
            %                   the public "to_struct" method.
            %                   If true, then they are converted to the bare
            %                   structure.
            %
            % Output:
            % -------
            %   S               Structure with information required to restore
            %                   the object using the "from_bare_struct" method.
            %
            %                   S is a structure array, each element of the 
            %                   array being the structure created from one 
            %                   object. The field names match the property names
            %                   returned from the method "saveableFields".
            %
            % See also from_bare_struct to_struct from_struct

            if nargin>1
                if isnumeric(varargin{1})
                    recursive_bare = logical(varargin{1});
                elseif islogical(varargin{1})
                    recursive_bare = varargin{1};
                elseif ischar(varargin{1}) && strncmpi(varargin{1},'-r',2)
                    recursive_bare = true;
                else
                    recursive_bare = false;
                end
            else
                recursive_bare = false;
            end
            S = to_bare_struct_ (obj, recursive_bare);
        end


        function S = to_struct (obj)
            % Convert a serializable object or array of objects into a dressed structure
            %
            %   >> S = to_struct (obj)
            %
            % To recover the input object, use the method "from_struct" (link 
            % below).
            %
            % Uses the (potentially overloaded) public method "to_bare_struct" 
            % internally and adds additional field to hold the class name and 
            % version.  
            %
            % The object is recursively explored to convert all properties which
            % are serializable objects into structures using "to_struct". 
            % Properties that are other objects remain as objects. Note that 
            % this means that if those objects have properties that are 
            % serializable, they will not be converted into structures.
            %
            % *** DO NOT OVERLOAD THIS METHOD ***.
            %
            % Input:
            % ------
            %   obj             Object or array of objects which are 
            %                   serializable.
            %                   i.e. which belong to a child class of 
            %                   serializable 
            %
            % Output:
            % -------
            %   S               Structure with information required to restore
            %                   the object using the "from_struct" method.
            %
            %                   S is a structure array
            %           The structure has fields
            %               .serial_name        Name of the class
            %               .version            Class version
            %           and either:
            %               .array_dat          Structure array each element of
            %                                   the array being the structure 
            %                                   created from one object. The 
            %                                   field names match the property
            %                                   names returned from the method
            %                                   "saveableFields".
            %           or there was only one object:
            %               .<property_1>       First property in saveableFields
            %               .<property_2>       Second    "     "    "
            %                     :                 :
            % 
            % See also from_struct to_bare_struct from_bare_struct

            S = to_struct_ (obj);
        end

        %------------------------------------------------------------------
        function obj = from_bare_struct (obj_template, S)
            % Restore object or object array from a structure
            %
            %   >> obj = from_bare_struct (obj_template, S)
            %
            % Because the bare structure does not contain the information of the
            % class type to be recovered, an object is needed to define it. This
            % template object must be a serializable object.
            %
            % Typically obj_template will have been created by the constructor
            % with no arguments for the class type to recover (this use case
            % would only have required this method to have been a static
            % method).
            % 
            % However, there are circumstances when it might be convenient to 
            % have a source of extra fields other than the defaults for the 
            % empty constructor. In this case, obj_template is used to provide 
            % any properties that might be missing from the structure, in
            % addition to defining the class type and the property names (via
            % "saveableFields") to be set from S.
            %
            % OVERLOADING:
            % If the method "to_bare_struct" has been overloaded, then an
            % overloaded version of this method will likely be required too.
            %
            % Input:
            % ------
            %   obj_template     Scalar instance of the class to be recovered.
            %                    This is needed because the structure created by
            %                   "to_bare_struct" does not contain the class
            %                   type. The object is used as template.
            %
            %   S        Structure or structure array of data with the structure
            %           as created by "to_bare_struct".
            %            Note that structures created by to_struct (i.e. with
            %           the fields 'serial_name', 'version' and (if from an 
            %           array of objects) 'array_dat' are *NOT* valid.
            %
            % Output:
            % -------
            %   obj      Object or array of objects of the same class as the
            %           input argument obj_template.
            %
            %
            % EXAMPLES
            %   Suppose the variable my_obj is an array of IX_fermi_chopper
            %   objects.
            %   Simple case of saving to a bare structure, and recovering later:
            %   >> S = to_bare_struct (my_obj);
            %   >>      :
            %   >> recovered_object_arr = from_bare_struct (S, IX_fermi_chopper)
            %
            %   Now suppose there is another class called IX_fancy_chopper that
            %   has some properties in common with an IX_fermi_chopper. If the
            %   additional state-defining properties of IX_fancy_chopper can be
            %   taken as the the default on construction then it is valid to set
            %
            %   >> my_fancy_obj_arr = from_bare_struct (S, IX_fancy_chopper)
            %
            %   Suppose we have a valid instance of IX_fancy_chopper called
            %   some_fancy_obj, then we can use it as a template from which to
            %   set a collection of fields from the structure S
            %
            %   >> my_fancy_obj_arr = from_bare_struct (S, some_fancy_obj)
            %  *OR*
            %   >> my_fancy_obj_arr = some_fancy_obj.from_bare_struct (S)
            %
            %
            % See also to_bare_struct

            obj = from_bare_struct_ (obj_template, S);
        end
    end

    methods (Static)
        function obj = from_struct (S, obj_template)
            % Restore object or object array from a structure created by to_struct
            % 
            %   >> obj = from_struct (S)
            %   >> obj = from_struct (S, obj_template)
            %
            % Input:
            % ------
            %   S        Structure or structure array of data with the struture
            %           as created by "to_struct".
            %            An attempt to restore from another structure is made if
            %           a template object is provided (see below).
            %
            % Optional:
            %   obj_template     Scalar instance of the class to be recovered.
            %                   it must be a serializable object.
            %                    This is used to over-ride the object type held
            %                   in the input structure S if it was created with
            %                   to_struct, or provides the template object that
            %                   is 
            %                    If S was not created by to_struct, then it 
            %                   provides the template object into which to 
            %                   attempt to load the structure.
            %
            % Output:
            % -------
            %   obj      Object or array of objects with properties set from S

            if nargin == 1
                obj = from_struct_ (S);
            else
                obj = from_struct_ (S, obj_template);
            end
        end
    end

    methods (Access=protected)
        function obj = from_old_struct (obj, S)
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
            if isfield (S, 'array_dat')
                obj = obj.from_bare_struct (S.array_dat);   % array of objects
            else
                obj = obj.from_bare_struct (S);     % scalar instance
            end
        end
    end



    methods
        function serialized_data = serialize (obj)
            % Serialize an object or array of objects
            %
            %   >> serialized_data = serialize (obj)
            %
            % Input:
            % ------
            %   obj                 Object or object array to be serialized
            %
            % Output:
            % -------
            %   serialized_data     Serialized data.
            %                       The input is first converted to a structure
            %                       using the method to_struct before calling
            %                       the utility function serilize.

            S = to_struct(obj);
            serialized_data = serialise (S);
        end

        function [size, S] = serial_size (obj)
            % Returns the size of the serialized object
            % 
            %   >> [size, S] = serial_size (obj)
            %
            % Overload with specific function to avoid conversion to a
            % structure, which may be expensive
            %
            % Input:
            % ------
            %   obj                 Object or object array to be serialized
            %
            % Output:
            % -------
            %   size    Serialized data.
            %           The input is first converted to a structure using the
            %           method to_struct before calling the utility function
            %           serial_size.

            S = to_struct (obj);
            size = serial_size (S);   % calls utility function, not this method
        end



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



        function obj = check_combo_arg(obj)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Overload to obtain information about the validity of
            % interdependent properties and information about issues with
            % interdependent properties

            %Throw if the properties are inconsistent and return without
            %problem it they are not.
        end
        % Developer property. Intended for creating algorithms, which
        % change bunch of interdependent properties one after another
        % without overloading the class.
        % Set this property to false at the beginning, change interdependent
        % properties, run check_combo_arg after setting all interdependent
        % properties to its values so if check_combo_arg throws the error,
        % the interdependent properties are inconsistent and the object is
        % invalid.
        function do = get.do_check_combo_arg(obj)
            do = obj.do_check_combo_arg_;
        end
        function obj = set.do_check_combo_arg(obj,val)
            %use set function to be able to overload this method by children
            obj = set_do_check_combo_arg(obj,val);
        end
        function [is,mess] = eq(obj,other_obj,varargin)
            % the generic equality operator, allowing comparison of
            % serializable objects
            %
            % Inputs:
            % other_obj -- the object or array of objects to compare with
            % current object
            % Optional:
            % any set of parameters equal_to_tol function would accept
            if nargout == 2
                [is,mess] = eq_(obj,other_obj,varargin{:});
            else
                is = eq_(obj,other_obj,varargin{:});
            end
        end
        function [nis,mess] = ne(obj,other_obj,varargin)
            if nargout == 2
                [is,mess] = eq_(obj,other_obj,varargin{:});
            else
                is = eq_(obj,other_obj,varargin{:});
            end
            nis = ~is;
        end
    end

    methods (Static)

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
        function obj = set_do_check_combo_arg(obj,val)
            % overloadable setters for checking interdependent properties.
            % May be overloaded by children for example to change the check
            % in compositing properties which values are in turn
            % serializable
            obj.do_check_combo_arg_ = logical(val);
        end
        %------------------------------------------------------------------


        function [obj, remains] = set_positional_and_key_val_arguments (obj, ...
                positional_param_names_list, old_keyval_compat, varargin)
            % Utility method, to use in a serializable class constructor,
            % allowing to specify the constructor parameters in the form:
            %
            % ObjConstructor(positional_par1,positional_par2,positional_par3,...
            % positional_par...,key1,val1,key2,val2,...keyN,valN);
            %
            % The keys are the names of the properties and the values are
            % the values of the properties to set.
            % The positional parameters are intended to be the values of
            % the properties with names defined in the
            % positinal_param_names_list list.
            %
            % Everything not identified as positional parameters or
            % Key-Value pair is returned in remains cellarray
            %
            % Input:
            % ------
            % positional_param_names_list
            %            -- cellarray of positional parameter names,
            %               coinciding with the names of the properties the
            %               function is called to set
            % old_keyval_compat
            %            -- if set to true, keys in varargin may have form
            %               '-keyN' in addition to 'keyN'. Deprecation
            %                warning is issued for this kind of names.
            % varargin   -- cellarray of the constructor inputs, in the
            %               form, described above.
            %
            % End of positional parameters list is established by finding
            % in varargin the element, belonging to the
            % positinal_param_names_list  (first key)
            %
            % If the same property is defined using positional parameter
            % and as key-value pair, the key-val parameter value takes
            % priority.
            %
            %
            % EXAMPLE:
            % if class have the properties {'a1'=1, 'a2'='blabla',
            % 'a3'=sqw() 'a4=[1,1,1], 'a5'=something} and these properties
            % are the independent properties defining the state of the
            % object and provided in positional_param_names_list as:
            % ppp = {'a1','a2','a3','a4','a5'}
            % Then the call to the function with the list of input parameters:
            % varargin = {1,'blabla',an_sqw_obj,'a4',[1,0,0],'blabla'}
            % in the form:
            %>> [obj,remains] = set_positional_and_key_val_arguments(obj,ppp,false,varargin{:});
            %
            % sets up the three first arguments as positional parameters,
            % for properties a1,a2 and a3, a4 is set as key-value pair,
            % 'blabla' is returned in remains and property a5 remains
            % unset.
            %
            %
            [obj,remains] = ...
                set_positional_and_key_val_arguments_(obj,...
                positional_param_names_list,old_keyval_compat,varargin{:});
            %
            % Simple Code sample to insert into new object constructor
            % to use this function as part of generic constructor:
            %
            % flds = obj.saveableFields();
            % [obj,remains] = obj.set_positional_and_key_val_arguments(...
            %        flds,false,varargin{:});
            %  if ~isempty(remains) % process the parameters not recognized
            %                       % as positional or key-value arguments
            %      error('HORACE:class_name:invalid_argument',...
            %           ' Class constructor has been invoked with non-recognized parameters: %s',...
            %                         disp2str(remains));
            %  end
        end
    end
end

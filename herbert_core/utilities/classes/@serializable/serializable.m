classdef serializable
    % Class supports common interface to convert class or array of classes
    % from/to structure used in serialization and defines the
    % standard for any Horace/Herbert custom class loadobj/saveobj methods.
    %
    methods(Abstract,Access=public)
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        ver  = classVersion(obj);
        % get independent fields, which fully define the state of a
        % serializable object.
        flds = indepFields(obj);
    end
    methods(Abstract,Static)
        % Static method used by Matlab load function to support custom
        % loading. The method has to be overloaded in the class using
        % loadobj_generic function in the form:
        %
        % function obj = loadobj(S)
        %   class_instance = EmptyClassConstructur();
        %   obj = serializable.loadobj_generic(S,class_instance);
        % end
        %
        % where EmpytClassConstructor is the empty constructor of the
        % class to recover from the record
        obj = loadobj(S);
    end
    
    
    methods
        % convert class or array of classes into a plain structure
        % using independent properties obtained from indepFields method.
        strc = struct(obj);

        %
        %------------------------------------------------------------------
        % restore object or array of objects from a plain structure,
        % previously obtained by struct operation
        obj = from_struct(obj,inputs);
        
        function struc = shallow_struct(obj)
            % convert object to structure, using only its top level
            % properties, e.g. if a property value is an object, we are not
            % converting this object into structure. Structure property value
            % remains object
            struc = shallow_struct_(obj);            
        end
        %
        
        function ser_data = serialize(obj)
            sh_struc = shallow_struct_(obj);
            ser_data = hlp_serialise(sh_struc);
        end
        %
        function size = serial_size(obj)
            % returns size of the serialized object
            str = shallow_struct_(obj);
            size = serial_size(str);
        end
        %
        function [obj,nbytes] = deserialize(obj,bytes_array,pos)
            % deserialize underlying data structure and return appropriate
            % object or array of objects
            %
            % pos -- the location of the data of interest within the bytes
            %         array
            [struc,nbytes] = hlp_deserialise(bytes_array,pos);
            obj = from_struct(obj,struc);
        end
        %======================================================================
        % Custom loadobj and saveobj
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
            
            % The following is generic code. Overload if really necessary
            S = struct(obj);
            ver = obj.classVersion();
            if numel(obj)>1
                S = struct('version',ver,...
                    'array_data',S);
            else
                S.version = ver;
            end
        end
        
        %
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            if isfield(inputs,'version')
                inputs = rmfield(inputs,'version');
            end
            if isfield(inputs,'array_data')
                obj = from_struct(obj,inputs.array_data);
            else
                obj = from_struct(obj,inputs);
            end
        end
        %
        function obj = serializable()
            % generic class constructor. Does nothing
        end
    end
    methods (Static)
        
        function obj = loadobj_generic(S,class_instance)
            % Generic method, used by particular class loadobj method
            % to recover any class
            %   >> obj = loadobj(S,class_instance)
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
            %       	or structure array)
            if isobject(S) && isa(S,class(class_instance))
                obj = S;
            else % call private implementation
                obj = loadobj_(S,class_instance);
            end
        end
    end
    
end

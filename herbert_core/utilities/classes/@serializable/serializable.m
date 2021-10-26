classdef serializable
    % Class supports common interface to convert class or array of classes
    % from/to structure used in serialization and defines the
    % standard for any Horace/Herbert custom class loadobj/saveobj methods.
    %
    %----------------------------------------------------------------------
    %   ABSTRACT INTERFACE TO DEFINE
    methods(Abstract,Access=public)
        % define version of the class to store in mat-files
        % and nxsqw data format. Each new version would presumably read
        % the older version, so version substitution is based on this
        % number
        
        ver  = classVersion(obj);
        % get independent fields, which fully define the state of a
        % serializable object.
        flds = indepFields(obj);
    end
    % To support old class versions, generic static loadob has to be
    % overloaded by the children class (e.g. ChildClass) by uncommenting
    % and appropriately modifying the following code:
    %     methods(Static)
    %         function obj = loadobj(S)
    %            % boilerplate loadobj method, calling generic method of
    %            % saveable class
    %             obj = ChildClass();
    %             obj = loadobj@serializable(S,obj);
    %         end
    %     end
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
            % Input:
            % obj  -- class or array of classes object.
            % Returns:
            % struc -- structure, or structure array, containing the full
            %          information, necessary to restore initial object
            strc = to_struct_(obj);
        end
        function strc = to_bare_struct(obj)
            % Convert serializable object into a special structure, which allow
            % serialization and recovery using "from_class_struct" operation
            %
            % Uses independent properties obtained from indepFields method.
            % in assumption that the properties, returned by this method
            % fully define the public interface describing the state of the
            % pbject.
            %
            % Input:
            % obj  -- class or array of classes object
            % Returns:
            % struc -- structure, or structure array, containing the full
            %          information, necessary to restore the initial object
            strc = to_bare_struct_(obj);
        end
        
        %------------------------------------------------------------------
        function obj = from_class_struct(obj,inputs)
            % restore object or array of objects from a plain structure,
            % previously obtained by to_bare_struct operation
            obj = from_class_struct_(obj,inputs);
        end
        %
        function ser_data = serialize(obj)
            struc = to_struct(obj);
            ser_data = serialise(struc);
        end
        %
        function size = serial_size(obj)
            % returns size of the serialized object
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
            S         = to_struct(obj);
            ver       = obj.classVersion();
            S.version = ver;
        end
        %
        function obj = serializable()
            % generic class constructor. Does nothing
        end
    end
    methods(Access=protected)
        %------------------------------------------------------------------
        function obj = from_old_struct(obj,inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % The method is called by loadobj in the case if the input
            % structure does not contain version or the version, stored
            % in the structure does not correspond to the current version
            %
            % By default, this function interfaces the default from_class_struct
            % method, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            %
            %if isfield(inputs,'version')
            %      do check for previous versions
            %      and appropriate code
            %end
            if isfield(inputs,'array_dat')
                obj = obj.from_class_struct(inputs.array_dat);
            else
                obj = obj.from_class_struct(inputs);
            end
        end
        
    end
    methods (Static)
        function obj = from_struct(inputs)
            % restore object or array of objects from a plain structure,
            % previously obtained by to_class_struct operation
            obj = from_struct_(inputs);
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
            %       	or structure array)
            obj = loadobj_(S,varargin{:});
        end
    end
end

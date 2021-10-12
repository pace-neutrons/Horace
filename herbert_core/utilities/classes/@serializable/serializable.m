classdef serializable
    % Class supports common interface to convert class from/to structure
    % used in serialization and standard for Horace/Herbert loadobj,saveobj
    % methods.
    %
    %
    methods(Abstract,Access=protected)
        % get independent fields, which fully define the state of the object
        flds = indepFields(obj);
        % get class version, which would affect the way class is stored on/
        % /restore from an external media
        ver  = classVersion(obj);
    end
    methods(Abstract,Static)
        % Static method used my Matlab load function to support custom
        % loading. The method has to be overloaded in the class using
        % loadobj_generic function in the form:
        %
        % function obj = loadobj(S)
        %   class_instance = EmptyClassConstructur();
        %   obj = class_instance.loadobj_generic(S,class_instance)
        % end
        %
        % where
        obj = loadobj(S);
    end
    
    
    methods
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
            S = to_struct(obj);
            ver = obj.classVersion();
            if numel(obj)>1
                S = struct('version',ver,...
                    'array_data',S);
            else
                S.version = ver;
            end
        end
        
        % convert class into a plain structure using independent properties
        % obtained from indepFields method
        str = to_struct(obj,varargin);
        %
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
            %  class_instance -- the instance of the class to recover from
            %          input S
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
        %------------------------------------------------------------------
        % resore object from a plain structure, previously obtained by
        % struct operation
        [obj,remains] = from_struct(inputs);
        
        function [obj,remains] = from_old_struct(inputs)
            % restore object from the old structure, which describes the
            % previous version of the object.
            %
            % Generally, this function interfaces the current from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs particular overloading
            % for loadob to recover new structure from an old structure.
            [obj,remains] = from_struct(inputs);
        end
    end
    
end


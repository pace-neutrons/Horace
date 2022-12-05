classdef IX_null_inst < IX_inst
    % An instrument constructed from a struct with no fields
    % As the new Experiment class has an array of IX_inst, we need
    % something derived from IX_inst to hold the case where the file from
    % which the sqw is created has these empty struct instruments.
    % This class will provide a conversion to an empty struct.
    
    properties
        % none in addition to the base IX_inst
    end
    
    methods
    
        % Constructor
        %-------------------------------
        function obj = IX_null_inst()
            % constructs a vanilla instance based on IX_inst
            obj = obj@IX_inst();
        end
        
        % ?
        %------
        function str = null_struct(~)
            %makes the null struct for storage in a file
            str = struct();
        end
        
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end
        
        function flds = saveableFields(obj)
            flds = saveableFields@IX_inst(obj);
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
            % By default, this function interfaces the default from_struct
            % function, but when the old strucure substantially differs from
            % the moden structure, this method needs the specific overloading
            % to allow loadob to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
            % optimization here is possible to not to use the public
            % interface. But is it necessary? its the question
            obj = from_old_struct@serializable(obj,inputs);
            
        end
    end
        
    %======================================================================
    % Custom loadobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods (Static)
        function obj = loadobj(S)
            % Static method used my Matlab load function to support custom
            % loading.
            %
            %   >> obj = loadobj(S)
            %
            % Input:
            % ------
            %   S       Either (1) an object of the class, or (2) a structure
            %           or structure array
            %
            % Output:
            % -------
            %   obj     Either (1) the object passed without change, or (2) an
            %           object (or object array) created from the input structure
            %       	or structure array)
            
            % The following is boilerplate code; it calls a class-specific function
            % called loadobj_private_ that takes a scalar structure and returns
            % a scalar instance of the class
            %{
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
            %}
            obj = IX_null_inst();
            obj = loadobj@serializable(S,obj);

        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end


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
        function [inputs,obj] = convert_old_struct(obj,inputs,ver)
            % Update structure created from earlier class versions to the current
            % version. Converts the bare structure for a scalar instance of an object.
            % Overload this method for customised conversion. Called within
            % from_old_struct on each element of S and each obj in array of objects
            % (in case of serializable array of objects)
            inputs = convert_old_struct_(obj,inputs);
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


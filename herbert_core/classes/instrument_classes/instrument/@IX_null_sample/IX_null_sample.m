classdef IX_null_sample < IX_samp
    %IX_NULL_SAMPLE Summary of this class goes here
    %   Detailed explanation goes here

    properties
        % none beyond IX_sample
    end

    methods

        % Constructor
        %------------
        function obj = IX_null_sample(varargin)
            obj = obj@IX_samp(''); %[1.0 1.0 1.0],[90 90 90]);
            if nargin == 3
                obj.name = varargin{1};
                obj.alatt = varargin{2};
                obj.angdeg = varargin{3};
            elseif nargin ~= 0
                error('HORACE:IX_null_sample:invalid argument','invalid no. args');
            end
        end

        % ?
        %-----
        function str = null_struct(~)
            str = struct();
        end

        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
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
            obj = IX_null_sample();
            obj = loadobj@serializable(S,obj);

        end
        %------------------------------------------------------------------

    end
    %======================================================================

end


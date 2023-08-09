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
                error('HORACE:IX_null_sample:invalid_argument', ...
                    'invalid number of args');
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
    methods(Access = protected)
        function alat = get_lattice(~)
            alat = [];
        end
        function ang = get_angles(~)
            ang = [];
        end
        function name = get_name(~)
            name = '';
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
            obj = IX_null_sample();
            obj = loadobj@serializable(S,obj);

        end
        %------------------------------------------------------------------

    end
    %======================================================================

end


classdef IX_samp  < serializable
    % Base class for samples to include the null sample case defined from a
    % struct with no fields (IX_null_sample) and the standard IX_sample

    properties (Access=protected)
        name_ = '';   % suitable string to identify sample
        alatt_;
        angdeg_;
    end

    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
    end

    properties
        %
    end

    properties (Dependent)
        % Mirrors of private/protected properties
        name;
        alatt;
        angdeg;
    end

    methods(Static)
        function isaval = cell_is_class(ca)
            try
                isaval = cellfun(@IX_samp.xxx, ca);
                if all(isaval), isaval = 1; else, isaval = 0; end
            catch
                error('HERBERT:IX_samp:cell_is_class', ...
                    'input could not be converted from cell to logical');
            end
        end
        function rv = xxx(obj)
            rv = isa(obj,'IX_samp');
        end
    end
    methods

        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function [obj,remains] = IX_samp (varargin)
            % Create base sample object
            % with possible arguments, 'name','alatt','angdeg';
            %
            %   >> base_sample = IX_samp (name)
            %
            if nargin==0
                return;
            end
            [obj,remains] = init(obj,varargin{:});
        end
        function  [obj,remains] = init(obj,varargin)
            % initialize serializable object using constructor fields
            % 'name','alatt','angdeg'
            fields = obj.saveableFields();
            [obj,remains] = set_positional_and_key_val_arguments(obj,fields,...
                varargin{:});
        end

        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function vers = classVersion(~)
            vers = 0; % base class function, dummy value
        end

        function flds = saveableFields(~)
            flds = {'name', 'alatt', 'angdeg'};
        end

        %
        % other methods
        %------------------------------------------------------------------
        function [iseq,mess] = eq(obj1, obj2,varargin)
            mess = '';
            iseq = strcmp(obj1.name, obj2.name);
            if ~iseq
                mess = 'objects have different names; ';
            end
            if numel(obj1.alatt)==3 && numel(obj2.alatt)==3
                iseq = iseq && all(obj1.alatt==obj2.alatt);
                mess = [mess,'objects have different lattice; '];
            elseif isempty(obj1.alatt) && isempty(obj2.alatt)
                iseq = iseq && true; % heavy-handed but gets the point across
            else
                iseq = false;
                return
            end
            if numel(obj1.angdeg)==3 && numel(obj2.angdeg)==3
                iseq = iseq && all(obj1.angdeg==obj2.angdeg);
            elseif isempty(obj1.angdeg) && isempty(obj2.angdeg)
                iseq = iseq && true; % heavy-handed but gets the point across
            else
                iseq = false;
                return
            end
        end

        %------------------------------------------------------------------
        % Set methods
        %
        % Set the non-dependent properties. We cannot make the set
        % functions depend on other non-dependent properties (see Matlab
        % documentation). Have to devolve any checks on interdependencies to the
        % constructor (where we refer only to the non-dependent properties)
        % and in the set functions for the dependent properties. There is a
        % synchronisation that must be maintained as the checks in both places
        % must be identical.

        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                if isempty(val)
                    obj.name_='';
                else
                    error('HERBERT:IX_samp:invalid_argument', ...
                        'Sample name must be a character string (or empty string)')
                end
            end
        end

        function n=get.name(obj)
            n = obj.name_;
        end

        function obj=set.alatt(obj,val)
            if isempty(val)
                obj.alatt_ = [];
                return;
            end
            if ~isnumeric(val)
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample alatt must be a 1 or 3 compoment numeric vector')
            end

            if numel(val) == 1
                obj.alatt_ = [val,val,val];
            elseif numel(val) == 3
                obj.alatt_=val(:)';
            else
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample alatt must be a 1 or 3 compoment numeric vector')
            end
        end

        function alat=get.alatt(obj)
            alat = obj.alatt_;
        end

        function obj=set.angdeg(obj,val)
            if isempty(val)
                obj.angdeg_ = [];
                return;
            end
            if ~isnumeric(val)
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample angdeg must be a numeric vector')
            end

            if numel(val) == 1
                obj.angdeg_ = [val,val,val];
            elseif numel(val) == 3
                obj.angdeg_=val(:)';
            else
                error('HERBERT:IX_samp:invalid_argument', ...
                    'Sample angdeg must be a numeric vector')
            end

            obj.angdeg_=val(:)';
        end

        function ang=get.angdeg(obj)
            ang = obj.angdeg_;
        end
    end
    %------------------------------------------------------------------
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
            obj = IX_samp();
            obj = loadobj@serializable(S,obj);
        end

        %------------------------------------------------------------------

    end
    %======================================================================
end

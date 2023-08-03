classdef IX_inst < serializable
    % Defines the base instrument class. This superclass must be
    % inherited by all instrument classes to unsure that they are
    % discoverable as instruments using isa(my_obj,'IX_inst')

    properties (Access=protected)
        name_ = '';             % Name of instrument (e.g. 'LET')
        source_ = IX_source;    % Source (name, or class of type IX_source)
        %
        valid_from_ = datetime(1900,01,01);
        valid_to_ = [];
        % indicator for presence of a correct validity interval
        validity_date_set_ = false(1,2);
    end

    properties (Dependent)
        name ;          % Name of instrument (e.g. 'LET')
        source; % Source (name, or class of type IX_source)
        moderator       % Moderator (object of class IX_moderator)
        % the date, instrument with these settings become valid
        valid_from;
        % the date, instrument with these settings stops beeing valid
        valid_to;
    end

    methods(Static)
        function isaval = cell_is_class(ca)
            try
                isaval = cellfun(@IX_inst.xxx, ca);
                if all(isaval), isaval = 1; else, isaval = 0; end
            catch ME
                error('HERBERT:IX_inst:invalid_argument', ...
                    'input could not be converted from cell to logical: %s',...
                    ME.message);
            end
        end
        function rv = xxx(obj)
            rv = isa(obj,'IX_inst');
        end
    end
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_inst (varargin)
            % Create instrument base information
            %
            %   >> instrument = IX_inst (name)
            %   >> instrument = IX_inst (source,name)
            %
            %   name        Name of instrument (character string)
            %   source      Neutron source
            %               - name of the source e.g. 'ISIS'
            %               - object of class IX_source

            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_inst.loadobj(varargin{1});
            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                pos_params = obj.saveableFields();
                % process deprecated interface where the "name" property
                % value is first among the input arguments
                if ischar(varargin{1})&&~strncmp(varargin{1},'-',1)&&~ismember(varargin{1},pos_params)
                    argi = varargin(2:end);
                    obj.name = varargin{1};
                else
                    argi = varargin;
                end
                % set positional parameters and key-value pairs and check their
                % consistency using public setters interface. check_compo_arg
                % after all settings have been done.
                [obj,remains] = set_positional_and_key_val_arguments(obj,pos_params,...
                    true,argi{:});

                if ~isempty(remains)
                    error('HERBERT:IX_inst:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_sample constructor: %s',...
                        disp2str(remains));
                end
            end
        end

        % other methods
        %------------------------------------------------------------------
        % Set methods for independent properties
        %
        % Devolve any checks on interdependencies to the constructor (where
        % we refer only to the independent properties) and in the set
        % functions for the dependent properties.
        %
        % There is a synchronisation that must be maintained as the checks
        % in both places must be identical.


        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.name(obj,val)
            if ~istext(val)
                error('HORACE:IX_inst:invalid_argument', ...
                    'The source name must be a character string')
            end
            obj.name_ = char(val);
        end

        function obj=set.source(obj,val)
            if isa(val,'IX_source') && isscalar(val)
                obj.source_ = val;
            elseif is_string(val)
                obj.source_ = IX_source('name',val);
            elseif isempty(val)
                obj.source_ = IX_source();
            else
                error('The source name must be a character string or an IX_source object')
            end
        end
        function obj = set.valid_from(obj,val)
            if ~isa(val,'datetime')
                val = datetime(val);
            end
            obj.valid_from_ = val;
            obj.validity_date_set_(1) = true;
        end
        function obj = set.valid_to(obj,val)
            if ~isa(val,'datetime')
                val = datetime(val);
            end
            obj.valid_to_ = val;
            obj.validity_date_set_(2) = true;
        end
        %------------------------------------------------------------------
        function obj = set_mod_pulse(obj,pulse_model,pm_par)
            % set moderator pulse model
            % Inputs:
            % pulse_model -- the string, defining the pulse model (TODO:
            %                should be a class)
            % pm_par      -- the parameters of the model
            mod = get_moderator(obj);
            mod = mod.set_mod_pulse(pulse_model,pm_par);
            obj = obj.set_moderator(mod);
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val = obj.name_;
        end

        function val=get.source(obj)
            val = obj.source_;
        end
        function val = get.valid_from(obj)
            val = obj.valid_from_;
        end
        function val = get.valid_to(obj)
            if obj.validity_date_set_(2)
                val = obj.valid_to_;
            else
                val = datetime("now");
            end
        end
        function val=get.moderator(obj)
            val = get_moderator(obj);
        end
        function obj = set.moderator(obj,val)
            obj = set_moderator(obj,val);
        end
        %------------------------------------------------------------------
    end
    methods(Access=protected)
        function val = get_moderator(~)
            % overloadable moderator getter
            error('HORACE:IX_inst:runtime_error',...
                'Moderator can not be retrieved from  IX_inst abstraction or empty instrument');

        end
        function obj = set_moderator(~,~)
            % overloadable moderator setter
            error('HERBERT:IX_inst:runtime_error',...
                'You can not set moderator on IX_inst abstraction or empty instrument')
        end

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
    methods
        % SERIALIZABLE interface
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 1;
        end

        function flds = saveableFields(obj)
            flds = {'source','name'};
            if obj(1).validity_date_set_(1)
                flds = [flds(:),'valid_from'];
            end
            if obj(1).validity_date_set_(2)
                flds = [flds(:),'valid_to'];
            end
        end
    end



    %======================================================================
    % Custom loadobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

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
            obj = IX_inst();
            %hack to recover creation date whatever it was previously set
            % or not
            default_from = obj.valid_from_;
            default_to = obj.valid_to_;
            obj.validity_date_set_ = true(1,2); % with this true, the code
            % will try to recover validity dates but do nothing if not
            % found these dates within the stored data.
            %
            obj = loadobj@serializable(S,obj);
            % check if validity dates were actually set and unset validity
            % indicator if they were not.
            if isequal(default_from,obj.valid_from_)
                obj.validity_date_set_(1) = false;
            end
            if isequal(default_to,obj.valid_to_)
                obj.validity_date_set_(2) = false;
            end
        end
        %------------------------------------------------------------------

    end
    %======================================================================
end

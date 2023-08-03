classdef IX_divergence_profile < serializable
    % Divergence profile class definition

    properties (Access=private)
        name_ = '';
        angles_ = [];
        profile_ = [];
        pdf_  =  pdf_table(); % will be set to default pdf by empty constructor
        mandatory_field_set_ = false(1,2)
    end

    properties (Dependent)
        % Mirrors of private properties
        name
        angles
        profile
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_divergence_profile (varargin)
            % Create fermi chopper object
            %
            %   >> div = IX_divergence_profile (angles,profile)
            %
            %   >> div = IX_divergence_profile (name,...)
            %
            % Required:
            %   angles          Vector of divergences (radians)
            %   profile         Vector with profile. Does not need to be normalised
            %
            % Optional:
            %   name            Name of the divergence profile (e.g. 'LET new vertical')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbreviations) e.g.:
            %
            %   div = IX_divergence_profile (angles,'name','in-pile', 'profile', y)


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_divergence_profile.loadobj(varargin{1});

            elseif nargin>0
                % define parameters accepted by constructor as keys and also the
                % order of the positional parameters, if the parameters are
                % provided without their names
                pos_params = obj.saveableFields();
                % process deprecated interface where the "name" property is
                % first among the input arguments
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
                    error('HERBERT:IX_divergence_profile:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_divergence_profile constructor: %s',...
                        disp2str(remains));
                end
            end
        end

        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj = set.angles(obj,angles_in)
            if isempty(angles_in)
                obj.angles_=[];  % make a row vector
                obj.mandatory_field_set_(1) = false;
            elseif ~(isnumeric(angles_in) && isvector(angles_in) && numel(angles_in)>=2 && all(diff(angles_in)>=0))
                error('HERBERT:IX_divergence_profile:invalid_argument', ...
                    'IX_divergence_profile: Angle array must be a vector length at least two and monotonically increasing')
            else
                obj.angles_=angles_in(:)';  % make a row vector
                obj.mandatory_field_set_(1) = true;
            end

            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(true);
            end

        end
        function obj = set.profile(obj,profile_in)
            if isempty(profile_in)
                obj.profile_=[];
                obj.mandatory_field_set_(2) = false;
            elseif ~(isvector(profile_in) && all(isfinite(profile_in)) && all(profile_in>=0))
                error('HERBERT:IX_divergence_profile:invalid_argument', ...
                    'IX_divergence_profile: The profile values must all be finite and greater or equal to zero')
            else
                obj.profile_=profile_in(:)';
                obj.mandatory_field_set_(2) = true;
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(true);
            end
        end
        function obj = set.name(obj,val)
            if ~(ischar(val)||isstring(val))
                error('HERBERT:IX_divergence_profile:invalid_argument', ...
                    'IX_divergence_profile: The profile values must all be finite and greater or equal to zero')
            end
            obj.name_ = val;
        end

        % Currently do not permit any - it only makes sense to change the
        % profile as a whole, which is best done with the constructor

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end

        function val=get.angles(obj)
            val=obj.angles_;
        end

        function val=get.profile(obj)
            val=obj.profile_;
        end
        %------------------------------------------------------------------
        function ver = classVersion(~)
            ver = 2;
        end
        function flds = saveableFields(~,mandatory)
            % Return cellarray of independent properties of the class
            %
            % If "mandatory" key is provided, return the subset of values
            % necessary for non-empty class to be defined
            if nargin>1
                mandatory = true;
            else
                mandatory = false;
            end
            flds = {'angles','profile','name'};
            if mandatory
                flds = flds(1:2);
            end

        end

        function obj = check_combo_arg(obj,do_recompute_pdf)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.
            if ~exist('do_recompute_pdf','var')
                do_recompute_pdf = true;
            end

            if any(obj.mandatory_field_set_) && ~all(obj.mandatory_field_set_)
                mandatory_field_names = obj.saveableFields('mandatory');
                error('HERBERT:IX_divirgence_profile:invalid_argument', ...
                    ' Must give all mandatory properties namely: %s.\n Properties: %s have not been set', ...
                    disp2str(mandatory_field_names), ...
                    disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
            end

            if numel(obj.angles_)~=numel(obj.profile_)
                error('HERBERT:IX_divirgence_profile:invalid_argument', ...
                    'The number of values of angles (%d) and profile (%d) must match',...
                    numel(angles_in),numel(profile_in))
            end

            if any(obj.mandatory_field_set_) && do_recompute_pdf
                % Compute the pdf
                obj.pdf_ = pdf_table (obj.angles_, obj.profile_);
            end
        end
        function [inputs,obj] = convert_old_struct(obj,inputs)
            % By default, this function interfaces the default from_struct
            % function, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
        end
		
    end

    methods(Access=protected)
        %------------------------------------------------------------------
    end
    %
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available
            obj = IX_divergence_profile();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end
    %======================================================================

end

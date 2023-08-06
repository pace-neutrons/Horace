classdef IX_doubledisk_chopper < serializable
    % Double disk chopper class definition

    properties (Access=protected)
        % Actual properties values - but kept protected and accessible
        % only through public dependent properties because validity checks
        % of setters require checks against the other properties.
        %
        name_ = '';
        distance_ = 0;
        frequency_ = 0;
        radius_ = 0;
        slot_width_ = 0;
        aperture_width_ = 0;
        aperture_width_defined_ = false;
        aperture_height_ = 0;
        jitter_ = 0;
        pdf_ = []   % This is effectively a cached dependent variable
        mandatory_field_set_ = false(1,4)
    end

    properties (Dependent)
        % Mirrors of private properties
        name
        distance
        frequency
        radius
        slot_width
        % beware that value of aperture_width is equal to value in
        % aperture_width_ only when aperture_width_defined_ == true. Otherwise
        % it is equal to slot_width. Use public aperture_width value in
        % all internal class calculations.
        aperture_width
        aperture_height
        jitter
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_doubledisk_chopper (varargin)
            % Create double-disk chopper object
            %
            %   >> chop = IX_doubledisk_chopper (distance,frequency,radius,slot_width)
            %
            %   >> chop = IX_doubledisk_chopper (...,aperture_width);
            %   >> chop = IX_doubledisk_chopper (...,aperture_width,aperture_height);
            %   >> chop = IX_doubledisk_chopper (...,aperture_width,aperture_height,jitter);
            %   >> chop = IX_doubledisk_chopper (...,aperture_width,aperture_height,jitter,name);
            %
            % Required:
            %   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
            %   frequency       Frequency of rotation of each disk (Hz)
            %   radius          Radius of chopper body (m)
            %   slot_width      Slot width (m)
            %
            % Optional:
            %   aperture_width  Aperture width (m) (Default: same as slot_width)
            %   aperture_height Aperture height (m)
            %   jitter          Timing uncertainty on chopper (FWHH) (microseconds)
            %
            %   name            Name of the chopper (e.g. 'chopper_5')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbrevioations) e.g.:
            %
            %   >> chop = IX_doubledisk_chopper (distance,frequency,radius,slot_width,...
            %               'jitter',3.5,'name','Chopper_1')


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_doubledisk_chopper.loadobj(varargin{1});

            elseif nargin==0
                % Compute the pdf for the default object
                obj.pdf_ = recompute_pdf_(obj);

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
                    error('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_doubledisk_chopper constructor: %s',...
                        disp2str(remains));
                end
            end
        end
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
                    'Disk chopper name must be a character string (or empty string)')
            end
        end

        function obj=set.distance(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
                obj.mandatory_field_set_(1) =true;
            else
                error('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
                    'Distance must be a numeric scalar')
            end
        end

        function obj=set.frequency(obj,val)
            val_old = obj.frequency_;
            obj = check_and_set_positive_scalar_(obj,'frequency_',val);
            obj.mandatory_field_set_(2) =true;
            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set
                recompute_pdf = obj.frequency_~=val_old;  % recompute the lookup table
                obj.pdf_ = obj.check_combo_arg(recompute_pdf );
            end
        end

        function obj=set.radius(obj,val)
            val_old = obj.radius_;
            obj = check_and_set_positive_scalar_(obj,'radius_',val);
            obj.mandatory_field_set_(3) =true;

            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set
                recompute_pdf = obj.radius_~=val_old;  % recompute the lookup table
                obj.pdf_ = obj.check_combo_arg(recompute_pdf );
            end
        end

        function obj=set.slot_width(obj,val)
            val_old = obj.slot_width_;
            obj = check_and_set_positive_scalar_(obj,'slot_width_',val);
            obj.mandatory_field_set_(4) =true;
            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set
                recompute_pdf = obj.slot_width_~=val_old;
                obj.pdf_ = obj.check_combo_arg(recompute_pdf);
            end
        end

        function obj=set.aperture_width(obj,val)
            val_old = obj.aperture_width_;
            obj = check_and_set_positive_scalar_(obj,'aperture_width_',val);
            obj.aperture_width_defined_=true;

            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set
                recompute_pdf = obj.aperture_width_~=val_old;
                obj.pdf_ = obj.check_combo_arg(recompute_pdf);
            end
        end

        function obj=set.aperture_height(obj,val)
            obj = check_and_set_positive_scalar_(obj,'aperture_height_',val);
        end

        function obj=set.jitter(obj,val)
            val_old = obj.jitter_;
            obj = check_and_set_positive_scalar_(obj,'jitter_',val);
            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set

                recompute_pdf =  obj.jitter_~=val_old;
                obj.pdf_ = obj.check_combo_arg(recompute_pdf);
            end
        end

        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val=get.name(obj)
            val=obj.name_;
        end

        function val=get.distance(obj)
            val=obj.distance_;
        end

        function val=get.frequency(obj)
            val=obj.frequency_;
        end

        function val=get.radius(obj)
            val=obj.radius_;
        end

        function val=get.slot_width(obj)
            val=obj.slot_width_;
        end

        function val=get.aperture_width(obj)
            if obj.aperture_width_defined_
                val=obj.aperture_width_;
            else
                val=obj.slot_width_;
            end
        end

        function val=get.aperture_height(obj)
            val=obj.aperture_height_;
        end

        function val=get.jitter(obj)
            val=obj.jitter_;
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

            flds = {'distance','frequency','radius','slot_width',...
                'aperture_width','aperture_height','jitter','name'};
            if mandatory
                flds = flds(1:4);
            end

        end
        function obj = check_combo_arg(obj,do_recompute_pdf)
            % verify interdependent variables and the validity of the
            % obtained serializable object. Return the result of the check
            %
            % Overload to obtain information about the validity of
            % interdependent properties and information about issues with
            % interdependent properties

            % Throw if the properties are inconsistent and return without
            % problem it they are not, after recomputing pdf table if
            % requested.
            if ~all(obj.mandatory_field_set_)
                mandatory_field_names = obj.saveableFields('mandatory');
                error('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
                    ' Must give all mandatory properties namely: %s.\n Properties: %s have not been set', ...
                    disp2str(mandatory_field_names), ...
                    disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
            end
            %
            if obj.aperture_width_defined_
                if obj.aperture_width_<obj.slot_width
                    warning('HERBERT:IX_doubledisk_chopper:invalid_argument', ...
                        'aperture_width=%g have been set smaller than the slot_width=%g. This is incorrect so will use slot_width as aperture_width',...
                        obj.aperture_width_,obj.slod_width)
                    obj.aperture_width = obj.slot_width;
                    do_recompute_pdf= true;
                end
            end

            if ~exist('do_recompute_pdf','var')
                do_recompute_pdf = true;
            end
            if do_recompute_pdf
                obj.pdf_ = recompute_pdf_(obj);   % recompute the lookup table
            end
        end
    end
    methods(Access=protected)
        function [inputs,obj] = convert_old_struct(obj,inputs,varargin)
            % By default, this function interfaces the default from_struct
            % function, but when the old structure substantially differs from
            % the modern structure, this method needs the specific overloading
            % to allow loadobj to recover new structure from an old structure.
            inputs = convert_old_struct_(obj,inputs);
        end
    end
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = IX_doubledisk_chopper();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------
    end
    %======================================================================

end

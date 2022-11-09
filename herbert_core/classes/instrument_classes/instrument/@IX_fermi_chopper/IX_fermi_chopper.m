classdef IX_fermi_chopper < serializable
    % Fermi chopper class definition
    properties (Constant, Access=private)
        % Conversion constant. Should replace by a class that gives constants
        c_e_to_t_ = 2.286271439537201e+03;
    end

    properties (Access=protected)
        % Stored properties - but kept protected and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        %
        % We use a trick to cache the probability distribution function for
        % random sampling. It is a private non-dependent property, but is
        % recomputed whenever a public (and in this class) dependent property
        % is changed that could alter it.
        %
        name_ = '';
        distance_ = 0;
        frequency_ = 0;
        radius_ = 0;
        curvature_ = 0;
        slit_width_ = 0;
        slit_spacing_ = 0;
        width_ = 0;
        height_ = 0;
        energy_ = 0;
        phase_ = true;
        jitter_ = 0;
        % array used in the checks for interdependent properties to ensure
        % that all interdependent properties are set
        mandatory_field_set_ = false(1,5);
        %
        pdf_    % This is effectively a cached dependent variable
    end

    properties (Dependent)
        % Public accessors to the protected properties
        name
        distance
        frequency
        radius
        curvature
        slit_width
        slit_spacing
        width
        height
        energy
        phase
        jitter
    end

    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = IX_fermi_chopper (varargin)
            % Create fermi chopper object
            %
            %   >> chop = IX_fermi_chopper (distance,frequency,radius,curvature,slit_width)
            %
            %   >> chop = IX_fermi_chopper (...,slit_spacing)
            %   >> chop = IX_fermi_chopper (...,slit_spacing,width,height);
            %   >> chop = IX_fermi_chopper (...,slit_spacing,width,height,energy);
            %   >> chop = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase);
            %   >> chop = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase,jitter);
            %   >> chop = IX_fermi_chopper (...,slit_spacing,width,height,energy,phase,jitter,name);
            %
            % Required:
            %   distance        Distance from sample (m) (+ve if upstream of sample, against the usual convention)
            %   frequency       Frequency of rotation (Hz)
            %   radius          Radius of chopper body (m)
            %   curvature       Radius of curvature of slits (m)
            %   slit_width      Slit width (m)
            %
            % Optional:
            %   slit_spacing    Spacing between slit centres (m)
            %   width           Width of aperture (m)
            %   height          Height of aperture (m)
            %   energy          Energy of neutrons transmitted by chopper (mev)
            %   phase           Phase = true if optimally phased, =false if 180 degree rotated
            %   jitter          Timing uncertainty on chopper (FWHH) (microseconds)
            %
            %   name            Name of the slit package (e.g. 'sloppy')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbrevioations) e.g.:
            %
            %   >> chop = IX_fermi_chopper (distance,frequency,radius,curvatue,...
            %               slit_width,'energy',120,'name','Chopper_1')


            % Original author: T.G.Perring


            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_fermi_chopper.loadobj(varargin{1});

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
                    error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                        'Unrecognized extra parameters provided as input to IX_fermi_chopper constructor: %s',...
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
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Fermi chopper name must be a character string (or empty string). It is %s', ...
                    disp2str(val));
            end
        end
        function obj=set.distance(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.mandatory_field_set_(1) = true;
                obj.distance_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Distance must be a numeric scalar. It is: %s',...
                    disp2str(val));
            end
        end
        function obj=set.frequency(obj,val)
            obj = check_and_set_frequency_(obj,val);
        end

        function obj=set.radius(obj,val)
            obj = check_and_set_radius_(obj,val);
        end

        function obj=set.curvature(obj,val)
            val_old = obj.curvature_;
            if isscalar(val) && isnumeric(val) && val>=0
                obj.mandatory_field_set_(4) = true;
                obj.curvature_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Slit radius of curvature must be a numeric scalar greater or equal to zero. It is %s',...
                    disp2str(val));
            end
            if obj.do_check_combo_arg_ % not a check but done this way to avoid
                % pdf recalculations if multiple properties are set
                recompute_pdf = obj.curvature_~=val_old; % recompute the lookup table
                obj = obj.check_combo_arg(recompute_pdf);
            end

        end

        function obj=set.slit_width(obj,val)
            obj =check_and_set_slit_width_(obj,val);
        end

        function obj=set.slit_spacing(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.slit_spacing_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Slit spacing must be a numeric scalar greater or equal to the slit width. It is: %s',...
                    disp2str(val));
            end
            if obj.do_check_combo_arg_
                obj = obj.check_combo_arg(false);
            end
        end

        function obj=set.width(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Chopper aperture width must be a numeric scalar greater or equal to zero It is: %s', ...
                    disp2str(val));
            end

        end

        function obj=set.height(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Chopper aperture height must be a numeric scalar greater or equal to zero It is: %s', ...
                    disp2str(val));
            end

        end

        function obj=set.energy(obj,val)
            val_old = obj.energy_;
            if isscalar(val) && isnumeric(val) && val>=0
                obj.energy_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Energy must be a numeric scalar greater or equal to zero It is: %s', ...
                    disp2str(val));
            end
            if obj.do_check_combo_arg_
                recompute_pdf = obj.energy_~=val_old;
                obj = obj.check_combo_arg(recompute_pdf);
            end
        end

        function obj=set.phase(obj,val)
            val_old = obj.phase_;
            if islognumscalar(val)
                obj.phase_=logical(val);
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Chopper phase type must be true or false (or 1 or 0)')
            end
            if obj.do_check_combo_arg_
                recompute_pdf = obj.phase_~=val_old;  % recompute the lookup table
                obj = obj.check_combo_arg(recompute_pdf);
            end
        end

        function obj=set.jitter(obj,val)
            val_old = obj.jitter_;
            if isscalar(val) && isnumeric(val) && val>=0
                obj.jitter_=val;
            else
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Timing jitter must be a numeric scalar greater or equal to zero. It is: %s',...
                    disp2str(val));
            end
            if obj.do_check_combo_arg_
                recompute_pdf = obj.jitter_~=val_old;  % recompute the lookup table
                obj = obj.check_combo_arg(recompute_pdf);
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

        function val=get.curvature(obj)
            val=obj.curvature_;
        end

        function val=get.slit_width(obj)
            val=obj.slit_width_;
        end

        function val=get.slit_spacing(obj)
            val=obj.slit_spacing_;
        end

        function val=get.width(obj)
            val=obj.width_;
        end

        function val=get.height(obj)
            val=obj.height_;
        end

        function val=get.energy(obj)
            val=obj.energy_;
        end

        function val=get.phase(obj)
            val=obj.phase_;
        end

        function val=get.jitter(obj)
            val=obj.jitter_;
        end

        %------------------------------------------------------------------
        function pdf = recompute_pdf_ (self)
            % Compute the pdf_table object if there is non-zero transmission
            npnt = 100;
            if self.transmission()>0
                [tlo, thi] = pulse_range(self);
                t = linspace(tlo,thi,npnt);
                y = pulse_shape(self, t);
                pdf = pdf_table(t,y);
            else
                pdf = pdf_table();
            end
        end

        %------------------------------------------------------------------
        % Recover pdf not as a property but via method
        function pdf = pdf_table(self)
            if ~isscalar(self)
                error('HORACE:IX_fermi_chopper:runtime_error',...
                    'Method only takes a scalar Fermi chopper object')
            end

            pdf = self.pdf_;
        end

        %------------------------------------------------------------------
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
            if obj.slit_width_>obj.slit_spacing_
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Slit width= %g  and must be less than or equal to the slit spacing= %g',obj.slit_width_)
            end


            if ~all(obj.mandatory_field_set_)
                mandatory_field_names = obj.saveableFields('mandatory');
                error('HERBERT:IX_fermi_chopper:invalid_argument', ...
                    'Must give all mandatory properties namely: %s\n. Properties: %s have not been set', ...
                    disp2str(mandatory_field_names),...
                    disp2str(mandatory_field_names(~obj.mandatory_field_set_)));
            end

            if do_recompute_pdf
                obj.pdf_ = recompute_pdf_(obj);   % recompute the lookup table
            end
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
            flds = {'distance','frequency','radius','curvature','slit_width',...
                'slit_spacing','width','height','energy',...
                'phase','jitter','name'};
            if mandatory
                flds = flds(1:5);
            end
        end

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

    %------------------------------------------------------------------
    methods (Static)
        function obj = loadobj(S)
            % overloaded loadobj method, calling generic method of
            % saveable class necessary for loading old class versions
            % which are converted into structure when recovered as class is
            % not available any more
            obj = IX_fermi_chopper();
            obj = loadobj@serializable(S,obj);
        end
        %------------------------------------------------------------------

    end
    %======================================================================

end

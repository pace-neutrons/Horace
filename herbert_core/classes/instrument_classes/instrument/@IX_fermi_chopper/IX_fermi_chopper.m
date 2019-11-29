classdef IX_fermi_chopper
    % Fermi chopper class definition
    properties (Constant, Access=private)
        % Conversion constant. Should replace by a class that gives constants
        c_e_to_t_ = 2.286271439537201e+03;
    end
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        %
        % We use a trick to cache the probability distribution function for
        % random sampling. It is a private non-dependent property, but is
        % recomputed whenever a public (and in this class) dependent property
        % is changed that could alter it.
        %
        % ***************************************************************
        %    WARNING: Do not change the value of any private property
        %             within a class method. This risks making pdf_
        %             out of synchronisation with the other properties.
        %             Only change the public properties, as this will force
        %             a recalculation.
        % ***************************************************************
        class_version_ = 1;
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
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
    end
    
    properties (Dependent)
        % Mirrors of private properties
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
            %
            %   >> chop = IX_fermi_chopper (name,...)
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
            %   phase           Phase = true if correctly phased, =false if 180 degree rotated
            %   jitter          Timing uncertainty on chopper (FWHH) (microseconds)
            %
            %   name            Name of the slit package (e.g. 'sloppy')
            %
            %
            % Note: any number of the arguments can given in arbitrary order
            % after leading positional arguments if they are preceded by the
            % argument name (including abbrevioations) with a preceding hyphen e.g.
            %
            %   >> chop = IX_fermi_chopper (distance,frequency,radius,curvatue,...
            %               slit_width,'-energy',120,'-name','Chopper_1')
            
            
            % Original author: T.G.Perring
            
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin==1 && isstruct(varargin{1})
                % Assume trying to initialise from a structure array of properties
                obj = IX_fermi_chopper.loadobj(varargin{1});
                
            elseif nargin>0
                namelist = {'name','distance','frequency','radius','curvature',...
                    'slit_width','slit_spacing','width','height','energy','phase','jitter'};
                [S, present] = parse_args_namelist ({namelist,{'char'}}, varargin{:});
                
                if present.name
                    obj.name_ = S.name;
                end
                
                if present.distance && present.frequency && present.radius &&...
                        present.curvature && present.slit_width
                    obj.distance_  = S.distance;
                    obj.frequency_ = S.frequency;
                    obj.radius_    = S.radius;
                    obj.curvature_ = S.curvature;
                    obj.slit_width_= S.slit_width;
                else
                    error ('Must give all of distance, frequency, radius, curvature and slit_width')
                end
                
                if present.slit_spacing
                    obj.slit_spacing_ = S.slit_spacing;
                    if obj.slit_spacing_ < obj.slit_width_
                        error('slit_spacing must be greater or equal to slit_width')
                    end
                else
                    obj.slit_spacing_ = obj.slit_width_;
                end
                % 'width','height','energy','phase','jitter'};
                if present.width
                    obj.width_ = S.width;
                end
                
                if present.height
                    obj.height_ = S.height;
                end
                
                if present.energy
                    obj.energy_ = S.energy;
                end
                
                if present.phase
                    obj.phase_ = S.phase;
                end
                
                if present.jitter
                    obj.jitter_ = S.jitter;
                end
                
                % Compute the pdf
                obj.pdf_ = recompute_pdf_(obj);
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
        
        function obj=set.name_(obj,val)
            if is_string(val)
                obj.name_=val;
            else
                error('Fermi chopper name must be a character string (or empty string)')
            end
        end
        
        function obj=set.distance_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.distance_=val;
            else
                error('Distance must be a numeric scalar')
            end
        end
        
        function obj=set.frequency_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.frequency_=val;
            else
                error('Frequency must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.radius_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.radius_=val;
            else
                error('Fermi chopper radius must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.curvature_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.curvature_=val;
            else
                error('Slit radius of curvature must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.slit_width_=val;
            else
                error('Slit width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.slit_spacing_(obj,val)
            if isscalar(val) && isnumeric(val)
                obj.slit_spacing_=val;
            else
                error('Slit spacing must be a numeric scalar greater or equal to the slit width')
            end
        end
        
        function obj=set.width_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.width_=val;
            else
                error('Chopper aperture width must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.height_=val;
            else
                error('Chopper aperture height must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.energy_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.energy_=val;
            else
                error('Energy must be a numeric scalar greater or equal to zero')
            end
        end
        
        function obj=set.phase_(obj,val)
            if islognumscalar(val)
                obj.phase_=logical(val);
            else
                error('Chopper phase type must be true or false (or 1 or 0)')
            end
        end
        
        function obj=set.jitter_(obj,val)
            if isscalar(val) && isnumeric(val) && val>=0
                obj.jitter_=val;
            else
                error('Timing jitter must be a numeric scalar greater or equal to zero')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        %
        % The checks on type, size etc. are performed in the set methods
        % for the non-dependent properties. However, any interdependencies with
        % other properties must be checked here.
        function obj=set.name(obj,val)
            obj.name_=val;
        end
        
        function obj=set.distance(obj,val)
            obj.distance_=val;
        end
        
        function obj=set.frequency(obj,val)
            val_old = obj.frequency_;
            obj.frequency_=val;
            if obj.frequency_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.radius(obj,val)
            val_old = obj.radius_;
            obj.radius_=val;
            if obj.radius_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.curvature(obj,val)
            val_old = obj.curvature_;
            obj.curvature_=val;
            if obj.curvature_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.slit_width(obj,val)
            val_old = obj.slit_width_;
            
            obj.slit_width_=val;
            if obj.slit_width_>obj.slit_spacing_
                error('Slit width must be less than or equal to the slit spacing')
            end
            
            if obj.slit_width_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.slit_spacing(obj,val)
            obj.slit_spacing_=val;
            if obj.slit_spacing_<obj.slit_width_
                error('Slit spacing must be greater or equal to the slit width')
            end
        end
        
        function obj=set.width(obj,val)
            obj.width_=val;
        end
        
        function obj=set.height(obj,val)
            obj.height_=val;
        end
        
        function obj=set.energy(obj,val)
            val_old = obj.energy_;
            obj.energy_=val;
            if obj.energy_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.phase(obj,val)
            val_old = obj.phase_;
            obj.phase_=val;
            if obj.phase_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
            end
        end
        
        function obj=set.jitter(obj,val)
            val_old = obj.jitter_;
            obj.jitter_=val;
            if obj.jitter_~=val_old
                obj.pdf_ = recompute_pdf_(obj);     % recompute the lookup table
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
            if ~isscalar(self), error('Method only takes a scalar Fermi chopper object'), end
            pdf = self.pdf_;
        end
        
        %------------------------------------------------------------------
        
    end
    
    %======================================================================
    % Methods for fast construction of structure with independent properties
    methods (Static, Access = private)
        function names = propNamesIndep_
            % Determine the independent property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = fieldnamesIndep(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function names = propNamesPublic_
            % Determine the visible public property names and cache the result.
            % Code is boilerplate
            persistent names_store
            if isempty(names_store)
                names_store = properties(eval(mfilename('class')));
            end
            names = names_store;
        end
        
        function struc = scalarEmptyStructIndep_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesIndep_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
        
        function struc = scalarEmptyStructPublic_
            % Create a scalar structure with empty fields, and cache the result
            % Code is boilerplate
            persistent struc_store
            if isempty(struc_store)
                names = eval([mfilename('class'),'.propNamesPublic_''']);
                arg = [names; repmat({[]},size(names))];
                struc_store = struct(arg{:});
            end
            struc = struc_store;
        end
    end
    
    methods
        function S = structIndep(obj)
            % Return the independent properties of an object as a structure
            %
            %   >> s = structIndep(obj)
            %
            % Use <a href="matlab:help('structArrIndep');">structArrIndep</a> to convert an object array to a structure array
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structPublic, structArrIndep, structArrPublic
            
            names = obj.propNamesIndep_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrIndep(obj)
            % Return the independent properties of an object array as a structure array
            %
            %   >> s = structArrIndep(obj)
            %
            % Use <a href="matlab:help('structIndep');">structIndep</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structIndep, structPublic, structArrPublic
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structIndep(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesIndep_';
                S = obj.scalarEmptyStructIndep_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
        
        function S = structPublic(obj)
            % Return the public properties of an object as a structure
            %
            %   >> s = structPublic(obj)
            %
            % Use <a href="matlab:help('structArrPublic');">structArrPublic</a> to convert an object array to a structure array
            %
            % Has the same behaviour as struct in that
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            % - If the object is non-empty array, returns a scalar structure corresponding
            %   to the the first element in the array of objects
            %
            %
            % See also structIndep, structArrPublic, structArrIndep
            
            names = obj.propNamesPublic_';
            if ~isempty(obj)
                tmp = obj(1);
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = tmp.(names{i});
                end
            else
                args = [names; repmat({cell(size(obj))},size(names))];
                S = struct(args{:});
            end
        end
        
        function S = structArrPublic(obj)
            % Return the public properties of an object array as a structure array
            %
            %   >> s = structArrPublic(obj)
            %
            % Use <a href="matlab:help('structPublic');">structPublic</a> for behaviour that more closely matches the Matlab
            % intrinsic function struct.
            %
            % Has the same behaviour as the Matlab instrinsic struct in that:
            % - Any structure array is returned unchanged
            % - If an object is empty, an empty structure is returned with fieldnames
            %   but the same size as the object
            %
            % However, differs in the behaviour if an object array:
            % - If the object is non-empty array, returns a structure array of the same
            %   size. This is different to the instrinsic Matlab, which returns a scalar
            %   structure from the first element in the array of objects
            %
            %
            % See also structPublic, structIndep, structArrIndep
            
            if numel(obj)>1
                S = arrayfun(@fill_it, obj);
            else
                S = structPublic(obj);
            end
            
            function S = fill_it (obj)
                names = obj.propNamesPublic_';
                S = obj.scalarEmptyStructPublic_;
                for i=1:numel(names)
                    S.(names{i}) = obj.(names{i});
                end
            end

        end
    end
    
    %======================================================================
    % Custom loadobj and saveobj
    % - to enable custom saving to .mat files and bytestreams
    % - to enable older class definition compatibility

    methods
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
            
            % The following is boilerplate code
            
            S = structIndep(obj);
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
            
            if isobject(S)
                obj = S;
            else
                obj = arrayfun(@(x)loadobj_private_(x), S);
            end
        end
        %------------------------------------------------------------------
        
    end
    %======================================================================
    
end

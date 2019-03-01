classdef IXX_divergence_profile
    % Divergence profile class definition
    
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
        name_ = '';
        angles_ = [];
        profile_ = [];
        pdf_ = pdf_table();     % This is effectively a cached dependent variable
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
        function obj = IXX_divergence_profile (varargin)
            % Create fermi chopper object
            %
            %   >> div = IX_divergence_profile (angle,profile)
            %
            %   >> div = IX_divergence_profile (name,...)
            %
            %   name            Name of the divergence profile (e.g. 'LET new vertical')
            %   angles          Vector of divergences (radians)
            %   profile         Vector with profile. Does not need to be normalised
            
            % Original author: T.G.Perring
            
            % Use the non-dependent property set functions to force a check of type,
            % size etc.
            if nargin>0
                noff=0;
                if is_string(varargin{1})
                    obj.name_ = varargin{1};
                    noff=noff+1;
                end
                if nargin-noff==2
                    angles_in  = varargin{noff+1};
                    profile_in = varargin{noff+2};
                    
                    if isnumeric(angles_in) && isvector(angles_in) && numel(angles_in)>=2 && all(diff(angles_in)>=0)
                        obj.angles_=angles_in(:)';  % make a row vector
                    else
                        error('Angle array must be a vector length at least two and monotonic increasing')
                    end
                    
                    if numel(angles_in)~=numel(profile_in)
                        error('The number of values of angles and profile must match')
                    elseif isvector(profile_in) && all(isfinite(profile_in)) && all(profile_in)>=0
                        obj.profile_=profile_in(:)';
                    else
                        error('The profile values must all be finite and greater or equal to zero')
                    end
                    
                else
                    error('Check number of input arguments')
                end
                % Compute the pdf
                obj.pdf_ = pdf_table (obj.angles_, obj.profile_);
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
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
        % Recover pdf not as a property but via method
        function pdf = pdf_table(self)
            if ~isscalar(self), error('Method only takes a scalar divergence object'), end
            pdf = self.pdf_;
        end
        
        %------------------------------------------------------------------
        
    end
end

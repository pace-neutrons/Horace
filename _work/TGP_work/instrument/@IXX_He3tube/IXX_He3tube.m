classdef IXX_He3tube
    %IX_He3tube Defines array of cylindrical 3He detectors
    %   Defines cylindrical 3He gas tube properties on which efficiency,
    %   depth of absortption etc depend, namely diameter, wall thickness
    %   partial pressure of 3He. It does not define pixellation or
    %   length of tube - those preoperties are considered geometric
    %   properties that belong elsewhere.
    
    % Original author: T.G.Perring
    %
    % $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_ = 0;       % Outer diameter of tube (m)
        height_ = 0     % Height (m)
        thick_ = 0;     % Wall thickness (m)
        atms_ = 0;      % 3He partial pressure (atmospheres)
        theta_ = (pi/2) % Angle between neutron path and tube axis (radians)
        
        % The following are really dependent, but should be cached to speed calculations
        sintheta_ = sin(pi/2)   % sin(theta)
        costheta_ = cos(pi/2)   % cos(theta) (note: in matlab, cos(pi/2) = 6.1232e-17 ~= 0!
    end
    
    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        height      % height (m)
        thick       % Wall thickness (m)
        atms        % 3He partial pressure (atmospheres)
        theta       % Angle between neutron path and tube axis 
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties
        ndet        % Number of detectors
        inner_rad   % Inner radius of tube(m)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IXX_He3tube(dia, height, thick, atms, theta)
            % Constructor for IX_He3tube object
            %
            %   >> obj = IXX_He3tube(dia, height, thick, atms)
            %   >> obj = IXX_He3tube(dia, height, thick, atms, theta)
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   dia         Outer diameter(s) of tube (m)
            %   height      Height of element(s) (m)
            %   thick       Wall thickness(es) (m)
            %   atms        3He partial pressure(s) (atmospheres)
            %   theta       Angle between neutron path and tube axis (radians)
            %                   theta = pi/2 if perpendicular to the tube axis
            %                   theta = 0 if along the tube axis in positive z direction
            %                   theta = pi if along the negave z direction 
            %               Default: pi/2 if not given (i.e. perpendicular)
            
            
            if nargin>0
                if nargin==4
                    [dia_exp, height_exp, thick_exp, atms_exp] = expand_args...
                        (dia, height, thick, atms);
                    theta_exp = (pi/2)*ones(size(dia_exp));
                else
                    [dia_exp, height_exp, thick_exp, atms_exp, theta_exp] = expand_args...
                        (dia, height, thick, atms, theta);
                end
                
                obj.dia_      = dia_exp;
                obj.height_   = height_exp;
                obj.thick_    = thick_exp;
                obj.atms_     = atms_exp;
                obj.theta_    = theta_exp;
                [obj.sintheta_,obj.costheta_] = sincos(obj.theta_);
                
                if ~all(obj.dia_>=2*obj.thick_)
                    error('Tube diameter(s) must be greater or equal to twice the wall thickness(es)')
                end
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        function obj=set.dia_(obj,val)
            if all(val(:) >= 0)
                obj.dia_ = val(:);
            else
                error('Tube diameter(s) must be greater or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if all(val(:) >= 0)
                obj.height_ = val(:);
            else
                error('Detector element height(s) must be greater or equal to zero')
            end
        end
        
        function obj=set.thick_(obj,val)
            if all(val(:) >= 0)
                obj.thick_ = val(:);
            else
                error('Wall thickness(es) must be greater or equal to zero')
            end
        end
        
        function obj=set.atms_(obj,val)
            if all(val(:) >= 0)
                obj.atms_ = val(:);
            else
                error('Partial pressure(s) of 3He must be greater or equal to zero')
            end
        end
        
        function obj=set.theta_(obj,val)
            if all(val(:) >= 0) && all(val(:) <= pi)
                obj.theta_ = val(:);
            else
                error('theta must lie on the range 0 to pi inclusive')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            val = expand_arg_by_ref (val, obj.dia_);
            if all(val>=2*obj.thick_)
                obj.dia_=val;
            else
                error('Tube diameter(s) must be greater or equal to twice the wall thickness(es)')
            end
        end
        
        function obj=set.height(obj,val)
            obj.height_ = expand_arg_by_ref (val, obj.height_);
        end
        
        function obj=set.thick(obj,val)
            val = expand_arg_by_ref (val, obj.thick_);
            if all(val<=obj.dia_/2)
                obj.thick_=val;
            else
                error('Tube wall thickness(es) must be less than or equal to the radii')
            end
        end
        
        function obj=set.atms(obj,val)
            obj.atms_ = expand_arg_by_ref (val, obj.atms_);
        end
        
        function obj=set.theta(obj,val)
            obj.theta_ = expand_arg_by_ref (val, obj.theta_);
            [obj.sintheta_,obj.costheta_] = sincos(obj.theta_);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.dia(obj)
            val = obj.dia_;
        end
        
        function val = get.height(obj)
            val = obj.height_;
        end
        
        function val = get.thick(obj)
            val = obj.thick_;
        end
        
        function val = get.atms(obj)
            val = obj.atms_;
        end
        
        function val = get.theta(obj)
            val = obj.theta_;
        end
        
        function val = get.ndet(obj)
            val = numel(obj.dia_);
        end
        
        function val = get.inner_rad(obj)
            val = 0.5*obj.dia_ - obj.thick_;
        end
        %------------------------------------------------------------------
        
    end
    
end

%------------------------------------------------------------------
function val_out = expand_arg_by_ref (val, ref)
% Expand a scalar argument to size of reference, or check the number of elements
% matches the reference.
% The returned result is a column vector.

if isscalar(val)
    val_out = repmat (val, numel(ref), 1);
elseif ~isempty(val) && numel(val)==numel(ref)
    val_out = val(:);
else
    throwAsCaller(MException('expand_arg_by_ref:invalid_argument',...
        'Argument must be scalar or have same number of elements as the one it is replacing'))
end
end

%------------------------------------------------------------------
function [s,c] = sincos (val)
% Calculate sin(val) and cos(val). Seems silly to do this, but it ensures that
% an identical process is performed to compute these cached arguments. Implemented
% because in Matlab cos(pi/2) = 6.1232e-17 ~= 0, so want ensure absolute consistency
% at all points of calculation on sin and cos
s = sin(val);
c = cos(val);
end


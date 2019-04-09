classdef IXX_DetectorTobyfitClassic
    % Defines a detector type that reproduces the results of original Tobyfit.
    % The tube axes are assumed always to be perpendicular to the neutron path.
    % The distance variances and random points are returned as old Tobyfit.
    % Efficiency is returned as unity and distance averages as zero.
    % Created solely to enable tests of Tobyfit against the original version.
    
    % Original author: T.G.Perring
    %
    % $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_ = 0;       % Outer diameter of tube (m)
        height_ = 0     % Height (m)
    end
    
    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        height      % height (m)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties
        ndet        % Number of detectors
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IXX_DetectorTobyfitClassic(dia, height)
            % Constructor for IX_He3tube object
            %
            %   >> obj = IXX_He3tube(dia, height)
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   dia         Outer diameter(s) of tube (m)
            %   height      Height of element(s) (m)
            
            
            if nargin>0
                [dia_exp, height_exp] = expand_args (dia, height);
                obj.dia_      = dia_exp;
                obj.height_   = height_exp;
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
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            obj.dia_ = expand_arg_by_ref (val, obj.dia_);
        end
        
        function obj=set.height(obj,val)
            obj.height_ = expand_arg_by_ref (val, obj.height_);
        end
                
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.dia(obj)
            val = obj.dia_;
        end
        
        function val = get.height(obj)
            val = obj.height_;
        end
        
        function val = get.ndet(obj)
            val = numel(obj.dia_);
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


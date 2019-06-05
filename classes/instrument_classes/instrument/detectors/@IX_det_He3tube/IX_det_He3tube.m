classdef IX_det_He3tube < IX_det_abstractType
    % IX_det_He3tube Defines array of cylindrical 3He detectors
    % Defines cylindrical 3He gas tube properties on which efficiency,
    % depth of absortption etc depend, namely diameter, wall thickness
    % partial pressure of 3He.
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.
    
    
    % Original author: T.G.Perring
    %
    % $Revision: 841 $ ($Date: 2019-02-11 14:13:46 +0000 (Mon, 11 Feb 2019) $)
    
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        dia_    = 0;    % Outer diameter of tube (m) (column vector)
        height_ = 0     % Height (m) (column vector)
        wall_   = 0;    % Wall thickness (m) (column vector)
        atms_   = 0;    % 3He partial pressure (atmospheres) (column vector)
    end
    
    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m) (column vector)
        height      % height (m) (column vector)
        wall        % Wall thickness (m) (column vector)
        atms        % 3He partial pressure (atmospheres) (column vector)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties
        inner_rad   % Inner radius of tube(m)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties required by abstract template
        ndet        % Number of detectors
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_He3tube(dia, height, wall, atms)
            % Constructor for cylindical 3He detector
            %
            %   >> obj = IX_det_He3tube (dia, height, wall, atms)
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   dia         Outer diameter(s) of tube (m)
            %   height      Height of element(s) (m)
            %   wall        Wall thickness(es) (m)
            %   atms        3He partial pressure(s) (atmospheres)
            
            if nargin>0
                [dia_exp, height_exp, wall_exp, atms_exp] = expand_args...
                    (dia, height, wall, atms);
                obj.dia_      = dia_exp;
                obj.height_   = height_exp;
                obj.wall_     = wall_exp;
                obj.atms_     = atms_exp;
                
                if ~ok_dia_and_wall (obj.dia_, obj.wall_)
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
        
        function obj=set.wall_(obj,val)
            if all(val(:) >= 0)
                obj.wall_ = val(:);
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
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.dia(obj,val)
            val = expand_args_by_ref (obj.dia_, val);
            if ok_dia_and_wall(val(:), obj.wall_)
                obj.dia_=val;
            else
                error('Tube diameter(s) must be greater or equal to twice the wall thickness(es)')
            end
        end
        
        function obj=set.height(obj,val)
            obj.height_ = expand_args_by_ref (obj.height_, val);
        end
        
        function obj=set.wall(obj,val)
            val = expand_args_by_ref (obj.wall_, val);
            if ok_dia_and_wall(obj.dia_, val(:))
                obj.wall_=val;
            else
                error('Tube wall thickness(es) must be less than or equal to the radii')
            end
        end
        
        function obj=set.atms(obj,val)
            obj.atms_ = expand_args_by_ref (obj.atms_, val);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.dia(obj)
            val = obj.dia_;
        end
        
        function val = get.height(obj)
            val = obj.height_;
        end
        
        function val = get.wall(obj)
            val = obj.wall_;
        end
        
        function val = get.atms(obj)
            val = obj.atms_;
        end
        
        function val = get.inner_rad(obj)
            val = 0.5*(obj.dia_ - 2*obj.wall_);
        end
        
        function val = get.ndet(obj)
            val = numel(obj.dia_);
        end
        %------------------------------------------------------------------
        
    end
    
end

%--------------------------------------------------------------------------
function status = ok_dia_and_wall (dia, wall)
% Check the consistency of tube diameter and wall thicjness in a standard way
status = all(dia(:)>=2*wall(:));
end

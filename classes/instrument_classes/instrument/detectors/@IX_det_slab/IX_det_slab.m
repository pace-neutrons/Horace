classdef IX_det_slab < IX_det_abstractType
    % IX_det_slab Slab detector type
    % Defines the size and abosrption of a cuboidal detector
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.
    
    
    % Original author: T.G.Perring
    %
    % $Revision: 841 $ ($Date: 2019-02-11 14:13:46 +0000 (Mon, 11 Feb 2019) $)
    
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % may require checks against the other properties
        class_version_ = 1;
        depth_  = 0;    % Column vector
        width_  = 0;    % Column vector
        height_ = 0;    % Column vector
        atten_  = 0;    % Column vector
    end
    
    properties (Dependent)
        % Mirrors of private properties
        depth       % Detector element thicknesses (m) (column vector)
        width       % Detector element widths (m) (column vector)
        height      % Detector element heights (m) (column vector)
        atten       % Attenuation length (to 1/e) at 2200 m/s (m) (column vector)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties required by abstract template
        ndet    % Number of detectors
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_slab (depth, width, height, atten)
            % Constructor for cuboidal detector
            %
            %   >> obj = IX_det_slab (depth, width, height, atten)
            %
            % The origin of the detector coordinate frame the the centre of the detector
            % and has x perpendicular to the detector face but into the detector. The
            % fron face of the detector is therefore at negative x.
            %
            % Input:
            % ------
            % All arguments can be scalar or arrays; all arrays must have the
            % same number of elements
            %
            %   depth       Depth of detector elements (m)      (x axis)
            %   width       Width of detector elements (m)       (y axis)
            %   height      Height of detector elements (m)   (z axis)
            %   atten       Attenuation distance at 2200 m/s (m)
            
            if nargin>0
                [depth_exp, width_exp, height_exp, atten_exp] = expand_args...
                    (depth, width, height, atten);
                obj.depth_   = depth_exp;
                obj.width_   = width_exp;
                obj.height_  = height_exp;
                obj.atten_   = atten_exp;
            end
        end
        
        %------------------------------------------------------------------
        % Set methods
        function obj=set.depth_(obj,val)
            if all(val(:) >= 0)
                obj.depth_ = val(:);
            else
                error('Detector element depth(s) must be greater or equal to zero')
            end
        end
        
        function obj=set.width_(obj,val)
            if all(val(:) >= 0)
                obj.width_ = val(:);
            else
                error('Detector element width(s) must be greater or equal to zero')
            end
        end
        
        function obj=set.height_(obj,val)
            if all(val(:) >= 0)
                obj.height_ = val(:);
            else
                error('Detector element height(s) must be greater or equal to zero')
            end
        end
        
        function obj=set.atten_(obj,val)
            if all(val(:) >= 0)
                obj.atten_ = val(:);
            else
                error('Detector element attenuation length(s) must be greater or equal to zero')
            end
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        function obj=set.depth(obj,val)
            obj.depth_ = expand_args_by_ref (obj.depth_, val);
        end
        
        function obj=set.width(obj,val)
            obj.width_ = expand_args_by_ref (obj.width_, val);
        end
        
        function obj=set.height(obj,val)
            obj.height_ = expand_args_by_ref (obj.height_, val);
        end
        
        function obj=set.atten(obj,val)
            obj.atten_ = expand_args_by_ref (obj.atten_, val);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function val = get.depth(obj)
            val = obj.depth_;
        end
        
        function val = get.width(obj)
            val = obj.width_;
        end
        
        function val = get.height(obj)
            val = obj.height_;
        end
        
        function val = get.atten(obj)
            val = obj.atten_;
        end
        
        function val = get.ndet(obj)
            val = numel(obj.depth_);
        end
        
        %------------------------------------------------------------------
        
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
            
            % The following is boilerplate code; it calls a class-specific function
            % called init_from_structure_ that takes a scalar structure and returns
            % a scalar instance of the class
            
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
            % called iniSt_from_structure_ that takes a scalar structure and returns
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

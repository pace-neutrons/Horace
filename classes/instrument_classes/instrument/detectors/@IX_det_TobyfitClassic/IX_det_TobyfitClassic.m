classdef IX_det_TobyfitClassic < IX_det_abstractType
    % Defines a detector type that reproduces the results of original Tobyfit.
    % The tube axes are assumed always to be perpendicular to the neutron path.
    % The distance variances and random points are returned as old Tobyfit.
    % Efficiency is returned as unity and distance averages as zero.
    %
    % Created solely to enable tests of Tobyfit against the original version.
    
    
    % Original author: T.G.Perring
    %
    % $Revision: 841 $ ($Date: 2019-02-11 14:13:46 +0000 (Mon, 11 Feb 2019) $)
    
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        class_version_ = 1;
        dia_ = 0;       % Outer diameter of tube (m)
        height_ = 0     % Height (m)
    end
    
    properties (Dependent)
        % Mirrors of private properties
        dia         % Outer diameter of tube (m)
        height      % height (m)
    end
    
    properties (Dependent, Hidden)
        % Other dependent properties required by abstract template
        ndet        % Number of detectors
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        function obj=IX_det_TobyfitClassic(dia, height)
            % Constructor for Tobyfit Classic detector object
            %
            %   >> obj = IX_det_TobyfitClassic (dia, height)
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
            obj.dia_ = expand_args_by_ref (obj.dia_, val);
        end
        
        function obj=set.height(obj,val)
            obj.height_ = expand_args_by_ref (obj.height_, val);
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

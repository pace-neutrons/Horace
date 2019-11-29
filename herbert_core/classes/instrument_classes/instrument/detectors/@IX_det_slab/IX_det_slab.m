classdef IX_det_slab < IX_det_abstractType
    % IX_det_slab Slab detector type
    % Defines the size and abosrption of a cuboidal detector
    %
    % The class does not define the position or orientation, which is done
    % elsewhere.
    
    
    % Original author: T.G.Perring
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    
    
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

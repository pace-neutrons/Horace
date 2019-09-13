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
    % $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)
    
    
    properties (Access=private)
        % Stored properties - but kept private and accessible only through
        % public dependent properties because validity checks of setters
        % require checks against the other properties
        class_version_ = 1; % Class version number
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

%--------------------------------------------------------------------------
function status = ok_dia_and_wall (dia, wall)
% Check the consistency of tube diameter and wall thicjness in a standard way
status = all(dia(:)>=2*wall(:));
end

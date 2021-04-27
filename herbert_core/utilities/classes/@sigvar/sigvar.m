classdef sigvar
    % Signal array and associated variances (standard errors squared)
    
    properties (Access=private)
        % Class version number
        class_version_ = 1;
        
        % Signal array
        % Numeric array of any size (including any size empty array)
        signal_ = []
        
        % Variance array
        % An array same size as signal array (all elements >=0 or NaN)
        % If all variances are zero, then = [] (to save memory)
        variance_ = []
        
        % Mask array
        % Logical array same size as signal array (0 = mask, 1 = retain)
        % If all elements are retained then = [] (to save memory)
        mask_ = []
        
    end
    
    properties (Dependent)
        s       % Signal array (numeric array)
        e       % Variance array (numeric array, same size as signal array)
        msk     % Mask array (logical array, same size as signal array, 0=mask, 1=retain)
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = sigvar (varargin)
            % Create sigvar object
            %
            %   >> w = sigvar           % Empty object
            %   >> w = sigvar(s)        % Signal but no variance
            %   >> w = sigvar(s,e)      % Signal and variance
            %   >> w = sigvar(s,e,msk)  % Signal and variance
            %
            % Input:
            % ------
            %   s       Signal (numeric array)
            %
            % Optional arguments:
            %   e       Variance array (same size as signal array)
            %           All elements must be greater or equal to zero
            %           If an empty array, then variances are assumed to all be zero
            %           If scalar (and signal non-empty) then all elements assumed to be same
            %
            %   msk     Mask array (logical array same size as signal array)
            %           Elements are 0 (mask) or 1 (keep)
            %           If an empty array, then assumed all points are retained
            %           If scalar (and signal non-empty) then all elements assumed to be same
            
            narg = numel(varargin);
            if narg>=1
                if numel(varargin)==1 && isa(varargin{1},'sigvar')
                    % Need to catch the case of input being a sigvar object for
                    % generic binary and unary operations to work (they require
                    % that a sigvar object be returned from an instance of the
                    % class; in this case that a sigvar object be returned from
                    % a signvar object - a dummy operation)
                    obj = varargin{1};
                elseif numel(varargin)==1 && isstruct(varargin{1})
                    structsize = length(fieldnames(varargin{1}));
                    if structsize>3
                        error("HORACE:sigvar:invalid argument", "Structure too large");                        
                    end
                    fnames = fieldnames(varargin{1});
                    if structsize>=1
                        if strcmp( fnames{1}, 's' )
                            obj.s = varargin{1}.s;
                        else
                            error("HORACE:sigvar:invalid argument", "Structure 's' field not present");
                        end
                    else
                        obj.s = [];
                    end
                    if structsize>=2 
                        if strcmp( fnames{2}, 'e' )
                            obj.e = varargin{1}.e;
                        else
                            error("HORACE:sigvar:structure w field not present");
                        end
                    else
                        obj.e = [];
                    end
                    if structsize>=3 
                        if strcmp( fnames{3}, 'msk' )
                            obj.e = varargin{1}.msk;
                        else
                            error("HORACE:sigvar:structure msk field not present");
                        end
                    else
                        obj.msk = [];
                    end
                else
                    s = varargin{1};
                    if narg>=2, e = varargin{2}; else, e = []; end
                    if narg>=3, msk = varargin{3}; else, msk = []; end
                    if narg>3
                        mess = 'Too many input arguments';
                        ME = MException('sigvar:invalid_argument',mess);
                        throw(ME)
                    end
                    [obj.signal_, obj.variance_, obj.mask_] = check_valid_input (s, e, msk);
                end
            end
            
        end
        
        %------------------------------------------------------------------
        % Set methods for dependent properties
        
        function obj=set.s(obj,val)
            [obj.signal_, obj.variance_, obj.mask_] = check_valid_input...
                (val, obj.variance_, obj.mask_);
        end
        
        function obj=set.e(obj,val)
            [obj.signal_, obj.variance_, obj.mask_] = check_valid_input...
                (obj.signal_, val, obj.mask_);
        end
        
        
        function obj=set.msk(obj,val)
            [obj.signal_, obj.variance_, obj.mask_] = check_valid_input...
                (obj.signal_, obj.variance_, val);
        end
        
        %------------------------------------------------------------------
        % Get methods for dependent properties
        
        function val=get.s(obj)
            % Return signal array
            val=obj.signal_;
        end
        
        function val=get.e(obj)
            % Return variance array, expanding [] as required
            sz_var = size(obj.variance_);
            if numel(sz_var)==2 && all(sz_var==0)   % i.e. variance_ == []
                val = zeros(size(obj.signal_));
            else
                val = obj.variance_;
            end
        end
        
        function val=get.msk(obj)
            % Return mask array, expanding [] as required
            sz_msk = size(obj.mask_);
            if numel(sz_msk)==2 && all(sz_msk==0)   % i.e. mask_ == []
                val = true(size(obj.signal_));
            else
                val = obj.mask_;
            end
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

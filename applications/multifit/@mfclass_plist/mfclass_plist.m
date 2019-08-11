classdef mfclass_plist
    % Parameter list for multifit
    %
    % A valid parameter list is one of the following:
    % - Base parameter list:
    %   - A numeric vector (row or column) or empty numeric, p
    %       e.g.    p = [10,100,0.01]
    %               p = []
    %
    %   - A cell array (row) of parameters, the first of which is a numeric
    %     vector (row or column) or empty numeric, of form {p, c1, c2, ...}
    %       e.g.    {[10,13]}               % same as [10,13]
    %               {[10,13], true, '-mev'}
    %               {[], 'average'}
    %
    %
    %   - The case of absent numeric parameters: a non-numeric argument or
    %    a cell array (row) without a leading numeric vector.
    %       e.g.    'average'
    %               {'average'}             % same as 'average'
    %               {true, '-mev'}
    %               {}                      % no parameters and no additional arguments
    %
    %   Note:
    %    (1) A numeric argument is only considered to be a numeric parameter
    %       list if it is a vector (row or column) or empty.For example, a 3x3
    %       matrix will be simplty treated as a constant argument
    %    (2) The case of absent numeric parameters and c1<0> being a numeric
    %       parameter list is not possible - it cannot be distinguished from
    %       the case of {p, c2<0>,...}
    %
    %
    % - A recursive nesting of functions and parameter lists:
    %       p<n> = {@func<n-1>, plist<n-1>, c1<n>, c2<n>,...}
    %            :
    %       p<1> = {@func<0>, p<0>, c1<1>, c2<1>,...}
    %       p<0> =  base parameter list i.e.
    %                p
    %               {p, c1<0>, c2<0>,...}
    %                c1<0>
    %               {c1<0>, c2<0>,...}
    %               {}
    %
    %   Note:
    %    (1) The way to tell that plist is nested is that it is a row cell
    %       array with at least two elements, the first of which is a function handle.
    %       Anything else must be the base parameter list.
    %
    %
    % The recursive form for the parameter list allows nesting of function calls.
    % If a function and a parameter list are given, func<n> and p<n>, then the
    % recursive call that is assumed is:
    %           wout =   func<n> (w, func<n-1>, p<n-1>, c1<n>, c2<n>, ...)
    %          [...] = func<n-1> (..., func<n-2>, p<n-2>, c1<n-1>, c2<n-1>, ...)
    %               :
    %          [...] =   func<1> (..., func<0>, p<0>, c1<1>, c2<1>, ...)
    %          [...] =   func<0> (..., p, c1<0>, c2<0>, ...)
    
    
    % For assistance when debugging/writing functions, the full set of possible
    % base parameter lists is:
    %    p                      % numeric vector or []
    %   {p, c1<0>, c2<0>,...}   % p as above, cn<0> any argument
    %    c1<0>                  % any argument except numeric vector or []
    %   {c1<0>, c2<0>,...}      % c1<0> not a numeric vector or [p]; cn<0> any argument
    %   {}                      % no numeric parameters or arguments
    
    properties (Hidden)
        % Parameter list
        plist_ = {};
        % Logical indicating if numeric parameter list is present or not
        p_present_ = false;
        % Numeric parameter list
        p_ = [];
    end
    
    properties (Dependent)
        % Parameter list
        plist
        % Logical indicating if numeric parameter list is present or not
        p_present = false;
        % Numeric parameter list
        p = [];
        % Number of elements in numeric parameter list
        np
    end
    
    methods
        %------------------------------------------------------------------
        % Constructor
        %------------------------------------------------------------------
        function obj = mfclass_plist(var)
            if nargin==1
                obj.plist_ = var;
                [obj.p_present_, obj.p_] = p_get (var);
            end
        end
        
        %------------------------------------------------------------------
        % Set/get methods: dependent properties
        %------------------------------------------------------------------
        % Get methods for dependent properties
        function out = get.plist (obj)
            out = obj.plist_;
        end
        
        function out = get.p_present (obj)
            out = obj.p_present_;
        end
        
        function out = get.p (obj)
            out = obj.p_;
        end
        
        function out = get.np (obj)
            out = numel(obj.p_);
        end
        
        % Set methods for dependent properties
        function obj = set.p (obj,pnew)
            if isnumeric(pnew) && (isempty(pnew) || isavector(pnew))
                obj.plist_ = p_set (obj.plist_, obj.p_present_, pnew);
                obj.p_present_ = true;
                obj.p_ = pnew;
            else
                error('Check new numeric parameters have the correct type')
            end
        end
        
        %------------------------------------------------------------------
        % Other methods
        %------------------------------------------------------------------
        function objnew = wrap (obj, func, pwrap)
            % Wraps a parameter list within another parameter list
            %
            %   >> plistnew = plist.wrap (func, pwrap)
            %
            % This results in the new parameter list created by replacing the
            % numeric parameter list in pwrap by
            %   {func, plist}
            %
            % Input:
            % ------
            %   func    Function handle
            %   pwrap   Valid parameter list
            
            if isa(func,'function_handle')
                objnew = obj;
                if nargin==2
                    tmp = mfclass_plist();      % empty pwrap
                elseif ~(isa(pwrap,'mfclass_plist') && isscalar(pwrap))
                    tmp = mfclass_plist(pwrap); % make pwrap an object
                else
                    tmp = pwrap;
                end
                objnew.plist_ = wrap (tmp.plist_, tmp.p_present, func, obj.plist_);
            else
                error('Check the input arguments')
            end
        end
        
        function objnew = append_args (obj, varargin)
            % Appends arguments to the top level parameter list
            %
            %   >> objnew = obj.append_args (d1, d2, ...)
            %
            % Converts the parameter list {p, c1, c2,..} into {p, c1, c2,..., d1, d2,...}
            % Note that if the numeric parameter list p and c1, c2,... are missing, then if
            % d1 is a numeric vector (or []) it will be taken to be a numeric parameter list.
            
            if numel(varargin)>0
                objnew = mfclass_plist();
                [objnew.plist_, objnew.p_present_, objnew.p_] = ...
                    append_args (obj.plist_, obj.p_present_, obj.p_, varargin{:});
            else
                objnew = obj;   % no change
            end
        end
        
        function objnew = prepend_args (obj, varargin)
            % Prepends arguments to the top level parameter list
            %
            %   >> objnew = obj.prepend_args (d1, d2, ...)
            %
            % Converts the parameter list {p, c1, c2,..} into {p, d1, d2,..., c1, c2,...}
            % Note that if the numeric parameter list p is missing, then if d1 is a numeric
            % vector (or []) then d1 will be taken to be a numeric parameter list.
            
            if numel(varargin)>0
                objnew = mfclass_plist();
                [objnew.plist_, objnew.p_present_, objnew.p_] = ...
                    prepend_args (obj.plist_, obj.p_present_, obj.p_, varargin{:});
            else
                objnew = obj;   % no change
            end
        end
        
        function varargout = unpack (obj)
            % Breaks down a parameter list into successive levels of recursion
            %
            %   >> C = obj.unpack
            %   >> obj.unpack       % display unpacking in command window
            %
            % Here C{1} is the top level, c{2} the next...c{end} the base parameter list
            
            C = unpack ({}, obj.plist_);
            
            if nargout>0
                varargout{1} = C;
            else
                % List to terminal
                for i=1:numel(C)
                    display(C{i})
                end
            end
            
        end
    end
    
end

%--------------------------------------------------------------------------------------------------
function plistnew = p_set (plist, p_present, varargin)
% Set the numeric parameter array in the base parameter list.
%
%   >> plistnew = p_set (plist, p_present)          % New parameter vector is the absence of a list
%   >> plistnew = p_set (plist, p_present, pnew)    % New parameter vector
%
% It is assumed that the parameter list is a row or column vector or [], and numel(varargin)= 0 or 1


if iscell(plist) && isrowvector(plist) && numel(plist)>=2 && isa(plist{1},'function_handle')
    % Nested parameter list
    plistnew = {plist{1}, p_set(plist{2},p_present,varargin{:}), plist{3:end}};
else
    % Base parameter list
    pnew_present = (numel(varargin)>0);
    if iscell(plist) && isrowvector(plist) && numel(plist)>=1   % plist has form {p, c1<0>, c2<0>,...} or {c1<0>, c2<0>,...}
        if p_present
            if pnew_present
                if numel(plist)>1
                    plistnew = [varargin,plist(2:end)];
                else
                    plistnew = varargin{1};
                end
            else
                if numel(plist)>2
                    plistnew = plist(2:end);
                elseif numel(plist)==1
                    plistnew = plist{2};
                else
                    plistnew = {};
                end
            end
        else
            if pnew_present
                plistnew = [varargin,plist];
            else
                plistnew = plist;   % unchanged
            end
        end
        
    elseif isnumeric(plist) && p_present    % plist is numeric parameter list (cf e.g. a matrix)
        if pnew_present
            plistnew = varargin{1};
        else
            plistnew = {};
        end
        
    elseif iscell(plist) && isempty(plist)  % plist is {} (or cell(1,0) or cell(0,1))
        if pnew_present
            plistnew = varargin{1};
        else
            plistnew = plist;   % unchanged
        end
        
    else                                    % plist is c1<0>
        if pnew_present
            plistnew = [varargin,{plist}];
        else
            plistnew = plist;   % unchanged
        end
    end
end

end

%--------------------------------------------------------------------------------------------------
function [p_present, p] = p_get(plist)
% Get the parameters at the base of a parameter list.
%
%   >> [p_present, p] = p_get(plist)

if iscell(plist) && isrowvector(plist) && numel(plist)>=2 && isa(plist{1},'function_handle')
    % Nested parameter list
    [p_present,p] = p_get (plist{2});
else
    % Base parameter list
    numeric_pars = @(x) isnumeric(x) && (isempty(x) || isavector(x));
    if iscell(plist) && isrowvector(plist) && numel(plist)>=1 && numeric_pars(plist{1})
        p_present = true;
        p = plist{1};
    elseif numeric_pars(plist)
        p_present = true;
        p = plist;
    else
        p_present = false;
        p = [];
    end
end

end

%--------------------------------------------------------------------------------------------------
function plistnew = wrap (pwrap, p_present, func, plist)
% Wrap a parameter list within another parameter list.
%
%   >> plistnew = wrap (pwrap, p_present, func, plist)

if iscell(pwrap) && isrowvector(pwrap) && numel(pwrap)>=2 && isa(pwrap{1},'function_handle')
    % Nested parameter list
    plistnew = {pwrap{1}, wrap(pwrap{2},p_present,func,plist), pwrap{3:end}};
else
    % Base parameter list
    if iscell(pwrap) && isrowvector(pwrap) && numel(pwrap)>=1
        if p_present                        % pwrap has form {p, c1<0>, c2<0>,...}
            plistnew = [{func,plist},pwrap(2:end)];
        else                                % pwrap has form {c1<0>, c2<0>,...}
            plistnew = [{func,plist},pwrap];
        end
        
    elseif isnumeric(pwrap) && p_present    % pwrap is numeric parameter list (cf e.g. a matrix)
        plistnew = {func,plist};
        
    elseif iscell(pwrap) && isempty(pwrap)  % pwrap is {} (or cell(1,0) or cell(0,1))
        plistnew = {func,plist};
        
    else                                    % pwrap is c1<0>
        plistnew = [{func,plist},{pwrap}];
    end
end

end

%--------------------------------------------------------------------------------------------------
function [plistnew, pnew_present, pnew] = append_args (plist, p_present, p, varargin)
% Append arguments to the top level parameter list.
%
%   >> [plistnew, pnew_present, pnew] = append_args (plist, p_present, p)
%   >> [plistnew, pnew_present, pnew] = append_args (plist, p_present, p, d1, d2,...)

% In most cases the numeric parameter list will not be changed, so return default
pnew_present = p_present;
pnew = p;

% Now append
if iscell(plist) && isrowvector(plist) && numel(plist)>=2 && isa(plist{1},'function_handle')
    % Nested parameter list
    plistnew = [plist,varargin];                % works if varargin is empty, as plist is not empty
else
    % Base parameter list
    if numel(varargin)>0
        if iscell(plist) && isrowvector(plist) && numel(plist)>=1   % plist has form {p, c1<0>, c2<0>,...} or {c1<0>, c2<0>,...}
            plistnew = [plist,varargin];        % at least one element in plist, so just append
            
        elseif isnumeric(plist) && p_present    % plist is numeric parameter list (cf e.g. a matrix)
            plistnew = [{plist},varargin];
            
        elseif iscell(plist) && isempty(plist)  % plist is {} (or cell(1,0) or cell(0,1))
            if numel(varargin)>1
                plistnew = varargin;
            else
                plistnew = varargin{1};
            end
            % It may be that we now have a numeric parameter list
            if isnumeric(varargin{1}) && (isempty(varargin{1}) || isavector(varargin{1}))
                pnew_present = true;
                pnew = varargin{1};
            end
            
        else                                    % plist is c1<0>
            plistnew = [{plist},varargin];
        end
    else
        plistnew = plist;               % unchanged
    end
end

end

%--------------------------------------------------------------------------------------------------
function [plistnew, pnew_present, pnew] = prepend_args (plist, p_present, p, varargin)
% Prepend arguments to the top level parameter list.
%
%   >> [plistnew, pnew_present, pnew] = prepend_args (plist, p_present, p)
%   >> [plistnew, pnew_present, pnew] = prepend_args (plist, p_present, p, d1, d2,...)

% In most cases the numeric parameter list will not be changed, so return default
pnew_present = p_present;
pnew = p;

% Now prepend
if iscell(plist) && isrowvector(plist) && numel(plist)>=2 && isa(plist{1},'function_handle')
    % Nested parameter list
    plistnew = [plist(1:2),varargin,plist(3:end)];  % works if varargin is empty, as plist is not empty
else
    % Base parameter list
    if numel(varargin)>0
        if iscell(plist) && isrowvector(plist) && numel(plist)>=1
            if p_present                        % plist has form {p, c1<0>, c2<0>,...}
                plistnew = [plist(1),varargin,plist(2:end)];
            else                                % plist has form {c1<0>, c2<0>,...}
                plistnew = [varargin,plist];
                % It may be that we now have a numeric parameter list
                if isnumeric(varargin{1}) && (isempty(varargin{1}) || isavector(varargin{1}))
                    pnew_present = true;
                    pnew = varargin{1};
                end
            end
            
        elseif isnumeric(plist) && p_present    % plist is numeric parameter list (cf e.g. a matrix)
            plistnew = [{plist},varargin];
            
        elseif iscell(plist) && isempty(plist)  % plist is {} (or cell(1,0) or cell(0,1))
            if numel(varargin)>1
                plistnew = varargin;
            else
                plistnew = varargin{1};
            end
            % It may be that we now have a numeric parameter list
            if isnumeric(varargin{1}) && (isempty(varargin{1}) || isavector(varargin{1}))
                pnew_present = true;
                pnew = varargin{1};
            end
            
        else                                    % plist is c1<0>
            plistnew = [varargin,{plist}];
            % It may be that we now have a numeric parameter list
            if isnumeric(varargin{1}) && (isempty(varargin{1}) || isavector(varargin{1}))
                pnew_present = true;
                pnew = varargin{1};
            end
        end
    else
        plistnew = plist;                       % unchanged
    end
end

end

%--------------------------------------------------------------------------------------------------
function C = unpack (Cin, plist)
% Break down a parameter list into successive levels of recursion
%
%   >> C = obj.unpack
%
% Here C{1} is the top level, c{2} the next...c{end} the base parameter list


if iscell(plist) && isrowvector(plist) && numel(plist)>=2 && isa(plist{1},'function_handle')
    % Nested parameter list
    C = unpack ([Cin; {[plist(1),{mfclass_plist()},plist(3:end)]}], plist{2});
else
    % Base parameter list
    C = [Cin; {plist}];
end

end

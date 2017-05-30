function [ok,mess]=equal_to_tol(a,b,varargin)
% Check that all elements of a pair objects are equal, with numeric arrays within a specified tolerance
%
%   >> ok=equal_to_tol(a,b)
%   >> ok=equal_to_tol(a,b,tol)
%   >> ok=equal_to_tol(...,keyword1,val1,keyword2,val2,...)
%   >> [ok,mess]=equal_to_tol(...)
%
% Any cell arrays, structures or objects are recursively explored.
%
% Input:
% ------
%   a,b     test objects (scalar objects, or arrays of objects with same sizes)
%   tol     tolerance (default: equality required)
%               +ve number: absolute tolerance  abserr = abs(a-b)
%               -ve number: relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%
% Valid keywords are:
%  'nan_equal'       Treat NaNs as equal (true or false; default=true)
%  'min_denominator' Minimum denominator for relative tolerance calculation (>=0; default=0)
%                   When the denominator in a relative tolerance is less than this value, the
%                   denominator is replaced by this value. Use this when the numbers being
%                   compared could be close to zero.
%  'ignore_str'      Ignore the length and content of strings or cell arrays of strings
%                   (true or false; default=false)
%
% Output:
% -------
%   ok      true if every element satisfies tolerance criterion
%   mess    error message if ~ok ('' if ok)


opt=struct('nan_equal',true,...
    'min_denominator',0,...
    'ignore_str',false);
warn = warning('off','MATLAB:structOnObject');
cl1 = onCleanup(@()warning(warn));

if nargin==2
    opt.tol=0;    % default is to force equality of numeric elements
elseif nargin==3 && isnumeric(varargin{1})
    opt.tol=varargin{1};
elseif nargin>=3
    [par,opt,present,filled,ok,mess]=parse_arguments(varargin,opt);
    if ~ok, error(mess), end
    if numel(par)==0
        opt.tol=0;
    elseif numel(par)==1
        opt.tol=par{1};
    else
        error('Check input arguments')
    end
    if ~islognumscalar(opt.nan_equal), error('Check value of ''nan_equal'''), end
    if ~isscalar(opt.min_denominator) || opt.min_denominator<0, error('Check value of ''min_denominator'''), end
    if ~islognumscalar(opt.ignore_str), error('Check value of ''ignore_str'''), end
end

[ok,mess]=equal_to_tol_internal(a,b,opt,'initial obj');

%--------------------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_internal(a,b,opt,obj_name)

% Consider special case of strings if they are to be ignored
if opt.ignore_str && (iscellstr(a)||ischar(a)) && (iscellstr(b)||ischar(b))
    ok=true;
    mess='';
    return
end

if (isobject(a) && isobject(b)) || (isstruct(a) && isstruct(b))
    if ~isequal(size(a),size(b))
        ok=false;
        mess=sprinft('Sizes of %s arrays of objects or structures being compared are not equal',...
            obj_name);
        return
    end
    name=fieldnames(a);
    if ~isequal(name,fieldnames(b))
        ok=false;
        mess=@(a,b)sprintf('Field names of %s obj or struct do not match: a=%s, b=%s',...
            obj_name,a,b);
        cellfun(mess,name,fieldnames(b),'UniformOutput',false)
        return
    end
    for i=1:numel(a)
        for j=1:numel(name)
            if isobject(a)
                [ok,mess]=equal_to_tol_internal(struct(a(i)).(name{j}),struct(b(i)).(name{j}),opt,name{j});
            else
                [ok,mess]=equal_to_tol_internal(a(i).(name{j}),b(i).(name{j}),opt,name{j});
            end
            if ~ok
                return
            end
        end
    end
    
elseif iscell(a) && iscell(b)
    if ~isequal(size(a),size(b))
        ok=false;
        mess=sprintf('Sizes of %s cell arrays being compared are not equal',...
            obj_name);
        return
    end
    for i=1:numel(a)
        [ok,mess]=equal_to_tol_internal(a{i},b{i},opt,obj_name);
        if ~ok, return, end
    end
    
elseif isnumeric(a) && isnumeric(b)
    [ok,mess]=equal_to_tol_numeric(a,b,opt.tol,opt.nan_equal,opt.min_denominator,obj_name);
    if ~ok
        return;
    end
    
else
    if strcmp(class(a),class(b))
        if ~isequal(size(a),size(b))
            ok=false;
            mess=sprintf('Sizes of %s array of objects being compared are not equal',...
                obj_name);
            return
        end
        if ~isequal(a,b)
            ok=false;
            mess='Non-numeric fields not equal';
            return
        end
    else
        ok=false;
        mess=spfintf('Fields for %s have different classes: a=%s b=%s',...
            obj_name,class(a),class(b));
        return
    end
end
ok=true; mess='';


%--------------------------------------------------------------------------------------------------
function [ok,mess]=equal_to_tol_numeric(a,b,tol,nan_equal,min_denominator,obj_name)
if isequal(size(a),size(b))
    % If NaNs are to be ignored, remove them from consideration
    if nan_equal
        keep=~isnan(a);
        if ~all(keep(:)==~isnan(b(:)))    % check NaNs have the same locations in both arrays
            ok=false;
            mess='NaN elements not in same locations in numeric arrays being compared';
            return
        elseif ~any(keep(:))   % if all elements are Nans, can simply return
            ok=true;
            mess='';
            return
        elseif ~all(keep(:))   % filter out elements if some to be ignored
            a=a(keep);
            b=b(keep);
        end
    end
    a=a(:);
    b=b(:);
    infs_mark=isinf(a);
    if any(infs_mark) % inf are present in the arrays
        infs2_mark=isinf(b);
        if any(infs_mark ~= infs2_mark)
            ok=false;
            mess=sprintf('Inf elements for %s not in same locations in numeric arrays being compared',...
                obj_name);
            return;
        end
        infss_a=sign(a(infs_mark));
        infss_b=sign(b(infs_mark));
        if any(infss_a ~= infss_b)
            mess=sprintf('Inf elements for %s have different signs in numeric arrays being compared',...
                obj_name);
            return;
        end
        a=a(~infs_mark);
        b=b(~infs_mark);
    end
    
    % Compare elements. Remove case of empty arrays - these are considered equal
    if ~isempty(a)
        if tol==0
            okk=a==b;
            ok=all(okk);
            errf = @(nok)a(nok);
        elseif tol>0
            okk = (abs(a-b)<=tol);
            ok=all(okk);
            errf = @(nok)abs(a(nok)-b(nok));
        else
            if min_denominator>0
                den=max(max(abs(a),abs(b)),min_denominator*ones(size(a)));
            else
                den=max(abs(a),abs(b));
            end
            okk = (abs(a-b)./den<=abs(tol))|den==0|isinf(den);
            ok=all(okk);   % if both are zero, then accept, or if either a or b in infinite
            errf=@(nok)(abs(a(nok)-b(nok))./den(nok));
        end
        if ok
            ok=true;    % stupid matlab feature: all(A) if A is a matrix results in a row vector! behaves as all(A(:)) in an if statement however.
            mess='';
        else
            ok=false;
            anok = a(~okk);
            [maxErr,ind]=max(errf(~okk));
            mess=sprintf('Numeric arrays ~= within tol requested; max err: %f for value %s=%f at pos: %d',...
                maxErr,obj_name,anok(ind),ind);
        end
    else
        ok=true;
        mess='';
    end
else
    ok=false;
    mess=sprintf('Numeric arrays for %s have different sizes',obj_name);
end

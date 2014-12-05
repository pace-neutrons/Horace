function [ok,mess]=logical_operator(v1,v2,type)
% Apply logical relational operator to two appversion objects
%
%   >> ok=logical_operator(v1,v2,func_type)
%
%   v1, v2  appversion objects (or arrays of objects)
%   type    logical comparison: 'gt' or 'eq'

% Check type comparison
if strcmp(type,'gt')
    opt_gt=true;
else
    opt_gt=false;
end

% If either object is empty array, return ok as empty (to match behaviour
% of numeric array comparisons)
if isempty(v1)||isempty(v2)
    ok=[];
    mess='';
    return
end

% Neither is empty, so check sizes are compatible
sz1=size(v1);
sz2=size(v2);
scalar1=isscalar(v1);
scalar2=isscalar(v2);
if ~(scalar1 || scalar2 || (numel(sz1)==numel(sz2) && all(sz1==sz2)))
    ok=false;
    mess='The array sizes of the appversions to be compared do not match';
    return
end

% Perform comparison
mess='';
if scalar1 && scalar2
    if opt_gt
        ok=gt_arr(arr(v1),arr(v2));
    else
        ok=eq_arr(arr(v1),arr(v2));
    end
elseif scalar1 && ~scalar2
    ok=false(sz2);
    a1=arr(v1);
    for i=1:numel(v2)
        if opt_gt
            ok(i)=gt_arr(a1,arr(v2(i)));
        else
            ok(i)=eq_arr(a1,arr(v2(i)));
        end
    end
elseif ~scalar1 && scalar2
    ok=false(sz1);
    a2=arr(v2);
    for i=1:numel(v1)
        if opt_gt
            ok(i)=gt_arr(arr(v1(i)),a2);
        else
            ok(i)=eq_arr(arr(v1(i)),a2);
        end
    end
else
    ok=false(sz1);
    for i=1:numel(v1)
        if opt_gt
            ok(i)=gt_arr(arr(v1(i)),arr(v2(i)));
        else
            ok(i)=eq_arr(arr(v1(i)),arr(v2(i)));
        end
    end
end

%--------------------------------------------------------------------------
function a=arr(v)
% Get array of version componenets, dropping trailing zeros
a=v.version;
a=a(1:find(a>0,1,'last'));
if isempty(a), a=0; end

%--------------------------------------------------------------------------
function ok=gt_arr(a1,a2)
% Determine if first array is 'gt' than second in left-to-right priority sense
n=min(numel(a1),numel(a2));
ind=find(a1(1:n)-a2(1:n)~=0,1,'first');
if (~isempty(ind) && a1(ind)>a2(ind)) || (isempty(ind) && numel(a1)>n)
    ok=true;
else
    ok=false;
end

%--------------------------------------------------------------------------
function ok=eq_arr(a1,a2)
% Determine if two arrays are equal
if numel(a1)==numel(a2) && all(a1==a2)
    ok=true;
else
    ok=false;
end

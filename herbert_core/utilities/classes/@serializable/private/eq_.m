function [is,mess] = eq_(obj,other_obj,varargin)
% Check equality of two serializable objects
%
is_tol = cellfun(@(x)((ischar(x)||isstring(x))&&ismember(x,{'tol','abstol','reltol'})), ...
    varargin);
if any(is_tol)
    argi = varargin;
else % default tol for comparing serializable objects 1e-9
    argi = ['tol';[1.e-9,1.e-9];varargin(:)];
end

if numel(obj) ~= numel(other_obj)
    is = false;
    if nargout>1
        mess = sprintf('number of elements in %s (%d) is not equal to number of elements in %s (%d)',...
            name1,numel(obj),name2,numel(other_obj));
    end
    return;
end
if any(size(obj) ~= size(other_obj))
    is = false;
    if nargout>1
        mess = sprintf('Shape of %s is not equal to shape of %s', ...
            name1,name2);
    end
    return
end

is = false(size(obj));
if nargout == 2
    mess = cell(size(obj));
end
for i=1:numel(obj)
    if nargout == 2
        [is(i),mess{i}] = eq_single(obj(i),other_obj(i),argi{:});
    else
        is(i) = eq_single(obj(i),other_obj(i),argi{:});
    end
end
if nargout == 2
    if any(~is)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end

function [iseq,mess] = eq_single(obj1,obj2,varargin)

flds = obj1.saveableFields;

for i=1:numel(flds)
    val1 = obj1.(flds{i});
    [iseq,mess] = equal_to_tol(val1,obj2.(flds{i}),varargin{:});
    if ~iseq
        return;
    end
end


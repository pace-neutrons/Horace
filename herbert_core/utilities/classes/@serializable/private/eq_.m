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
[name_a,name_b,argi] = check_and_extract_name(inputname(1),inputname(2),argi{:});
if nargout>1
    if numel(obj)>1
        namer = @(x,i)sprintf('%s(%d)',x,i);
    else
        namer = @(x,i)sprintf('%s',x);
    end
end

for i=1:numel(obj)
    if nargout == 2
        name_1 = namer(name_a,i);
        name_2 = namer(name_b,i);
        [is(i),mess{i}] = eq_single(obj(i),other_obj(i), ...
            'name_a',name_1,'name_b',name_2,argi{:});
    else
        is(i) = eq_single(obj(i),other_obj(i), ...
            'name_a',name_a,'name_b',name_b,argi{:});
    end
end
if nargout == 2
    if any(~is)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end

function [iseq,mess] = eq_single(obj1,obj2,name_a,name_a_val,name_b,name_b_val,varargin)
% compare single pair of serializeble objects
%
flds = obj1.saveableFields;

for i=1:numel(flds)
    val1 = obj1.(flds{i});
    name_a_val_f = [name_a_val,'.',flds{i}];
    name_b_val_f = [name_b_val,'.',flds{i}];
    [iseq,mess] = equal_to_tol(val1,obj2.(flds{i}), ...
        name_a,name_a_val_f,name_b,name_b_val_f,varargin{:});
    if ~iseq
        return;
    end
end

function [name_a,name_b,argi] = check_and_extract_name(input_name1,input_name2,varargin)
name_a_default = 'lhs_obj';
name_b_default = 'rhs_obj';
name_a = input_name1;
name_b = input_name2;
if isempty(input_name1)
    name_a = name_a_default;
end
if isempty(input_name2)
    name_b = name_b_default;
end
% check if input name was provided (as part of equal_to_tol operation
is_name = cellfun(@(x)((ischar(x)||isstring(x))&&(strcmp(x,'name_a')||strcmp(x,'name_b'))),...
    varargin);
if any(is_name)
    name_pos = find(is_name);
    name_val = name_pos +1;
    is_name(name_val) = 1;
    argi = varargin(~is_name);
    for i=1:numel(name_pos)
        if strcmp(varargin{name_pos(i)},'name_a')
            name_a = varargin{name_val(i)};
        else
            name_b = varargin{name_val(i)};
        end
    end
else
    argi = varargin;
end

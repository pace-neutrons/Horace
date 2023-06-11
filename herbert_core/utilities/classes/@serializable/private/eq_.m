function [iseq, mess] = eq_ (obj1, obj2, varargin)
% Check equality of two serializable objects

is_tol = cellfun(@(x)((ischar(x)||isstring(x))&&ismember(x,{'tol','abstol','reltol'})), ...
    varargin);
if any(is_tol)
    argi = varargin;
else % default tol for comparing serializable objects 1e-9
    argi = ['tol';[1.e-9,1.e-9];varargin(:)];
end

if numel(obj1) ~= numel(obj2)
    iseq = false;
    if nargout>1
        [name1,name2] = check_and_extract_name(inputname(1),inputname(2),argi{:});            
        mess = sprintf('number of elements in %s (%d) is not equal to number of elements in %s (%d)',...
            name1,numel(obj1),name2,numel(obj2));
    end
    return;
end
if any(size(obj1) ~= size(obj2))
    iseq = false;
    if nargout>1
        [name1,name2] = check_and_extract_name(inputname(1),inputname(2),argi{:});                    
        mess = sprintf('Shape of %s is not equal to shape of %s', ...
            name1,name2);
    end
    return
end

iseq = false(size(obj1));
if nargout == 2
    mess = cell(size(obj1));
end
[name_a,name_b,argi] = check_and_extract_name(inputname(1),inputname(2),argi{:});
if nargout>1
    if numel(obj1)>1
        namer = @(x,i)sprintf('%s(%d)',x,i);
    else
        namer = @(x,i)sprintf('%s',x);
    end
end

for i=1:numel(obj1)
    if nargout == 2
        name_1 = namer(name_a,i);
        name_2 = namer(name_b,i);
        [iseq(i),mess{i}] = eq_single(obj1(i),obj2(i), ...
            'name_a',name_1,'name_b',name_2,argi{:});
    else
        iseq(i) = eq_single(obj1(i),obj2(i), ...
            'name_a',name_a,'name_b',name_b,argi{:});
    end
end
if nargout == 2
    if any(~iseq)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end


%-------------------------------------------------------------------------------
function [iseq, mess] = eq_single (obj1, obj2, name_a, name_a_val, ...
    name_b, name_b_val, varargin)
% Compare single pair of serializeble objects

struc1 = obj1.to_bare_struct();
struc2 = obj2.to_bare_struct();
[iseq, mess] = equal_to_tol (struc1, struc2, ...
        name_a, name_a_val, name_b, name_b_val, varargin{:});


%-------------------------------------------------------------------------------
function [name_a, name_b, argi] = check_and_extract_name ...
    (input_name1, input_name2, varargin)
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

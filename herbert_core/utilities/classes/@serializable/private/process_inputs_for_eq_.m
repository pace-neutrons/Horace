function [is, mess, name_a, name_b, namer, argi] = process_inputs_for_eq_ (...
    lhs_obj, rhs_obj, narg_out, names, varargin)
% Check equality of two serializable objects

mess = '';
is_tol = cellfun(@(x)((ischar(x)||isstring(x))&&ismember(x,{'tol','abstol','reltol'})), ...
    varargin);
if any(is_tol)
    argi = varargin;
else % default tol for comparing serializable objects 1e-9
    argi = ['tol';[1.e-9,1.e-9];varargin(:)];
end

if numel(lhs_obj) ~= numel(rhs_obj)
    is = false;
    if nargout>1
        [name_a,name_b] = check_and_extract_name(names{1},names{2},argi{:});
        mess = sprintf('number of elements in %s (%d) is not equal to number of elements in %s (%d)',...
            name_a,numel(lhs_obj),name_b,numel(rhs_obj));
    end
elseif any(size(lhs_obj) ~= size(rhs_obj))
    is = false;
    if nargout>1
        [name_a,name_b] = check_and_extract_name(names{1},names{2},argi{:});
        mess = sprintf('Shape of %s is not equal to shape of %s', ...
            name_a,name_b);
    end
else
    is = true;
    if narg_out == 2
        mess = cell(size(lhs_obj));
    end
    [name_a,name_b,argi] = check_and_extract_name(names{1},names{2},argi{:});
end

if nargout>1
    if numel(lhs_obj)>1
        namer = @(x,i)sprintf('%s(%d)',x,i);
    else
        namer = @(x,i)sprintf('%s',x);
    end
end

end

%-------------------------------------------------------------------------------
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

end

function [iseq, mess] = equal_to_tol(obj1, obj2, varargin)
% Return a logical variable stating if two serializable objects are equal or not
%
%   >> [iseq, mess] = equal_to_tol(obj1, obj2)
%   >> [iseq, mess] = equal_to_tol(obj1, obj2, p1, p2, ...)
%
% Input:
% ------
%   obj1        Object on left-hand side
%
%   obj2        Object on right-hand side
%
% Optional:
%   p1, p2,...  Any set of parameters that the equal_to_tol function accepts
%
[is,mess] = is_type_and_shape_equal(obj1,obj2);
if ~is
    is_recursive = cellfun(@(x)(isstruct(x)&&isfield(x,'recursive_call')),varargin);
    if any(is_recursive)
        opt = varargin{is_recursive};
        mess = sprintf(['Object %s and %s are different\n' ...
            'Reason: %s'], ...
            opt.name_a,opt.name_b,mess);
    end
    return;
end

% Get names of input variables, if can
name_a = variable_name(inputname(1), false, size(obj1), 1, 'input_1');
name_b = variable_name(inputname(2), false, size(obj2), 1, 'input_2');

opt = parse_equal_to_tol_inputs(name_a,name_b,varargin{:});

[iseq, mess] = equal_to_tol_(obj1, obj2, opt);


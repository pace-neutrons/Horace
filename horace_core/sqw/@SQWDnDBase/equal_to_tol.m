function [ok, mess] = equal_to_tol(w1, w2, varargin)
% Check if two sqw objects are equal to a given tolerance
%
%   >> ok = equal_to_tol (a, b)
%   >> ok = equal_to_tol (a, b, tol)
%   >> ok = equal_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> [ok, mess] = equal_to_tol (...)
%
% Class specific version of the generic equal_to_tol that by default
%   (1) assumes NaN are equivalent (see option 'nan_equal'), and
%   (2) ignores the order of pixels within a bin as the order is irrelevant
%       (change the default with option 'reorder')
%
% In addition, it is possible to check the contents of just a random
% fraction of non-empty bins (see option 'fraction') in order to speed up
% the comparison of large objects.
%
% Input:
% ------
%   w1,w2   Test objects (scalar objects, or arrays of objects with same sizes)
%
%   tol     Tolerance criterion for numeric arrays (Default: [0,0] i.e. equality)
%           It has the form: [abstol, reltol] where
%               abstol     absolute tolerance (>=0; if =0 equality required)
%               reltol     relative tolerance (>=0; if =0 equality required)
%           If either criterion is satified then equality within tolerance
%           is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%           For backwards compatibility, a scalar tolerance can be given
%           where the sign determines absolute or relative tolerance
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%             Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%           [To apply an absolute as well as a relative tolerance with a
%            scalar negative value, set the value of the legacy keyword
%           'min_denominator' (see below)]
%
% Valid keywords are:
%  'nan_equal'      Treat NaNs as equal (true or false; default=true)
%
%  'ignore_str'     Ignore the length and content of strings or cell arrays
%                  of strings (true or false; default=false)
%
%  'reorder'        Ignore the order of pixels within each bin
%                  (true or false; default=true)
%                   Only applies if sqw-type object
%
%  'fraction'       Compare pixels in only a fraction of the non-empty bins
%                  (0<= fracton <= 1; default=1 i.e. test all bins)
%                   Only applies if sqw-type object
%  '-ignore_date'   (provided without additional values, so its presence in
%                    the sequence of keywords means true). If provided,
%                    ignore file creation date stored in main header.
%
%       The reorder and fraction options are available because the order of the
%   pixels within the pix array for a given bin is unimportant. Reordering
%   takes time, however, so the option to test on a few bins is given.

if ~isa(w1, 'SQWDnDBase') || ~isa(w2, 'SQWDnDBase')
    ok = false;
    mess = 'One of the objects to be compared is not an sqw or dnd object';
    return
end

% Check array sizes match
if ~isequal(size(w1), size(w2))
    ok = false;
    mess = 'Sizes of object arrays being compared are not equal';
    return
end

% Check that corresponding objects in the array have the same type
% $$$     base_message = 'Objects being compared are not both sqw-type or both dnd-type';
% $$$     for i = 1:numel(w1)
% $$$         if class(w1(i)) ~= class(w2(i))
% $$$             elmtstr = '';
% $$$             if numel(w1) > 1
% $$$                 elmtstr = ['(element ', num2str(i), ')'];
% $$$             end
% $$$
% $$$             ok = false;
% $$$             if numel(w1) > 1
% $$$                 mess = [base_message, ' ', elmtstr];
% $$$             else
% $$$                 mess = base_message;
% $$$             end
% $$$             return
% $$$         end
% $$$     end

% Perform comparison
sz = size(w1);
for i = 1:numel(w1)
    in_name = cell(1, 2);
    in_name{1} = variable_name(inputname(1), false, sz, i, 'input_1');
    in_name{2} = variable_name(inputname(2), false, sz, i, 'input_2');
    if nargin > 2
        opt = {'name_a', 'name_b'};
        [keyval_list, other] = extract_keyvalues(varargin, opt);
        if ~isempty(keyval_list)
            ic = 1;
            for j = 1:2:numel(keyval_list) - 1
                in_name{ic} = variable_name(keyval_list{j+1}, false, sz, i);
                ic = ic + 1;
            end
        end
    else
        other = varargin;
    end
    [ok, mess] = equal_to_tol_internal(w1(i), w2(i), in_name{1}, in_name{2}, other{:});
    if ~ok
        return
    end
end

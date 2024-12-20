function [iseq, mess] = equal_to_tol(obj1, obj2, varargin)
% Return a logical variable stating if two serializable objects are equal or not
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
%   obj2        Object on right-hand side
%
% Optional:
%   p1, p2,...  Any set of parameters that the equal_to_tol function accepts
%

[iseq,mess,~,opt] = process_inputs_for_eq_to_tol(obj1, obj2, ...
    inputname(1), inputname(2),true,varargin{:});
if ~iseq
    return;
end
name_a = opt.name_a;
name_b = opt.name_b;
% Perform comparison
sz = size(obj1);
for i = 1:numel(obj1)
    if numel(obj1)>1  % the variables will be with
        % size-brackets and we do not want them for only one object
        opt.name_a = variable_name(name_a, false, sz, i, 'input_1');
        opt.name_b = variable_name(name_b, false, sz, i, 'input_1');
    end
    %
    [iseq, mess] = equal_to_tol_(obj1, obj2, opt);
    if ~iseq
        return
    end
end


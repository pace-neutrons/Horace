function [ok,mess,opt]=equal_to_tol(a,b,varargin)
% Check if two arguments are equal within a specified tolerance
%
%   >> ok = equal_to_tol (a, b)
%   >> ok = equal_to_tol (a, b, tol)
%   >> ok = equal_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> [ok, mess] = equal_to_tol (...)
%
% Any cell arrays, structures or objects are recursively explored.
%
% Note: legacy usage has scalar tol and equates NaNs as equal. This usage is
% deprecated. Please use the new syntax. Note that the usage: equal_to_tol(a,b),
% which would otherwise be ambiguous as either new style or legacy format, is
% interpreted as the new format. This may result in errors in previously
% running code as now NaNs are not treated as equivalent.
%
% Input:
% ------
%   a,b     Test objects (scalar objects, or arrays of objects with same sizes)
%
%   tol     Tolerance criterion for numeric arrays (Default: [0,0] i.e. equality)
%           It has the form: [abstol, reltol] where
%               abstol     absolute tolerance (>=0; if =0 equality required)
%               reltol     relative tolerance (>=0; if =0 equality required)
%           If either criterion is satisfied then equality within tolerance
%           is accepted.
%             Examples:
%               [1e-4, 1e-6]    absolute 1e-4 or relative 1e-6 required
%               [1e-4, 0]       absolute 1e-4 required
%               [0, 1e-6]       relative 1e-6 required
%               [0, 0]          equality required
%               0               equivalent to [0,0]
%
%            A scalar tolerance can be given where the sign determines if
%           the tolerance is absolute or relative:
%               +ve : absolute tolerance  abserr = abs(a-b)
%               -ve : relative tolerance  relerr = abs(a-b)/max(abs(a),abs(b))
%             Examples:
%               1e-4            absolute tolerance, equivalent to [1e-4, 0]
%               -1e-6           relative tolerance, equivalent to [0, 1e-6]
%
%           [Legacy compatibility: to apply an absolute as well as a relative
%            tolerance with a scalar negative value, set the value of the
%            legacy keyword 'min_denominator' (see below)]
%
% Valid keywords are:
%  'tol'            Tolerance as above (alternative keyword specification
%                  to parameter input above)
%
%  'abstol'         Absolute tolerance; abstol>=0 (alternative keyword
%                  specification to scalar parameter input above).
%                   Use in conjunction with 'reltol' to specify a combined
%                  criterion equivalent to tol = [abstol, reltol]
%
%  'reltol'         Relative tolerance; reltol>=0 (alternative keyword
%                  specification to parameter input above). Note that the
%                  sign is positive here.
%                   Use in conjunction with 'abstol' to specify a combined
%                  criterion equivalent to tol = [abstol, reltol]
%
%  'nan_equal'      Treat NaNs as equal (true or false; default=true)
%
%
%  'name_a'         Explicit name of variable a for use in messages
%                   Usually not required, as the name of a variable will
%                  be discovered. However, if the input argument is an array
%                  element e.g. my_variable{3}  then the name is not
%                  discoverable in Matlab, and default 'input_1' will be
%                  used unless a different value is given with the keyword
%                  'name_a'.
%  'name_b'         Explicit name of variable b for use in messages.
%                   The same comments apply as for 'name_a' except the
%                  default is 'input_2'
%  'ignore_str'    Ignore the length and content of strings or cell arrays
%                  of strings (true or false; default=false)
%
%   throw_on_err   Instead of returning error codes, throw error if
%                  comparison returns false
%
% Valid keys (if present, true, if absent, false) are:
% '-ignore_str'    Ignore the length and content of strings or cell arrays
% '-throw_on_err'  Instead of returning error codes, though error if
%                  comparison returns false.
%
% Output:
% -------
%   ok      true if every element satisfies tolerance criterion, false if not
%   mess    error message if ~ok ('' if ok)
% 
% Optional:
% opt              a structure containing all fields equal_to_tol may
%                  accept with either default values or values, extracted
%                  from input parameters. 
%                  Currently used in tests only and probably should remain this way.
%                  Call  process_inputs_for_eq_to_tol procedure to obtain these keys
%                  as fields of its output structure.
%
%
% -----------------------------
% *** Deprecated use: ***
% -----------------------------
% To apply an absolute as well as a relative tolerance when using a negative
% scalar tolerance, use the keyword:
%
% 'min_denominator' Minimum denominator for relative tolerance calculation.
%                   When the denominator in a relative tolerance is less than
%                  this value, the denominator is replaced by this value.
%
%                   Emulate [abs_tol,rel_tol] by setting
%                       tol = -rel_tol
%                       min_denominator = abs_tol / rel_tol
%
% This use is no longer recommended. Replace:
%       tol = -|rel_tol|    and     min_denominator
% with
%       tol = [|rel_tol|*min_denominator, |rel_tol|]



warn = warning('off','MATLAB:structOnObject');
cleanup_obj = onCleanup(@()warning(warn));
[ok,mess,~,opt] = process_inputs_for_eq_to_tol(a, b, ...
    inputname(1), inputname(2),true, varargin{:});
if ~ok
    return
end
%
% Now perform comparison
try
    % Lazy handling of MATLAB strings
    [a,b] = convertStringsToChars(a,b);

    equal_to_tol_private(a,b,opt);
catch ME
    if opt.throw_on_err
        rethrow(ME)
    elseif strcmp(ME.identifier,'HERBERT:equal_to_tol:inputs_mismatch')
        ok = false;
        mess = ME.message;
    else
        rethrow(ME);
    end
end

end

%--------------------------------------------------------------------------------------------------
function equal_to_tol_private(a,b,opt)
% Check the equality of two arguments within defined tolerance
% Used by public functions equal_to_tol and equaln_to_tol
%
%   >> equal_to_tol_private (a, b, opt, obj_name)
%
% Input:
% ------
%   a, b        Arguments to be compared
%   opt         Structure giving comparison options
%                   ignore_str  If true: ignore length and contents of
%                              and cell arrays of strings
%                   nan_equal   If true: NaNs are considered equal
%                   tol         Two element array [abs_tol, rel_tol] of
%                              absolute and relative tolerance. If either is
%                              satisfied then equality within tolerance is
%                              accepted
%   name_a      Name of first variable
%   name_b      Name of second variable


if opt.ignore_str && (iscellstr(a)||istext(a)) && (iscellstr(b)||istext(b))
    % Case of strings and cell array of strings if they are to be ignored
    % If cell arrays of strings then contents and number of strings are
    % ignored e.g. {'Hello','Mr'}, {'Dog'} and '' are all considered equal
    return;

elseif isobject(a) && isobject(b)
    % --------------------------
    % Both arguments are objects
    % --------------------------
    % Check sizes of arrays are the same
    [is,mess] = is_type_and_shape_equal(a,b,opt);
    if ~is
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            'Comparing: %s and %s: %s',...
            opt.name_a,opt.name_b,mess);
    end
    if ismethod(a,'equal_to_tol')
        [ok,mess] = equal_to_tol(a,b,opt);
        if ~ok
            error('HERBERT:equal_to_tol:inputs_mismatch',...
                ['%s and %s: Objects are not equal due to class-specific equal_to_tol method\n',...
                ' Reason: %s'],...
                opt.name_a,opt.name_b,mess);
        end
        return;
    end
    try
        fieldsA = {meta.class.fromName(class(a)).PropertyList(:).Name};
        fieldsB = {meta.class.fromName(class(b)).PropertyList(:).Name};

    catch ME
        % Still some old-style classes floating around

        if isempty(meta.class.fromName(class(a)))
            fieldsA = fieldnames(struct(a));
            fieldsB = fieldnames(struct(b));
        else
            rethrow(ME)
        end
    end

    extraA = setdiff(fieldsA,fieldsB);
    extraB = setdiff(fieldsB,fieldsA);

    % Check fieldnames are identical
    if ~isempty(extraA) || ~isempty(extraB)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            'Input %s with extra fields: "%s" DIFFERENT from Input %s: with extra fields: "%s"',...
            opt.name_a,strjoin(extraA,'; '),opt.name_b,strjoin(extraB,'; '));
    end

    if isscalar(a) || isa(a, 'containers.Map')
        name_a_ind = opt.name_a;
        name_b_ind = opt.name_b;
        Sa = struct(a);
        Sb = struct(b);

        % If we get here, we need the "right" names
        fieldsA = fieldnames(Sa);
        for j=1:numel(fieldsA)
            lopt = opt;
            lopt.name_a = [name_a_ind,'.',fieldsA{j}];
            lopt.name_b = [name_b_ind,'.',fieldsA{j}];
            equal_to_tol_private(Sa.(fieldsA{j}), Sb.(fieldsA{j}), lopt);
        end
    else
        name_a = opt.name_a;
        name_b = opt.name_b;
        for i=1:numel(a)

            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
            Sa = struct(a(i));
            Sb = struct(b(i));

            % If we get here, we need the "right" names
            fieldsA = fieldnames(Sa);
            for j=1:numel(fieldsA)
                lopt = opt;
                lopt.name_a = [name_a_ind,'.',fieldsA{j}];
                lopt.name_b = [name_b_ind,'.',fieldsA{j}];

                equal_to_tol_private(Sa.(fieldsA{j}), Sb.(fieldsA{j}), lopt);
            end
        end
    end

elseif isstruct(a) && isstruct(b)
    % -----------------------------
    % Both arguments are structures
    % -----------------------------
    % Check sizes of structure arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of arrays of structures being compared are not equal',...
            opt.name_a,opt.name_b);
    end

    % Check fieldnames are identical
    fieldsA = fieldnames(a);
    fieldsB = fieldnames(b);
    extraA = setdiff(fieldsA,fieldsB);
    extraB = setdiff(fieldsB,fieldsA);

    if ~isempty(extraA) || ~isempty(extraB)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            'The structure: "%s" names: "%s" DIFFER from the struct: "%s"  names: "%s"',...
            opt.name_a,strjoin(extraA,'; '),opt.name_b,strjoin(extraB,'; '));
    end

    name_a = opt.name_a;
    name_b = opt.name_b;
    % Check contents of each field are the same
    if isscalar(a)

        for j=1:numel(fieldsA)
            lopt = opt;
            lopt.name_a = [name_a,'.',fieldsA{j}];
            lopt.name_b = [name_b,'.',fieldsA{j}];

            equal_to_tol_private (a.(fieldsA{j}),b.(fieldsA{j}), lopt);
        end

    else
        for i=1:numel(a)
            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
            for j=1:numel(fieldsA)
                lopt = opt;
                lopt.name_a = [name_a_ind,'.',fieldsA{j}];
                lopt.name_b = [name_b_ind,'.',fieldsA{j}];

                equal_to_tol_private (a(i).(fieldsA{j}),...
                    b(i).(fieldsA{j}), lopt);
            end
        end
    end

elseif iscell(a) && iscell(b)
    % ------------------------------
    % Both arguments are cell arrays
    % ------------------------------
    % Check sizes of structure arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of cell arrays being compared are not equal',...
            opt.name_a,opt.name_b);
    end

    name_a = opt.name_a;
    name_b = opt.name_b;
    % Check contents of each element of the arrays
    for i=1:numel(a)
        lopt = opt;
        lopt.name_a =[name_a,'{',arraystr(sz,i),'}'];
        lopt.name_b = [name_b,'{',arraystr(sz,i),'}'];

        equal_to_tol_private (a{i} ,b{i}, lopt);
    end

elseif isnumeric(a) && isnumeric(b)
    % ---------------------------------
    % Both arguments are numeric arrays
    % ---------------------------------
    equal_to_tol_numeric(a,b,opt);

elseif ischar(a) && ischar(b)
    % -----------------------------------
    % Both arguments are character arrays
    % -----------------------------------
    % Check sizes of structure arrays are the same
    if ~isequal(size(a),size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of character arrays being compared are not equal',...
            opt.name_a,opt.name_b);
    end
    is_datetime = false;
    if isrow(a) && ~isempty(regexp(a, '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}','once'))
        % Probably dealing with datetime string
        try
            a = main_header_cl.convert_datetime_from_str(a);
            b = main_header_cl.convert_datetime_from_str(b);
            is_datetime= true;
            % Allow separation of up to 1 minute to be same
            if abs(posixtime(a) - posixtime(b)) < 60
                return
            end
        catch
        end
    end

    if ~strcmp(a,b)
        if is_datetime
            mess = sprintf('Object %s with Time=%s  and object %s, with Time=%s are different for more than a minute', ...
                opt.name_a,a,opt.name_b,b);
        else
            mess = sprintf('%s and %s: Character arrays being compared are not equal', ...
                opt.name_a,opt.name_b);
        end
        error('HERBERT:equal_to_tol:inputs_mismatch',mess);
    end

elseif strcmp(class(a),class(b))
    % ------------------------------------------------------------------------
    % Catch-all for anything else - should hsve been caught by the cases above
    % but Alex had added it (I think), so maybe it was needed
    % ------------------------------------------------------------------------
    if ~isequal(size(a),size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of arrays of objects being compared are not equal',...
            opt.name_a,opt.name_b);

    end

    if ~isequal(a,b)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Object (or object arrays) are not equal',...
            opt.name_a,opt.name_b);
    end
else
    % -----------------------------------------------
    % Items being compared do not have the same class
    % -----------------------------------------------
    error('HERBERT:equal_to_tol:inputs_mismatch',...
        '%s and %s: Have different classes: %s and %s',...
        opt.name_a,opt.name_b,class(a),class(b));
end

end

%--------------------------------------------------------------------------------------------------
function equal_to_tol_numeric(a,b,opt)
% Check two arrays have same size and each element is the same within
% requested relative or absolute tolerance.

tol = opt.tol;
nan_equal = opt.nan_equal;
name_a = opt.name_a;
name_b = opt.name_b;
sz=size(a);

if any(sz ~= size(b))
    error('HERBERT:equal_to_tol:inputs_mismatch',...
        '%s and %s: Different size numeric arrays',...
        name_a,name_b);
end

% Turn arrays into vectors (avoids problems with MATLAB changing shapes
% of arrays when logical filtering is performed
a=a(:);
b=b(:);

% Treatment of NaN elements
if nan_equal
    % If NaNs are to be ignored, remove them from consideration
    keep=~isnan(a);
    if any(keep ~= ~isnan(b))    % check NaNs have the same locations in both arrays
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: NaN elements not in same locations in numeric arrays',...
            name_a,name_b);
    else
        a=a(keep);
        b=b(keep);
    end
else
    % If any NaNs the equality fails
    bad=(isnan(a)|isnan(b));
    if any(bad)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: NaN elements in one or both numeric arrays',...
            name_a,name_b);
    end
end

% Treatment of Inf elements
infs_mark=isinf(a);
if any(infs_mark)   % Inf elements are present
    if any(infs_mark ~= isinf(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Inf elements not in same locations in numeric arrays',...
            name_a,name_b);
    elseif any(sign(a(infs_mark))~=sign(b(infs_mark)))

        ind=find(infs_mark,1);
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Inf elements have different signs; first occurrence at element %s',...
            name_a,name_b,['(',arraystr(sz,ind),')']);
    end
    a=a(~infs_mark);            % filter out Inf elements from further consideration
    b=b(~infs_mark);
end

% Compare elements. Pass the case of empty arrays - these are considered equal
if isempty(a)
    return
end

% All elements to be compared are finite (dealt with Inf and NaN above)
abs_tol = tol(1);
rel_tol = tol(2);
if ~isa(a,class(b))
    a = double(a);
    b = double(b);
end
if abs_tol==0 && rel_tol==0

    % Equality required
    if any(a~=b)
        [max_delta, ind] = max(abs(a-b));
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Not all elements are equal; max. error = %s at element %s',...
            name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
    end

elseif rel_tol == 0

    [max_delta, ind] = max(abs(a-b));

    if max_delta > abs_tol
        % Absolute tolerance must be satisfied
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Absolute tolerance failure; max. error = %s at element %s',...
            name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
    end

elseif abs_tol == 0

    [max_delta, ind] = max(rel_diff(a, b));

    if max_delta > rel_tol
        % Relative tolerance must be satisfied
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Relative tolerance failure; max. error = %s at element %s',...
            name_a,name_b,num2str(max_delta),['(',arraystr(sz,ind),')']);
    end

else
    diff = abs(a-b);
    [max_delta_abs, ind_abs] = max(diff);
    [max_delta_rel, ind_rel] = max(diff./max(abs(a),abs(b)));

    if max_delta_abs > abs_tol && max_delta_rel > rel_tol
        % Absolute or relative tolerance must be satisfied
        if max_delta_rel/rel_tol > max_delta_abs/abs_tol
            error('HERBERT:equal_to_tol:inputs_mismatch',...
                '%s and %s: Relative and absolute tolerance failure; max. error = %s (relative) at element %s',...
                name_a,name_b,num2str(max_delta_rel),['(',arraystr(sz,ind_rel),')']);
        else
            error('HERBERT:equal_to_tol:inputs_mismatch',...
                '%s and %s: Relative and absolute tolerance failure; max. error = %s (absolute) at element %s',...
                name_a,name_b,num2str(max_delta_abs),['(',arraystr(sz,ind_abs),')']);
        end
    end
end

end

%--------------------------------------------------------------------------------------------------
function str=arraystr(sz,i)
% Make a string of the form '2,3,1' (or '23' if vector) from a size array and single index

if isvector(sz)
    str=num2str(i);
else
    ind=cell(1,numel(sz));
    [ind{:}]=ind2sub(sz,i);
    j=1:numel(ind);
    str=arrayfun(@(j)num2str(ind{j}),j,'UniformOutput',false);
    str = strjoin(str,',');
end

end

function rel = rel_diff(a, b)

rel = abs(a-b)./max(abs(a),abs(b));

end

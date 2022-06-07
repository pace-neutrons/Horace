function [ok,mess]=equal_to_tol(a,b,varargin)
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
%           It has the form: [abs_tol, rel_tol] where
%               abs_tol     absolute tolerance (>=0; if =0 equality required)
%               rel_tol     relative tolerance (>=0; if =0 equality required)
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
%  'ignore_str'     Ignore the length and content of strings or cell arrays
%                  of strings (true or false; default=false)
%
%   throw_on_err   Instead of returning error codes, thow error if some
%                  fields are not consistent
%
%  'name_a'         Explicit name of variable a for use in messages
%                   Usually not required, as the name of a variable will
%                  be discovered. However, if the input argument is an array
%                  element e.g. my_variable{3}  then the name is not
%                  discoverable in Matlab, and default 'input_1' will be
%                  used unless a different value is given with the keyword
%                  'name_a'.
%
%  'name_b'         Explicit name of variable b for use in messages.
%                   The same comments apply as for 'name_a' except the
%                  default is 'input_2'
%
%
% Output:
% -------
%   ok      true if every element satisfies tolerance criterion, false if not
%   mess    error message if ~ok ('' if ok)
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


% Original author: T.G.Perring
%
%
% The following code is pretty complex as it has to handle legacy input as
% well. Touch at your peril!

ok = true;
mess = '';

warn = warning('off','MATLAB:structOnObject');
cleanup_obj = onCleanup(@()warning(warn));


% Get names of input variables, if can
name_a_default = 'input_1';
name_b_default = 'input_2';
name_a = inputname(1);
name_b = inputname(2);
if isempty(name_a)
    name_a = name_a_default;
end
if isempty(name_b)
    name_b = name_b_default;
end

% Lazy handling of MATLAB strings
[a,b] = convertStringsToChars(a,b);

% Parse input arguments
if nargin==2
    % Inputs to compare only; save an expensive call to parse_arguments
    opt.nan_equal = true;
    opt.ignore_str = false;
    opt.tol = [0,0];
    opt.throw_on_err=false;

elseif nargin==3 && isnumeric(varargin{1})
    % Case of no optional arguments; save an expensive call to parse_arguments
    opt.nan_equal = true;
    opt.ignore_str = false;

    % Determine if legacy input; it must be if tol is scalar
    if isscalar(varargin{1})
        opt.tol=check_tol(varargin{1},0);
    else
        opt.tol=check_tol(varargin{1});
    end
    opt.throw_on_err=false;
else
    % Optional arguments must have been given; parse input arguments
    % opt filled with default for new format; strip min_denominator away later

    opt = struct(...
        'tolerance',[],...
        'abstolerance',0,...
        'reltolerance',0,...
        'ignore_str',false,...
        'nan_equal',true,...
        'name_a',name_a,...
        'name_b',name_b,...
        'min_denominator',0,...
        'throw_on_err',false);
    cntl.keys_once=false;   % so name_a and name_b can be overridden by input arguments
    cntl.keys_at_end=false; % as may have name_a or name_b appear first in some cases
    [par, opt, present, ~] = parse_arguments(varargin, opt, cntl);

    % Determine the tolerance
    ok_positive_scalar = @(x)(isnumeric(x) && isscalar(x) && ~isnan(x) && x>=0);
    if numel(par)==1 && isnumeric(par{1})
        % There is a single parameter that is numeric, so must be tol
        if isscalar(par{1})
            % Legacy format
            tol=check_tol(par{1},opt.min_denominator);
        else
            % New format
            tol=check_tol(par{1});
            % Invalid keyword 'min_denominator' cannot present with new format
            if present.min_denominator
                error('HERBERT:equal_to_tol:invalid_argument',...
                    '''min_denominator'' is only valid for legacy scalar tolerance')
            end
        end
        % Check that tolerance has not been given as a keyword parameter as well
        if present.tolerance || present.abstolerance || present.reltolerance
            error('HERBERT:equal_to_tol:invalid_argument',...
                ['Cannot give the tolerance as third input argument and'...
                'also as a keyword parameter'])
        end

    elseif numel(par)==0
        % No tolerance parameter given, so determine from keywords if possible.
        if ~any([present.tolerance, present.abstolerance, present.reltolerance])
            % No tolerance keywords present - use default tol; still unresolved
            % if legacy or not, but presence of min_denominator will not make any
            % difference to the test. Just need to check it is valid if given
            if present.min_denominator
                % Treat as legacy
                tol = check_tol(0,opt.min_denominator);
            else
                % Treat as new format
                tol = [0,0];
            end

        else
            % Tolerance keyword(s) present; usage is therefore non-legacy.

            % Check that invalid keyword 'min_denominator' is not present
            if present.min_denominator
                error('HERBERT:equal_to_tol:invalid_argument',...
                    '''min_denominator'' is only valid for legacy argument format')
            end

            % Determine tolerance
            if present.tolerance && ~(present.abstolerance || present.reltolerance)
                if isnumeric(opt.tolerance)
                    tol = check_tol(opt.tolerance);
                else
                    error('HERBERT:equal_to_tol:invalid_argument',...
                        '''tol'' must be numeric')
                end
            elseif ~present.tolerance
                if present.abstolerance && present.reltolerance
                    if ok_positive_scalar(opt.abstolerance) && ok_positive_scalar(opt.reltolerance)
                        tol = [opt.abstolerance,opt.reltolerance];
                    else
                        error('HERBERT:equal_to_tol:invalid_argument',...
                            ['''abstol'' and ''reltol'' must both be '...
                            'numeric scalars greater or equal to zero'])
                    end
                elseif present.abstolerance
                    if ok_positive_scalar(opt.abstolerance)
                        tol = [opt.abstolerance,0];
                    else
                        error('HERBERT:equal_to_tol:invalid_argument',...
                            '''abstol'' must be a numeric scalar greater or equal to zero')
                    end
                elseif present.reltolerance
                    if ok_positive_scalar(opt.reltolerance)
                        tol = [0,opt.reltolerance];
                    else
                        error('HERBERT:equal_to_tol:invalid_argument',...
                            '''reltol'' must be a numeric scalar greater or equal to zero')
                    end
                else
                    tol = [0,0];
                end
            else
                error('HERBERT:equal_to_tol:invalid_argument',...
                    '''tol'' cannot be present with ''abstol'' or ''reltol''')
            end

        end
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check number and type of non-keyword input arguments')
    end

    % Strip away temporary fields
    name_a = opt.name_a;
    name_b = opt.name_b;
    if isempty(name_a)
        name_a = name_a_default;
    end
    if isempty(name_b)
        name_b = name_b_default;
    end
    opt = rmfield(opt, {'min_denominator','name_a','name_b',...
        'tolerance','abstolerance','reltolerance'});

    if islognumscalar(opt.ignore_str)
        opt.ignore_str = logical(opt.ignore_str);
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check ''ignore_str'' is logical scalar (or 0 or 1)')
    end
    if islognumscalar(opt.nan_equal)
        opt.nan_equal = logical(opt.nan_equal);
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check ''nan_equal'' is logical scalar (or 0 or 1)')
    end
    opt.tol = tol;
end

% Now perform comparison
try
    equal_to_tol_private(a,b,opt,name_a,name_b);
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
function tol_out = check_tol (tol, min_denominator)
% Convert all the possible inputs into [abs_tol, rel_tol]
% Assumes tol_in is numeric
%
%   >> tol = check_tol (tol_in)
%   >> tol = check_tol (tol_in, min_denominator]


ok_positive_scalar = @(x)(isnumeric(x) && isscalar(x) && ~isnan(x) && x>=0);

if isempty(tol)
    tol_out = [0,0];

elseif isscalar(tol)
    if ~isnan(tol)
        if tol>=0
            tol_out = [tol,0];
        else
            if ok_positive_scalar(min_denominator)
                tol_out = [min_denominator*abs(tol),abs(tol)];
            else
                error('HERBERT:equal_to_tol:invalid_argument',...
                    'Check value of ''min_denominator'' is greater or equal to zero');
            end
        end
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Tolerance cannot be NaN');
    end

elseif numel(tol)==2
    if all(tol>=0)
        tol_out = tol;
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check tolerance has form [abs_tol, rel_tol] where both are >=0');
    end
else
    error('HERBERT:equal_to_tol:invalid_argument',...
        'The tolerance is not a positive numeric scalar');
end

end

%--------------------------------------------------------------------------------------------------
function equal_to_tol_private(a,b,opt,name_a,name_b)
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


if opt.ignore_str && (iscellstr(a)||ischar(a)) && (iscellstr(b)||ischar(b))
    % Case of strings and cell array of strings if they are to be ignored
    % If cell arrays of strings then contents and number of strings are
    % ignored e.g. {'Hello','Mr'}, {'Dog'} and '' are all considered equal
    return;

elseif isobject(a) && isobject(b)
    % --------------------------
    % Both arguments are objects
    % --------------------------
    % Check sizes of arrays are the same
    sz=size(a);
    if ~isequal(sz,size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of arrays of objects being compared are not equal',...
            name_a,name_b);
    end
    if ismethod(a,'eq') && ~isa(a,'handle')
        try
            [is,mess] = eq(a,b,opt.ignore_str);
        catch ME
            if strcmp(ME.identifier,'MATLAB:TooManyInputs') ||...
                strcmp(ME.identifier,'MATLAB:UndefinedFunction')
                is = eq(a,b);
                if ~is
                    mess = 'class "eq" operation returned false';
                end
            else
                rethrow(ME);
            end
        end
        if ~is
            error('HERBERT:equal_to_tol:inputs_mismatch',...
                'Input object %s differs from input object %s reason: %s',...
                name_a,name_b,mess);
        end
        return;
    end

    try
        fieldsA = {meta.class.fromName(class(a)).PropertyList(:).Name}
        fieldsB = {meta.class.fromName(class(b)).PropertyList(:).Name}

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
              name_a,strjoin(extraA,'; '),name_b,strjoin(extraB,'; '));
    end

    if isscalar(a) || isa(a, 'containers.Map')
        name_a_ind = name_a;
        name_b_ind = name_b;
        Sa = struct(a);
        Sb = struct(b);

        % If we get here, we need the "right" names
        fieldsA = fieldnames(Sa);
        for j=1:numel(fieldsA)
            equal_to_tol_private(Sa.(fieldsA{j}), Sb.(fieldsA{j}), opt,...
                                 [name_a_ind,'.',fieldsA{j}], [name_b_ind,'.',fieldsA{j}]);
        end
    else
        for i=1:numel(a)
            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
            Sa = struct(a(i));
            Sb = struct(b(i));

            % If we get here, we need the "right" names
            fieldsA = fieldnames(Sa);
            for j=1:numel(fieldsA)
                equal_to_tol_private(Sa.(fieldsA{j}), Sb.(fieldsA{j}), opt,...
                                     [name_a_ind,'.',fieldsA{j}], [name_b_ind,'.',fieldsA{j}]);
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
            name_a,name_b);
    end

    % Check fieldnames are identical
    fieldsA = fieldnames(a);
    fieldsB = fieldnames(b);
    extraA = setdiff(fieldsA,fieldsB);
    extraB = setdiff(fieldsB,fieldsA);

    if ~isempty(extraA) || ~isempty(extraB)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            'The structure: "%s" names: "%s" DIFFER from the struct: "%s"  names: "%s"',...
            name_a,strjoin(extraA,'; '),name_b,strjoin(extraB,'; '));
    end

    % Check contents of each field are the same
    if isscalar(a)
        name_a_ind = name_a;
        name_b_ind = name_b;

        for j=1:numel(fieldsA)
            equal_to_tol_private (a.(fieldsA{j}),...
                b.(fieldsA{j}), opt,...
                [name_a_ind,'.',fieldsA{j}], [name_b_ind,'.',fieldsA{j}]);
        end

    else
        for i=1:numel(a)
            name_a_ind = [name_a,'(',arraystr(sz,i),')'];
            name_b_ind = [name_b,'(',arraystr(sz,i),')'];
            for j=1:numel(fieldsA)
                equal_to_tol_private (a(i).(fieldsA{j}),...
                                      b(i).(fieldsA{j}), opt,...
                                      [name_a_ind,'.',fieldsA{j}], [name_b_ind,'.',fieldsA{j}]);
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
            name_a,name_b);
    end

    % Check contents of each element of the arrays
    for i=1:numel(a)
        name_a_ind = [name_a,'{',arraystr(sz,i),'}'];
        name_b_ind = [name_b,'{',arraystr(sz,i),'}'];
        equal_to_tol_private (a{i} ,b{i}, opt, name_a_ind, name_b_ind);
    end

elseif isnumeric(a) && isnumeric(b)
    % ---------------------------------
    % Both arguments are numeric arrays
    % ---------------------------------
    equal_to_tol_numeric(a,b,opt.tol,opt.nan_equal,name_a,name_b);

elseif ischar(a) && ischar(b)
    % -----------------------------------
    % Both arguments are character arrays
    % -----------------------------------
    % Check sizes of structure arrays are the same
    if ~isequal(size(a),size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of character arrays being compared are not equal',...
            name_a,name_b);
    end

    if ~strcmp(a,b)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Character arrays being compared are not equal',...
            name_a,name_b);
    end

elseif strcmp(class(a),class(b))
    % ------------------------------------------------------------------------
    % Catch-all for anything else - should hsve been caught by the cases above
    % but Alex had added it (I think), so maybe it was needed
    % ------------------------------------------------------------------------
    if ~isequal(size(a),size(b))
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Sizes of arrays of objects being compared are not equal',...
            name_a,name_b);

    end

    if ~isequal(a,b)
        error('HERBERT:equal_to_tol:inputs_mismatch',...
            '%s and %s: Object (or object arrays) are not equal',...
            name_a,name_b);
    end

else
    % -----------------------------------------------
    % Items being compared do not have the same class
    % -----------------------------------------------
    error('HERBERT:equal_to_tol:inputs_mismatch',...
        '%s and %s: Have different classes: %s and %s',...
        name_a,name_b,class(a),class(b));
end

end

%--------------------------------------------------------------------------------------------------
function equal_to_tol_numeric(a,b,tol,nan_equal,name_a,name_b)
% Check two arrays have smae size and each element is the same within
% requested relative or absolute tolerance.

sz=size(a);

if any(sz ~= size(b))
    error('HERBERT:equal_to_tol:inputs_mismatch',...
          '%s and %s: Different size numeric arrays',...
          name_a,name_b);
end

% Turn arrays into vectors (avoids problems with matlab changing shapes
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
            '%s and %s: Inf elements have different signs; first occurence at element %s',...
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

    [max_delta, ind] = max(abs(a-b)./max(abs(a),abs(b)));

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
    str='';
    for j=1:numel(ind)
        str=[str,num2str(ind{j}),','];
    end
    str=str(1:end-1);
end

end
function opt = parse_equal_to_tol_inputs(name_a,name_b,varargin)
% PARSE_EQUAL_TO_TOL_INPUTS validates inputs for equal_to_tol function
% and returns standard form of these inputs.
%
% NOTE:
% Basic solution. Expect all possible equal_to_toll overload keys to be
% specified here. See Re #
%
% The method is separated to be provided to multiple equal_to_tol overloads
% in multiple classes
%   >> opt = parse_equal_to_tol_inputs(name_a,name_b);
%   >> opt = equal_to_tol (name_a,name_b, tol)
%   >> opt = equal_to_tol (..., keyword1, val1, keyword2, val2,...)
%   >> opt = equal_to_tol (...,-key1,-key2,...)
%   >> opt = equal_to_tol (...,opt)
%
% Input:
% ------
%   name_a,name_b Two names of objects to process.
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
%   throw_on_err   Instead of returning error codes, thow error if
%                  comparison returns false
%
% Valid keys (if present, true, if absent, false) are:
% '-ignore_str'    Ignore the length and content of strings or cell arrays
% '-throw_on_err'  Instead of returning error codes, thow error if
%                  comparison returns false.
% '-nan_different'  if data contain values, they are different (true or false; default=false)
% '-ignore_date'    if true, do not compare possible dates
% SPECIAL OPTION:
% opt    -- if this option is provided, it is returned with output with
%           possible modifications from keys and parameters provided as input
%
%
% Retuns:
% opt   -- structure with fields, provided above, which contains default or
%          processed variables.

nargi = nargin;
is_recursive = cellfun(@(x)isstruct(x)&&isfield(x,'recursive_call'),varargin);
if any(is_recursive)
    nargi = nargi-1;
    opt = varargin{is_recursive};
    argi = varargin(~is_recursive);
    if nargi == 2
        if isfield(opt,'name_is_provided')
            opt = rmfield(opt,'name_is_provided');
        else
            opt.name_a = [opt.name_a,'.',name_a];
            opt.name_b = [opt.name_b,'.',name_b];
        end
        return
    end
else
    argi = varargin;
end
if nargi == 3 && isnumeric(varargin{1})
    % Determine if legacy input; it must be if tol is scalar
    if isscalar(varargin{1})
        tol=check_tol(varargin{1},0);
    else
        tol=check_tol(varargin{1});
    end
else
    tol = [0,0];
end

% process non_recursive inputs
keys = {'-ignore_str','-throw_on_err','-nan_different','-ignore_date',...
    '-reorder'};
[ok,mess,ignore_str,throw_on_difference,nan_different,ignore_date,reorder,argi] =...
    parse_char_options(argi,keys);
if ~ok
    error('HERBERT:parse_equal_to_tol:invalid_arguments',mess);
end
opt = struct(...
    'tol',tol,...
    'tolerance',[],...
    'abstolerance',0,...
    'reltolerance',0,...
    'ignore_str',ignore_str,...
    'nan_equal',nan_different,...
    'name_a',name_a,...
    'name_b',name_b,...
    'min_denominator',0,...
    'throw_on_err',throw_on_difference,...
    'ignore_date' ,ignore_date, ... % equal_to_tol sqw/dnd
    'reorder',     reorder,     ... % equal_to_tol sqw/pix
    'fraction',1,               ... % equal_to_tol sqw/pix
    'npix',[]                   ... % equal_to_tol pix
    );

cntl.keys_once  =false;  % so name_a and name_b can be overridden by input arguments
cntl.keys_at_end=false;  % as may have name_a or name_b appear first in some cases
[par, opt, present, ~] = parse_arguments(argi, opt, cntl);

% Check inputs:
opt = check_reoder_and_fraction(opt,present);

opt = extract_tolerance(opt,par,present);

% check other possible arguments
if present.ignore_str
    if islognumscalar(opt.ignore_str)
        opt.ignore_str = logical(opt.ignore_str);
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check ''ignore_str'' is logical scalar (or 0 or 1)')
    end
end
if present.nan_equal
    if islognumscalar(opt.nan_equal)
        opt.nan_equal = logical(opt.nan_equal);
    else
        error('HERBERT:equal_to_tol:invalid_argument',...
            'Check ''nan_equal'' is logical scalar (or 0 or 1)')
    end
end
if present.name_a
    opt.name_a = [opt.name_a,'.',name_a];
end
if present.name_b
    opt.name_b = [opt.name_b,'.',name_b];
end

opt.recursive_call = true;
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

function  opt = check_reoder_and_fraction(opt,present)
if present.reorder && ~islognumscalar(opt.reorder)
    error('SQW:equal_to_tol_internal', ...
        '''reorder'' must be a logical scalar (or 0 or 1)')
end
if present.fraction && (~isnumeric(opt.fraction) || opt.fraction < 0 || opt.fraction > 1)
    error('SQW:equal_to_tol_internal', ...
        '''fraction'' must lie in the range 0 to 1 inclusive')
end
end

function opt = extract_tolerance(opt,par,present)
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
        'Unrecognized input argument(s): %s',disp2str(par));
end
opt.tol = tol;
end
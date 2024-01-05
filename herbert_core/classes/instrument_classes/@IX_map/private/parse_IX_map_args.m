function [wkno_out, ns_out, s_out] = parse_IX_map_args (varargin)
% Parse the input arguments to the IX_map constructor
%
%   >> [wkno_out, ns_out, s_out] = parse_IX_map_args (varargin)
%
% Input:
% ------
%
% Single spectrum to single workspace, one-to-one mapping of spectra
% to workspaces, or general many-to-one mapping:
% ----------------------------------------------
%   >> w = IX_map (s)   % s scalar: single spectrum to workspace 1
%                       % s array:  one spectrum in each of workspaces 1,2,3...
%   >> w = IX_map (s, 'wkno', wkno)
%                       % wkno scalar: all spectra mapped into that workspace
%                       % wkno array:  one spectrum per workspace
%   >> w = IX_map (s, 'ns', ns)
%                       % Spectra grouped in workspaces by the number of spectra
%                       % per workspace in ns. Workspaces numbered 1,2,3...
%   >> w = IX_map (s, 'wkno', wkno, 'ns', ns)
%                       % Workspace numbers and number of spectra in each
%                       % of the workspaces
%
% Groups of contiguous spectra to contiguous workspace numbers:
% -------------------------------------------------------------
%   >> w = IX_map (s_beg, s_end)            % one spectrum per workspace
%   >> w = IX_map (s_beg, s_end, step)      % |step| spectra per workspace
%   >> w = IX_map (..., 'wkno', wkno_beg)   % Mapped to workspaces starting at
%                                           % wkno_beg, ascending or descending
%                                           % according as the sign of step
%
% With either of the two cases above, the mapping can be repeated multiple times
% with successive increments of the spectra and workspace number for each repeat
% of the block:
%   >> ... = parse_IX_map_args (..., 'repeat', [nrepeat, delta_s, delta_w])
%
%
% Output:
% -------
%   wkno_out    Workspace numbers (Column vector).
%               There may be multiple occurences of the same workspace number in
%               wkno_out, depending on the values of the input parameters (for
%               example, there is no requirement that the list of workspace
%               numbers in wkno contains just unique values)
%
%   ns_out      Number of spectra in each workspace in the array wkno_out. 
%               (column vector, same length as wkno_out)
%               If a workspace number is repeated in wkno_out this does not cause
%               any problems: it is treated as the spectra contributing to the
%               workspace as being split into two or more sections
%
%   s_out       Spectrum numbers that will be grouped into workspaces according
%               as wkno_out and ns_out (column vector)


npar_req = 1;
npar_opt = 2;
keyval_def = struct('wkno', [], 'ns', [], 'repeat', [1,0,0]);% default: no repeat
[par, keyval, present, ~, ok, mess] = parse_arguments ...
    (varargin, npar_req, npar_opt, keyval_def);

if ~ok
    error ('HERBERT:IX_map:invalid_argument', mess)
end

% Determine if IX_map(s_beg, s_end, ...) or IX_map (s, ...) input
% and if optional 'wkno' and 'ns', if present.

if numel(par)==1
    % Must be IX_map (s, ...), IX_map (s, 'wkno', wkno), or
    % IX_map (s, 'wkno', wkno, 'ns', ns)
    
    % Check s
    s = par{1}(:);
    if isempty(s)
        s = zeros(0,1);
    elseif ~all_positive_integers(s)
        error ('HERBERT:IX_map:invalid_argument', ...
            'Spectrum numbers must all be greater than or equal to 1')
    end
    
    % Check presence or otherwise of wkno and ns
    if ~present.wkno
        if present.ns
            % Group spectra into workspaces according to the values in ns
            % The workspace numbers will be assigned 1,2,3...
            ns = keyval.ns(:);
            if isempty(ns)
                ns = zeros(0,1);
            elseif ~all_integers_ge_zero(ns)
                error ('HERBERT:IX_map:invalid_argument', ['The number of ' ...
                    'spectra in each workspace must be greater than or equal to zero'])
            end
            
            if sum(ns) ~= numel(s)
                error ('HERBERT:IX_map:invalid_argument', ['The number of ' ...
                    'spectra does not match the number expected in the workspaces'])
            end
            wkno = (1:numel(ns))';
        else
            % Assume 1:1 mapping to workspaces 1,2,3...
            wkno = (1:numel(s))';
            ns = ones(numel(wkno),1);
        end
        
    else
        % Workspace numbers are given - either one-to-one with the spectrum
        % number list, s, or correspond to groups of spectra with the numbers in
        % each group given by the optional argumnet ns.
        wkno = keyval.wkno(:);
        if isempty(wkno)
            wkno = zeros(0,1);
        elseif ~all_positive_integers(wkno)
            error ('HERBERT:IX_map:invalid_argument', ...
                'Workspace numbers must all be greater than or equal to 1')
        end
        
        if present.ns
            % Workspace numbers and the number of spectra in each workspace are
            % given.
            %  Note:
            % - wkno does not need to contain unique workspace numbers: the
            %   total number of contributing spectra will be given by the sum of
            %   the corresponding values of ns for each element of wkno with the
            %   same workspace number
            % - ns can contain zeros: these describe empty workspaces i.e. no
            %   contributing spectra
            ns = keyval.ns(:);
            if isempty(ns)
                ns = zeros(0,1);
            elseif ~all_integers_ge_zero(ns)
                error ('HERBERT:IX_map:invalid_argument', ['The number of ' ...
                    'spectra in each workspace must be greater than or equal to zero'])
            end
            
            if numel(ns) ~= numel(wkno)
                error ('HERBERT:IX_map:invalid_argument', ...
                    ['The number of elements in the array ''ns'', which gives the number of\n' ...
                    'spectra in each workspace must equal the number of workspaces'])
            elseif sum(ns) ~= numel(s)
                error ('HERBERT:IX_map:invalid_argument', ['The number of ' ...
                    'spectra does not match the number expected in the workspaces'])
            end
        else
            % Interpret scalar wkno as all spectra into a single workspace, or
            % otherwise the workspaces and spectra assumed to be in one-to-one
            % mapping
            if isscalar(wkno)
                % All spectra go into a single workspace (this includes the case
                % when s is an empty array)
                ns = numel(s);
            elseif numel(wkno) == numel(s)
                % Assume one-to-one mapping of workspaces and spectra
                ns = ones(numel(wkno),1);
            else
                error ('HERBERT:IX_map:invalid_argument', ['The workspace array ',...
                    'must be scalar or have same length as spectrum array'])
            end
        end
    end

    % Parse 'repeat' option
    repeat_pars = keyval.repeat;
    Nschema = 1;
    [nrepeat, delta_s, delta_wkno] = parse_repeat_pars (repeat_pars, Nschema);
    
    % Output full spectra and workspace numbers lists
    [wkno_out, ns_out, s_out] = repeat_s_w_arrays (wkno, ns, s, nrepeat, ...
        delta_s, delta_wkno);
    
else
    % Must be  IX_map(s_beg, s_end [, step]) or IX_map(s_beg, s_end [, step],...
    % 'wkno', wkno_beg). Option 'ns' is not permitted
    if present.ns
        error ('HERBERT:IX_map:invalid_argument', ['Keword option ''ns'' is not ',...
            'permitted if spectrum grouping is explicitly given'])
    end
    
    % Parse the grouping of spectra and check that it is valid
    [s_beg, s_end, ngroup, s_dcn, wkno_dcn] = parse_spectrum_grouping (par{:});
    Nschema = numel(s_beg);   % number of spectra-to-workspace mapping schemas
    
    % Check wkno_beg is valid and consistent with s_beg and s_end
    % Otherwise create default
    if ~present.wkno
        wkno_beg = parse_initial_workspace_numbers (NaN, Nschema);
    else
        wkno_beg_in = keyval.wkno;
        wkno_beg = parse_initial_workspace_numbers (wkno_beg_in, Nschema);
    end
    
    % Parse 'repeat' option
    repeat_pars = keyval.repeat;
    [nrepeat, delta_s, delta_wkno] = parse_repeat_pars (repeat_pars, Nschema);
    
    % Output full spectra and workspace numbers lists
    [wkno_out, ns_out, s_out] = repeat_s_w_blocks (s_beg, s_end, ...
        ngroup, s_dcn, wkno_beg, wkno_dcn, nrepeat, delta_s, delta_wkno);
end

end

    
%-------------------------------------------------------------------------------
function [s_beg, s_end, ngroup, s_dcn, wkno_dcn] = parse_spectrum_grouping ...
    (s_beg_in, s_end_in, step)
% Parse spectrum grouping for set of spectrum-to-workspace schemas
%
%   >> [s_beg, s_end, ngroup, s_dcn, wkno_dcn] = parse_spectrum_grouping ...
%                                               (s_beg_in, s_end_in, step)
%
% Input arguments can be scalars (one schema), or vectors (multiple schema)
%
% Input:
% ------
%   s_beg_in        Starting spectrum numbers for each schema (vector; one
%                   element per schema)
%   s_end_in        Final spectrum numbers for each schema (vector; one
%                   element per schema)
% 
% Optionally:
%   step            Grouping and workspace increment sign (all elements ~=0)
%                   - Group spectra in the ith schema in groups size |step(i)|
%                     (the last group will be the remainder if less than
%                     |step(i)| spectra are left)
%                   - Workspace numbers increase by +1 or -1 according to sign
%                     of step(i)
%                   Can be scalar (applies to all schemas) or vector (one
%                   element per schema)
%
%                   Default: +1 i.e. one spectrum per workspace, and workspace
%                   number increments by +1 for each group starting from
%                   s_beg_in
%
% Output:
% -------
%   s_beg           Starting spectrum numbers for each schema (column vector)
%   s_end           Final spectrum numbers for each schema (column vectors)
%   ngroup          Spectrum group sizes for each schema (Column vector)
%                   Elements are greater or equal to 1.
%                   Default if step not given: 1 (i.e. one-to-one to workspaces)
%   s_dcn           +/-1 indicating spectrum numbers increment (+1) or decrement
%                   (-1) from s_beg (Column vector).
%                   If s_beg(i) == s_end(i) then = +1) 
%   wkno_dcn        +/-1 indicate workspace numbers increment (+1) or decrement
%                   (-1) from the starting value for the schema (Column vector).
%                   Default if step not given: +1 for each group


% Check s_beg and s_end are valid and have same number of elements
if isnumeric(s_beg_in) && isnumeric (s_end_in) && isvector(s_beg_in) ...
        && isvector(s_end_in)
    % Make column vectors (could have been rows)
    s_beg = s_beg_in(:);
    s_end = s_end_in(:);
else
    error ('HERBERT:IX_map:invalid_argument', ...
        'Spectra range start and end arrays must both be numeric scalars or vectors')
end

if ~all_positive_integers(s_beg) || ~all_positive_integers(s_end)
    error ('HERBERT:IX_map:invalid_argument', ...
        'Start and end of spectra range(s) must all be >= 1')
end

if numel(s_beg)~=numel(s_end)
    error ('HERBERT:IX_map:invalid_argument', ['The spectra range start and end ',...
        'arrays must both have the same number of elements'])
end

% Check step is valid, and scalar or same number of elements as s_beg and
% s_end
Nschema = numel(s_beg);
if nargin==3
    % Check spectra grouping
    if ~isnumeric(step) || ~isvector(step) || ~any(numel(step)==[1,Nschema])
        error ('HERBERT:IX_map:invalid_argument', ['Step size(s) must be a numeric ',...
            'scalar or vector with length equal to number of mapping schema'])
    end
    % Check numeric validity
    if ~all_nonzero_integers(step)
        error ('HERBERT:IX_map:invalid_argument', 'Step size(s) must be non-zero integer(s)')
    end
    % Expand value to vector if necessary
    if numel(step)==1 && Nschema>1
        ngroup = repmat(step, Nschema, 1);
    else
        ngroup = step(:);
    end
    
else
    % Set default step of +1
    ngroup = ones(size(s_beg));
end

% Sign of increment in w: +1 or -1 in w, (w + wkno_dcn), w + (2*wkno_dcn), ...
wkno_dcn = sign(ngroup);

% Get increment for spectra in s_beg:s_dcn:s_end
s_dcn = sign(s_end - s_beg);
s_dcn(s_dcn==0) = 1;    % catch case of s_beg==s_end

% Get spectrum grouping - absolute value
ngroup = abs(ngroup);

end


%-------------------------------------------------------------------------------
function wkno_beg = parse_initial_workspace_numbers (wkno_beg_in, Nschema)
% Parse initial workspace numbers for spectra-to-workspace mapping schemas
%
%   >> wkno_beg = parse_initial_workspace_numbers (wkno_beg_in, Nschema)
%
% Input:
% ------
%   wkno_beg_in Values to parse: scalar or vector with length matching the 
%               number of mapping schemas, Nschema.
%               The elements of wkno_beg_in are integers >= 1 or NaNs. NaN mean
%               'whatever workspace number immediately follows largest workspace
%               number defined bythe previous schema'
%   Nschema     Number of schemas. Assumed that Nschema>=1
%
% Output:
% -------
%   wkno_beg    Initial workspace number for each spectra block
%               If the first element of wkno_beg was NaN, it is set to 1 on
%               output. (Column vector length Nschema)


% Check validity of workspace number(s)
if ~isnumeric(wkno_beg_in) || ~isvector(wkno_beg_in) || ...
        ~any(numel(wkno_beg_in)==[1,Nschema])
    if Nschema==1     % single row only permitted
        error ('HERBERT:IX_map:invalid_argument', ...
            'Workspace number must be a scalar')
    else
        error ('HERBERT:IX_map:invalid_argument', ['Workspace number(s) must be a ',...
            'scalar or vector with length of initial spectrum numbers array'])
    end
end

if ~all_positive_integers_or_nan(wkno_beg_in)
    error ('HERBERT:IX_map:invalid_argument', ...
            'Workspace number(s) must be integer(s) >=0 or NaN(s)')
end


% Expand to vector if necessary
if numel(wkno_beg_in)==1 && Nschema>1
    wkno_beg = repmat(wkno_beg_in, Nschema, 1);
else
    wkno_beg = wkno_beg_in(:);
end

if isnan(wkno_beg(1))
    wkno_beg(1) = 1;  % ensure that the first workspace is +1
end

end


%-------------------------------------------------------------------------------
function [nrepeat, delta_s, delta_wkno] = parse_repeat_pars (repeat_pars, Nschema)
% Parse 'repeat' option, if present
%
%   >> [nrepeat, delta_s, delta_wkno] = parse_repeat_pars (repeat_pars, Nschema)
%
% Returns column vectors with the number of repeats of of a block of spectra,
% together with the offsets of the initial spectra and workspace numbers, for
% one or more spectrum-to-workspace mapping schemas. If the input corresponds to
% a single block repeat entry, the output arguments are expanded in size to
% match the number of mapping schemas, Nschema.
%
% Input:
% ------
%   repeat_pars Value to parse: 1x3 or Nx3 array (N defined below)
%               Has the form:
%                   [nrepeat, delta_s, delta_wkno]
%               where for a single repeat block nrepeat, delta_s and delta_wkno
%               are scalars, or for N repeat blocks they can be scalars or 
%               column vectors length N.
%
%   Nschema     Number of smapping schemas (assumed Nschema >= 1)
%               If repeat_pars is a row vector, it will be expanded to Nschema
%               rows.
%
% Output:
% -------
%   nrepeat     Number(s) of times to repeat spectra block - all integers >=1
%              (Column vector length Nschema)
%   delta_s     Spectrum number offset between repeats of spectra block
%              (Column vector length Nschema)
%   delta_wkno  Workspace number offset between repeats of spectra block
%              (Column vector length Nschema)


% Check validity of input
if ~isnumeric(repeat_pars) || ~ismatrix(repeat_pars) || ...
        ~any(size(repeat_pars,1)==[1,Nschema]) || ~size(repeat_pars,2)==3
    if Nschema==1     % single row only permitted
        error ('HERBERT:IX_map:invalid_argument', 'Block repeat data must by a 1x3 vector')
    else
        error ('HERBERT:IX_map:invalid_argument', ['Block repeat data must by a 1x3 ',...
            'vector or Nx3 array (N is length of initial spectrum number array'])
    end
end

if ~all_positive_integers(repeat_pars(:,1))
    error ('HERBERT:IX_map:invalid_argument', 'Value(s) of block repeats must be >= 1')
end

if ~all_integers(repeat_pars(:,2))
    error ('HERBERT:IX_map:invalid_argument', 'Spectrum offset(s) must be integer(s)')
end

if ~all_integers_or_nan(repeat_pars(:,3))
    error ('HERBERT:IX_map:invalid_argument', ...
            'Workspace offset(s) must be integer(s) or NaN(s)')
end

% Expand to expected number of repeat blocks if necessary
if size(repeat_pars,1)==1 && Nschema>1
    repeat_pars = repmat(repeat_pars, Nschema, 1);
end
nrepeat = repeat_pars(:,1);
delta_s = repeat_pars(:,2);
delta_wkno = repeat_pars(:,3);

end


%-------------------------------------------------------------------------------
function ok = all_positive_integers (iarr)
% Check that all elements of an array are integers >=1
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:) | iarr(:)<1);
end


%-------------------------------------------------------------------------------
function ok = all_nonzero_integers (iarr)
% Check that all elements of an array are integers ~= 0
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:) | iarr(:)==0);
end


%-------------------------------------------------------------------------------
function ok = all_positive_integers_or_nan (iarr)
% Check that all elements of an array are integers >=1 or NaN
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    all(isnan(iarr(:)) | (isfinite(iarr(:)) & round(iarr(:))==iarr(:) & iarr(:)>0));
end


%-------------------------------------------------------------------------------
function ok = all_integers_or_nan (iarr)
% Check that all elements of an array are integers or NaN
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    all(isnan(iarr(:)) | (isfinite(iarr(:)) & round(iarr(:))==iarr(:)));
end


%-------------------------------------------------------------------------------
function ok = all_integers_ge_zero (iarr)
% Check that all elements of an array are integers >=0
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:) | iarr(:)<0);
end


%-------------------------------------------------------------------------------
function ok = all_integers (iarr)
% Check that all elements of an array are integers or NaN
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:));
end

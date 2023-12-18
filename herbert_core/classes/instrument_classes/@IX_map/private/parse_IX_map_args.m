function [is, iw] = parse_IX_map_args (varargin)
% Parse the input arguments to the IX_map constructor
%
%   >> [is, iw] = parse_IX_map_args (varargin)
%
% Input:
% ------
% Single spectrum to single workspace, or one-to-one mapping of spectra
% to workspaces:
%   >> w = IX_map (isp)         % single spectrum to workspace 1
%   >> w = IX_map (isp_array)   % general case of array of spectra
%   >> w = IX_map (isp_array, 'wkno', iw_array)
%                               % if iw_array is scalar, all spectra
%                               % are mapped into that wokspace
%
% Groups of contiguous spectra to contiguous workspace numbers:
%   >> w = IX_map (isp_beg, isp_end)        % one spectrum per workspace
%   >> w = IX_map (isp_beg, isp_end, step)  % |step| spectra per workspace
%   >> w = IX_map (..., 'wkno', iw_beg)     % Mapped into succesive workspaces starting
%                                           % at iw_beg, ascending or descending
%                                           % according as the sign of step
%
% With either of the two cases above, the mapping can be repeated multiple times
% with successive increments of the spectra and workspace number for each repeat
% of the block:
%   >> ... = parse_IX_map_args (..., 'repeat', [nrepeat, delta_isp, delta_iw])
%
%
% Output:
% -------
%   is          Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Column vector.
%
%   iw          Workspace numbers for each of the spectra. Column vector (same
%               length as is)


npar_req = 1;
npar_opt = 2;
keyval_def = struct('wkno', NaN, 'repeat', [1,0,0]);    % default: no repeat
[par, keyval, present, ~, ok, mess] = parse_arguments ...
    (varargin, npar_req, npar_opt, keyval_def);

if ~ok
    error ('IX_map:invalid_argument', mess)
end

% Determine if IX_map(isp_beg, isp_end,...) or IX_map (isp_array,...) input
% and optional 'wkno', if present.

if numel(par)==1
    % Must be IX_map (isp_array,...) or IX_map (isp_array, 'wkno', iw_array)
    
    % Check isp_array
    isp_array = par{1}(:);
    if ~all_positive_integers (isp_array)
        error ('IX_map:invalid_argument', 'Spectrum numbers must all be >= 1')
    end
    
    % Check iw_array is valid and consistent with isp_array, if present;
    % otherwise create default
    if ~present.wkno
        iw_array = (1:numel(isp_array))';
    else
        iw_array = keyval.wkno(:);
        if all_positive_integers (iw_array)
            try
                iw_array = expand_args_by_ref (isp_array, iw_array);
            catch
                error ('IX_map:invalid_argument', ['Workspace array must be ',...
                    'scalar or have same length as spectrum array'])
            end
        else
            error ('IX_map:invalid_argument', 'Workspace numbers must all be >= 1')
        end
    end

    % Parse 'repeat' option
    repeat_pars = keyval.repeat;
    [nrepeat, delta_sp, delta_w] = parse_repeat_pars (repeat_pars, 1);
    
    % Output full spectra and workspace numbers lists
    [is, iw] = repeat_s_w_arrays (isp_array, iw_array, nrepeat, delta_sp, delta_w);
    
else
    % Must be  IX_map(isp_beg, isp_end [, step]) or
    % IX_map(isp_beg, isp_end [, step], 'wkno', iw_beg)
    
    % Parse the grouping of spectra and check that it is valid
    [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectrum_grouping (par{:});
    Nschema = numel(isp_beg);   % number of spectra-to-workspace mapping schemas
    
    % Check iw is valid and consistent with isp_beg and isp_end
    % Otherwise create default
    if ~present.wkno
        iw_beg = parse_initial_workspace_numbers (NaN, Nschema);
    else
        iw_beg_in = keyval.wkno;
        iw_beg = parse_initial_workspace_numbers (iw_beg_in, Nschema);
    end
    
    % Parse 'repeat' option
    repeat_pars = keyval.repeat;
    [nrepeat, delta_sp, delta_w] = parse_repeat_pars (repeat_pars, Nschema);
    
    % Output full spectra and workspace numbers lists
    [is, iw] = repeat_s_w_blocks (isp_beg, isp_end, ...
        ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
end

end

    
%-------------------------------------------------------------------------------
function [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectrum_grouping ...
    (isp_beg_in, isp_end_in, step)
% Parse spectrum grouping for set of spectrum-to-workspace schemas
%
%   >> [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectrum_grouping ...
%                                               (isp_beg_in, isp_end_in, step)
%
% Input arguments can be scalars (one schema), or vectors (multiple schema)
%
% Input:
% ------
%   isp_beg_in      Starting spectrum numbers for each schema (vector; one
%                  element per schema)
%   isp_end_in      Final spectrum numbers for each schema (vector; one
%                  element per schema)
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
%                   isp_beg_in
%
% Output:
% -------
%   isp_beg         Starting spectrum numbers for each schema (column vector)
%   isp_end         Final spectrum numbers for each schema (column vectors)
%   ngroup          Spectrum group sizes for each schema (Column vector)
%                   Elements are greater or equal to 1.
%                   Default if step not given: 1 (i.e. one-to-one to workspaces)
%   isp_dcn         +/-1 indicating spectrum numbers increment (+1) or decrement
%                   (-1) from isp_beg (Column vector).
%                   If isp_beg(i) == isp_end(i) then = +1) 
%   iw_dcn          +/-1 indicate workspace numbers increment (+1) or decrement
%                   (-1) from the starting value for the schema (Column vector).
%                   Default if step not given: +1 for each group


% Check isp_beg and isp_end are valid and have same number of elements
if isnumeric(isp_beg_in) && isnumeric (isp_end_in) && isvector(isp_beg_in) ...
        && isvector(isp_end_in)
    % Make column vectors (could have been rows)
    isp_beg = isp_beg_in(:);
    isp_end = isp_end_in(:);
else
    error ('IX_map:invalid_argument', ...
        'Spectra range start and end arrays must both be numeric scalars or vectors')
end

if ~all_positive_integers (isp_beg) || ~all_positive_integers (isp_end)
    error ('IX_map:invalid_argument', ...
        'Start and end of spectra range(s) must all be >= 1')
end

if numel(isp_beg)~=numel(isp_end)
    error ('IX_map:invalid_argument', ['The spectra range start and end ',...
        'arrays must both have the same number of elements'])
end

% Check step is valid, and scalar or same number of elements as is_beg and
% isp_end
Nschema = numel(isp_beg);
if nargin==3
    % Check spectra grouping
    if ~isnumeric(step) || ~isvector(step) || ~any(numel(step)==[1,Nschema])
        error ('IX_map:invalid_argument', ['Step size(s) must be a numeric ',...
            'scalar or vector with length equal to number of mapping schema'])
    end
    % Check numeric validity
    if ~all_nonzero_integers (step)
        error ('IX_map:invalid_argument', 'Step size(s) must be non-zero integer(s)')
    end
    % Expand value to vector if necessary
    if numel(step)==1 && Nschema>1
        ngroup = repmat(step, Nschema, 1);
    else
        ngroup = step(:);
    end
    
else
    % Set default step of +1
    ngroup = ones(size(isp_beg));
end

% Sign of increment in iw: +1 or -1 in iw, (iw + iw_dcn), iw + (2*iw_dcn), ...
iw_dcn = sign(ngroup);

% Get increment for spectra in isp_beg:isp_dcn:isp_end
isp_dcn = sign(isp_end - isp_beg);
isp_dcn(isp_dcn==0) = 1;    % catch case of isp_beg==isp_end

% Get spectrum grouping - absolute value
ngroup = abs(ngroup);

end


%-------------------------------------------------------------------------------
function iw_beg = parse_initial_workspace_numbers (iw_beg_in, Nschema)
% Parse initial workspace numbers for spectra-to-workspace mapping schemas
%
%   >> iw_beg = parse_initial_workspace_numbers (iw_beg_in, Nschema)
%
% Input:
% ------
%   iw_beg_in   Values to parse: scalar or vecmapping schemas
%              - Elements are integers >= 1 or NaNs. NaN mean 'whatever workspace
%              number immediately follows largest workspace number defined by
%              the previous schema'
%   Nschema     Number of schemas. Assumed that Nschema>=1
%
% Output:
% -------
%   iw_beg      Initial workspace number for each spectra block
%              If first element is NaN, set to 1 (Column vector length Nschema)


% Check validity of workspace number(s)
if ~isnumeric(iw_beg_in) || ~isvector(iw_beg_in) || ~any(numel(iw_beg_in)==[1,Nschema])
    if Nschema==1     % single row only permitted
        error ('IX_map:invalid_argument', ...
            'Workspace number must be a scalar')
    else
        error ('IX_map:invalid_argument', ['Workspace number(s) must be a ',...
            'scalar or vector with length of initial spectrum numbers array'])
    end
end

if ~all_positive_integers_or_nan (iw_beg_in)
    error ('IX_map:invalid_argument', ...
            'Workspace number(s) must be integer(s) >=0 or NaN(s)')
end


% Expand to vector if necessary
if numel(iw_beg_in)==1 && Nschema>1
    iw_beg = repmat(iw_beg_in, Nschema, 1);
else
    iw_beg = iw_beg_in(:);
end

if isnan(iw_beg(1))
    iw_beg(1) = 1;  % ensure that the first workspace is +1
end

end


%-------------------------------------------------------------------------------
function [nrepeat, delta_sp, delta_w] = parse_repeat_pars (repeat_pars, Nschema)
% Parse 'repeat' option, if present
%
%   >> [nrepeat, delta_sp, delta_w] = parse_repeat_pars (repeat_pars, Nschema)
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
%                   [nrepeat, delta_isp, delta_iw]
%               where for a single repeat block nrepeat, delta_isp and delta_iw
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
%   delta_sp    Spectrum number offset between repeats of spectra block
%              (Column vector length Nschema)
%   delta_w     Workspace number offset between repeats of spectra block
%              (Column vector length Nschema)


% Check validity of input
if ~isnumeric(repeat_pars) || ~ismatrix(repeat_pars) || ...
        ~any(size(repeat_pars,1)==[1,Nschema]) || ~size(repeat_pars,2)==3
    if Nschema==1     % single row only permitted
        error ('IX_map:invalid_argument', 'Block repeat data must by a 1x3 vector')
    else
        error ('IX_map:invalid_argument', ['Block repeat data must by a 1x3 ',...
            'vector or Nx3 array (N is length of initial spectrum number array'])
    end
end

if ~all_positive_integers (repeat_pars(:,1))
    error ('IX_map:invalid_argument', 'Value(s) of block repeats must be >= 1')
end

if ~all_integers (repeat_pars(:,2))
    error ('IX_map:invalid_argument', 'Spectrum offset(s) must be integer(s)')
end

if ~all_integers_or_nan (repeat_pars(:,3))
    error ('IX_map:invalid_argument', ...
            'Workspace offset(s) must be integer(s) or NaN(s)')
end

% Expand to expected number of repeat blocks if necessary
if size(repeat_pars,1)==1 && Nschema>1
    repeat_pars = repmat(repeat_pars, Nschema, 1);
end
nrepeat = repeat_pars(:,1);
delta_sp = repeat_pars(:,2);
delta_w = repeat_pars(:,3);

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
function ok = all_integers (iarr)
% Check that all elements of an array are integers or NaN
ok = isnumeric(iarr) && numel(iarr)>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:));
end

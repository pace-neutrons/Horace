function [is, iw, ns, wkno, unique_map, unique_spec] = parse_IX_map_args (varargin)
% Parse the input arguments to the IX_map constructor
%
%   >> [is, iw, ns, wkno, unique_map, unique_spec] = parse_IX_map_args (varargin)
%
% where the various possible inputs are:
%
% Single spectrum or array of spectra:
%   >> ... = parse_IX_map_args (isp)         % single spectraum
%   >> ... = parse_IX_map_args (isp_array)   % general case of array of spectra
%   >> ... = parse_IX_map_args (isp_array, 'wkno', iw_array)
%
% Block of contiguous spectra to contiguous workspaces:
%   >> ... = parse_IX_map_args (isp_beg, isp_end)
%   >> ... = parse_IX_map_args (isp_beg, isp_end, step)
%   >> ... = parse_IX_map_args (..., 'wkno', iw)
%
% Either of the two cases above:
%   >> ... = parse_IX_map_args (..., 'repeat', [nrepeat, delta_isp, delta_iw])
%
%
% Output:
% -------
%   is          Spectrum numbers sorted by workspace number, and within each
%               workspace number by spectrum number. Column vector.
%
%   iw          Workspace numbers for each of the spectra. Column vector (same
%               length as is_sort)
%
%   ns          Number of spectra in each workspace. Column vector.
%
%   wkno        Unique workspace numbers. Column vector.
%
%   unique_map  True if there were no repeated is-to-iw entries; else false
%
%   unique_spec True if a spectrum is mapped to only one workspace; else false


npar_req = 1;
npar_opt = 2;
keyval_def = struct('wkno', NaN, 'repeat', [1,0,0]);
[par, keyval, present, ~, ok, mess] = parse_arguments ...
    (varargin, npar_req, npar_opt, keyval_def);

if ~ok
    error ('IX_map:invalid_argument', mess)
end

% Determine if IX_map(isp_beg, isp_end,...) or IX_map (isp_array,...) input
% and optional 'wkno', if present.

if numel(par)==1
    % Must be IX_map (isp_array) or IX_map (isp_array, 'wkno', iw_array)
    
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
    [nrepeat, delta_sp, delta_w] = parse_repeat (keyval.repeat, 1);
    
    % Output full spectra and workspace numbers lists
    [is, iw] = repeat_s_w_arrays (isp_array, iw_array, nrepeat, delta_sp, delta_w);
    
else
    % Must be  IX_map(isp_beg, isp_end [, step]) or IX_map(isp_beg, isp_end ...
    % [, step], 'wkno', iw)
    
    [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectra_ranges (par{:});
    
      
    % Check iw is valid and consistent with isp_beg and isp_end
    % Otherwise create default
    iw_beg = parse_initial_workspace_numbers (val, N);
    
    % Parse 'repeat' option
    [nrepeat, delta_sp, delta_w] = parse_repeat (keyval.repeat, numel(isp_beg));
    
    % Output full spectra and workspace numbers lists
    [is, iw] = repeat_s_w_blocks_multi (isp_beg, isp_end, ...
        ngroup, isp_dcn, iw_beg, iw_dcn, nrepeat, delta_sp, delta_w);
end

% Sort spectra and
[is, iw, ns, wkno, unique_map, unique_spec] = sort_s_w (is, iw);


end

    
%-------------------------------------------------------------------------------
function [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectra_ranges ...
    (isp_beg_in, isp_end_in, step)
% Parse spectra block ranges 
%
%   >> [isp_beg, isp_end, ngroup, isp_dcn, iw_dcn] = parse_spectra_ranges ...
%                                               (isp_beg_in, isp_end_in, step)
%
% Input:
% ------
%   isp_beg_in      Starting spectrum numbers for each block
%   isp_end_in      Final spectrum numbers for each block
% 
% Optionally:
%   step            Grouping and workspace increment sign (all elements ~=0)
%                   - group ith block of spectra in groups size |step(i)| (last
%                     group will be remainder if less than |step(i)| spectra
%                     left)
%                   - workspace numbers increase by +1 or -1 according to sign
%                     of step(i)
%                   Default: 1
%
% Output:
% -------
%   isp_beg         Staering spectrum numbers (column vector)
%   isp_end         Final spectrum numbers (column vectors)
%   ngroup          Group sizes of each block (Column vector)
%                   Default if step not given: +1 for 
%   isp_dcn         +/-1 indicating incrementing or decrementing; if isp_beg(i)
%                   == isp_end(i) then = +1) (Column vector)
%   iw_dcn          +/-1 according as sign(step) (Column vector)
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
N = numel(isp_beg);
if nargin==3
    % Check spectra grouping
    if ~isnumeric(step) || ~isvector(step) || ~any(numel(step)==[1,N])
        error ('IX_map:invalid_argument', ['Step size(s) must be a numeric ',...
            'scalar or vector with length equal to number of spectra blocks'])
    end
    % Check numeric validity
    if ~all_nonzero_integers (step)
        error ('IX_map:invalid_argument', 'Step size(s) must be non-zero integer(s)')
    end
    % Expand value to vector if necessary
    if numel(step)==1 && N>1
        ngroup = repmat(step, N, 1);
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

% Get spectrum group - absolute value
ngroup = abs(ngroup);

end


%-------------------------------------------------------------------------------
function iw_beg = parse_initial_workspace_numbers (val, N)
% Parse initial workspace number(s) for a spectra block range(s)
%
%   >> iw = parse_initial_workspace_numbers (val, N)
%
% Input:
% ------
%   val         Value to parse: scalar or vector length N (N defined below)
%              - If scalar, will apply to all spectra block definitions
%              - Elements are integers >= 1 or NaNs. NaN mean 'whatever workspace
%              number immediately follows largest workspace number in previous
%              block and its repeats'
%   N           Number of spectra block definitions. Assumed that N>=1
%
% Output:
% -------
%   iw_beg      Initial workspace number for each spectra block
%              If first element is NaN, set to 1 (Column vector length N)


% Check validity of workspace number(s)
if ~isnumeric(val) || ~isvector(val) || ~any(numel(val)==[1,N])
    if N==1     % single row only permitted
        error ('IX_map:invalid_argument', ...
            'Workspace number must be a scalar')
    else
        error ('IX_map:invalid_argument', ['Workspace number(s) must be a ',...
            'scalar or vector with length of initial spectrum numbers array'])
    end
end

if ~all_positive_integers_or_nan (val)
    error ('IX_map:invalid_argument', ...
            'Workspace number(s) must be integer(s) >=0 or NaN(s)')
end


% Expand to vector if necessary
if numel(val)==1 && N>1
    iw_beg = repmat(val, N, 1);
else
    iw_beg = val(:);
end

if isnan(iw_beg(1))
    iw_beg(1) = 1;  % ensure that the first workspace is +1
end

end


%-------------------------------------------------------------------------------
function [nrepeat, delta_sp, delta_w] = parse_repeat (val, N)
% Parse 'repeat' option, if present
%
%   >> [nrepeat, delta_sp, delta_w] = parse_repeat (val, N)
%
% Returns column vectors with the number of repeats of blocks of spectra,
% together with the offsets of the initial spectra and workspace numbers. If
% the input corresponds to a single repeat entry, the output arguments are
% expanded in size to match the number of spectra blocks, N.
%
% Input:
% ------
%   val         Value to parse: 1x3 or Nx3 array (N defined below)
%   N           Number of spectra block definitions. Assumed that N>=1
%
% Output:
% -------
%   nrepeat     Number(s) of times to repeat spectra block - all integers >=1
%              (Column vector length N)
%   delta_sp    Spectrum number offset between repeats of spectra block
%              (Column vector length N)
%   delta_w     Workspace number offset between repeats of spectra block
%              (Column vector length N)


% Check validity of input
if ~isnumeric(val) || ~ismatrix(val) || ~any(size(val,1)==[1,N]) || ~size(val,2)==3
    if N==1     % single row only permitted
        error ('IX_map:invalid_argument', 'Block repeat data must by a 1x3 vector')
    else
        error ('IX_map:invalid_argument', ['Block repeat data must by a 1x3 ',...
            'vector or Nx3 array (N is length of initial spectrum number array'])
    end
end

if ~all_positive_integers (val(:,1))
    error ('IX_map:invalid_argument', 'Value(s) of block repeats must be >= 1')
end

if ~all_nonzero_integers (val(:,2))
    error ('IX_map:invalid_argument', 'Spectrum offset(s) must be integer(s)')
end

if ~all_integers_or_nan (val)
    error ('IX_map:invalid_argument', ...
            'Workspace offset(s) must be integer(s) or NaN(s)')
end

% Expand to number of blocks if necessary
if size(val,1)==1 && N>1
    val = repmat(val, N, 1);
end
nrepeat = val(:,1);
delta_sp = val(:,2);
delta_w = val(:,3);

end


%-------------------------------------------------------------------------------
function ok = all_positive_integers (iarr)
% Check that all elements of an array are integers >=1
ok = isnumeric(iarr(:)) && numel(iarr(:))>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:) | iarr(:)<1);
end


%-------------------------------------------------------------------------------
function ok = all_nonzero_integers (iarr)
% Check that all elements of an array are integers ~= 0
ok = isnumeric(iarr(:)) && numel(iarr(:))>0 && ...
    ~any(~isfinite(iarr(:)) | round(iarr(:))~=iarr(:) | iarr(:)==0);
end


%-------------------------------------------------------------------------------
function ok = all_positive_integers_or_nan (iarr)
% Check that all elements of an array are integers >=1 or NaN
ok = isnumeric(iarr(:)) && numel(iarr(:))>0 && ...
    all(isnan(iarr(:)) | (isfinite(iarr(:)) & round(iarr(:))==iarr(:) & iarr(:)>0));
end


%-------------------------------------------------------------------------------
function ok = all_integers_or_nan (iarr)
% Check that all elements of an array are integers or NaN
ok = isnumeric(iarr(:)) && numel(iarr(:))>0 && ...
    all(isnan(iarr(:)) | (isfinite(iarr(:)) & round(iarr(:))==iarr(:)));
end

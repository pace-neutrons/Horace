function parse_IX_map_args (varargin)

%   >> w = IX_map(isp)
%   >> w = IX_map(isp, 'wkno', iw)
%
%   >> w = IX_map(isp_beg, isp_end)
%   >> w = IX_map(isp_beg, isp_end, 'wkno', iw)
%
%   >> w = IX_map(isp_beg, isp_end, nstep)
%   >> w = IX_map(isp_beg, isp_end, nstep, 'wkno', iw)
%
%   >> w = IX_map (isp_array, 'wkno', iw_array)
%
% -------------------------------------------------------------------------
%   >> w = IX_map(..., 'repeat', [nrepeat, delta_isp, delta_iw])

npar_req = 1;
npar_opt = 2;
keyval_def = struct('wkno', [], 'repeat', [1,0,0]);
[par, keyval, present] = parse_arguments (varargin, keyval_def);

% Determine if IX_map(isp_beg, isp_end,...) or IX_map (isp_array,...) input
if numel(par)==1
    % Must be isp_array
    isp_array = par{1};
    if ~all_positive_integers(isp_array)
        error ('IX_map:invalid_argument', 'Spectrum numbers must all be >=1')
    end
    if ~present.wkno
        wkno_array = 1:numel(isp_array);
    elseif all_positive_integers(wkno_array)
        wkno_array = keyval.wkno;
    else
        error ('IX_map:invalid_argument', 'Workspace numbers must all be >=1')
    end
end

end


%--------------------------------------------------------------------------
function ok = all_positive_integers (iarr)
% Check that all elements of an array are integers >=1
if numel(iarr)==1
    ok = ~(~isfinite(iarr) || rem(iarr,1)~=0 || iarr<1);
else
    ok = ~(~all(isfinite(iarr(:))) || any(rem(iarr(:),1)~=0) || any(iarr(:)<1));
end

end

%--------------------------------------------------------------------------
function ok = all_nonzero_integers (iarr)
% Check that all elements of an array are integers ~= 0
if numel(iarr)==1
    ok = ~(~isfinite(iarr) || rem(iarr,1)~=0 || iarr==0);
else
    ok = ~(~all(isfinite(iarr(:))) || any(rem(iarr(:),1)~=0) || any(iarr(:)==1));
end

end

%--------------------------------------------------------------------------
function ok = all_integer_or_nan (iarr)
% Check that all elements of an array are integers or are NaN
if numel(iarr)==1
    ok = isnan(iarr) || ~(~isfinite(iarr) || rem(iarr,1)~=0);
else
    ok = all(isnan(iarr(:)) | ~(~isfinite(iarr(:)) | rem(iarr(:),1)~=0));
end

end

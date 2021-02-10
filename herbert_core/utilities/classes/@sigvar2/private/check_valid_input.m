function [signal_, variance_, mask_] = check_valid_input (s, e, msk)
% Return valid arguments

% Check input types
%------------------
mess = '';
if ~isnumeric(s)
    mess = 'Signal array must be numeric';
elseif ~isnumeric(e)
    mess = 'Variance array must be numeric';
elseif ~(isnumeric(msk) || islogical(msk))
    mess = 'Mask array must be numeric or logical array';
end
if ~isempty(mess)
    ME = MException('sigvar:invalid_argument',mess);
    throwAsCaller(ME)
end

% Check consistency of input
%---------------------------
% Determine if sizes are consistent:
%
% The input variance and mask arrays must have the same size as the signal
% array, except in the case of non-empty signal when they can be scalar or
% have size == [0,0]
%
% Recall the requirement for the output hidden internal variance and mask arrays:
% - Variance array:
%   - An array same size as signal array (all elements >=0 or NaN)
%   - If all variances are zero, then = [] (to save memory)
%
% - Mask array:
%   - Logical array same size as signal array (0 = mask, 1 = retain)
%   - If all elements are retained then = [] (to save memory)

signal_ = s;

% Check variance array
[ok, null, scalar] = signal_size (size(s), size(e));
mess = '';
if ok
    if null
        variance_ = [];
    elseif scalar
        if e<0
            mess = 'Variance cannot be less than zero';
        else
            variance_ = e*ones(size(s));
        end
    else
        if any(e<0)
            mess = 'No variance array element can be less than zero';
        else
            variance_ = e;
        end
    end
else
    mess = 'Signal and variance array sizes are inconsistent';
end
if ~isempty(mess)
    ME = MException('sigvar:invalid_argument',mess);
    throwAsCaller(ME)
end

% Check mask array
[ok, null, scalar] = signal_size (size(s), size(msk));
mess = '';
if ok
    if null
        mask_ = [];
    elseif scalar
        if isnumeric(msk)
            if isnan(msk)
                mask_ = false;  % ensure NaN interpreted as false
            else
                if logical(msk)
                    mask_ = [];
                else
                    mask_ = false(size(s));
                end
            end
        else
            if msk
                mask_ = [];
            else
                mask_ = false(size(s));
            end
        end
    else
        if isnumeric(msk)
            if any(isnan(msk(:)))
                msk(isnan(msk)) = false;    % ensure NaN interpreted as false
            end
            mask_ = logical(msk);
        else
            mask_ = msk;
        end
        if all(mask_(:))
            mask_ = [];
        end
    end
else
    mess = 'Signal and mask array sizes are inconsistent';
end
if ~isempty(mess)
    ME = MException('sigvar:invalid_argument',mess);
    throwAsCaller(ME)
end


%--------------------------------------------------------------------------
function [ok, null, scalar] = signal_size (sz_s, sz)
% The input variance and mask arrays must have the same size as the signal
% array, except in the case of non-empty signal when they can be scalar or
% have size == [0,0]
%
% Input:
% ------
%   sz_s    Signal array size
%   sz      Size of test array
%
% Output:
% -------
%   ok      sz is consistent with sz_s
%   null    true if sz == [0,0]
%   scalar  true if sz == [1,1]

same = (numel(sz)==numel(sz_s) && all(sz==sz_s));
null = (numel(sz)==2 && all(sz==0));
scalar = (numel(sz)==2 && all(sz==1));
if prod(sz_s)~=0
    ok = (same || null || scalar);
else
    ok = same;
end

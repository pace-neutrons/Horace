function [signal_, variance_, mask_] = check_valid_input (s, e, msk)
% Return valid arrays for the variance and mask arrays
%
%   >> [signal_, variance_, mask_] = check_valid_input (s, e, msk)
%
% Throws an error as if from caller if there is a problem
%
% Input
% -----
%   s       Signal array (must be numeric)
%
%   e       Variance array (numeric, all elements >=0 or NaN)
%           - empty (which will be interpreted as variance == 0), OR
%           - same size as signal array, OR
%           - scalar (if non-empty signal)
%
%   msk     Mask array (numeric or logical, 0 = mask, 1 = retain)
%           - empty (which will be interpreted as mask == true), OR
%           - same size as signal array, OR
%           - scalar (if non-empty signal)
%           Note: numeric NaN is interpreted as false
%
% Output:
% -------
%   signal_     Signal array (will be unchanged if no errors)
%
%   variance_   Variance array (numeric, all elements >=0 or NaN)
%               - same size as signal array, OR
%               - =[] if all elements are zero (to save memory)
%
%   mask_       Mask array (numeric or logical, 0 = mask, 1 = retain)
%               - logical array same size as signal array, OR
%               - =[] if all elements are true (to save memory)


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
signal_ = s;

% Check variance array
mess = '';
if isempty(e)
    variance_ = [];
elseif ~isempty(s) && isscalar(e)
    if e<0
        mess = 'Variance cannot be less than zero';
    else
        variance_ = e*ones(size(s));
    end
elseif isequal(size(s), size(e))
    if any(e<0)
        mess = 'No variance array element can be less than zero';
    else
        variance_ = e;
    end
else
    mess = 'Signal and variance array sizes are inconsistent';
end
if ~isempty(mess)
    ME = MException('sigvar:invalid_argument',mess);
    throwAsCaller(ME)
end

% Check mask array
mess = '';
if isempty(msk)
    mask_ = [];
elseif ~isempty(s) && isscalar(msk)
    if isnumeric(msk)
        if isnan(msk)
            mask_ = false;  % ensure NaN interpreted as false
        else
            if logical(msk)     % if converted to true
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
elseif isequal(size(s), size(e))
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
else
    mess = 'Signal and mask array sizes are inconsistent';
end
if ~isempty(mess)
    ME = MException('sigvar:invalid_argument',mess);
    throwAsCaller(ME)
end

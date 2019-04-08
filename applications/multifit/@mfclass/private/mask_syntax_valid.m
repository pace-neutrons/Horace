function [ok, mess, xkeep, xremove, msk] = mask_syntax_valid (nd, xkeep_in, xremove_in, msk_in)
% Check that keep, remove and mask options have the correct format
%
%   >> [ok, mess, xkeep, xremove, msk] = mask_syntax_valid (nd, xkeep_in, xremove_in, msk_in)
%
% Does not check if the masking options are consistent with the dimensionality
% of any data - that information is not provided as should be done elsewhere
%
% Input:
% ------
%   nd          Number of data sets
%   xkeep_in    Array giving ranges along each x-axis to retain for fitting. 
%               - General case of n-dimensions: 
%                   [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi] 
%               - More than one range to keep can be specified in additional rows: 
%                   [Range_1; Range_2; Range_3;...; Range_m] 
%               where each of the ranges are given in the format above. 
% 
%           	Applies to all datasets. 
%               Alternatively, give a cell array of arrays, one per data set 
%               If empty, then ignored
% 
%   xremove_in  Ranges to remove from fitting. Follows the same format as 'keep'. 
%               If empty, then ignored
% 
%   msk_in      Array of ones and zeros, indicates which of the data points are
%               to be retained for fitting (1=keep, 0=remove). 
%
%           	Applies to all datasets. 
%               Alternatively, give a cell array of arrays, one per data set 
%               If empty, then ignored
%
% Output:
% -------
%   xkeep       Cell array (row) of keep ranges, one per data set. Empty input
%               for a data set replaced with []
%
%   xremove     Cell array (row) of keep ranges, one per data set. Empty input
%               for a data set replaced with []
%
%   mask        Cell array (row) of mask arrays, one per data set. Empty input
%               for a data set replaced with []
% 
%   ok          True if format OK, false otherwise
%
%   mess        If OK, then ''; else contains error message


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


ok=true;
mess='';

if ~isempty(xkeep_in)
    xkeep=xkeep_in;
    if ~iscell(xkeep), xkeep={xkeep}; end  % make a single cell, for later convenience
    if ~(isscalar(xkeep) || numel(xkeep)==nd)
        [xkeep,xremove,msk] = error_output(nd);
        ok=false;
        mess='''keep'' option must provide a single entity defining keep ranges, or a cell array of entities with same number as data sets';
        return
    end
    [ok,xkeep] = check_xformat(xkeep);
    if ~ok
        [xkeep,xremove,msk] = error_output(nd);
        mess='''keep'' option must be numeric array(s) with size [m,2*ndim], where m = number of ranges';
        return
    end
    if isscalar(xkeep)
        xkeep=repmat(xkeep,1,nd);
    end
else
    xkeep=cell(1,nd);       % empty cell array of correct size, for later convenience
end


if ~isempty(xremove_in)
    xremove=xremove_in;
    if ~iscell(xremove), xremove={xremove}; end  % make a single cell, for later convenience
    if ~(isscalar(xremove) || numel(xremove)==nd)
        [xkeep,xremove,msk] = error_output (nd);
        ok=false;
        mess='''remove'' option must provide a single entity defining remove ranges, or a cell array of entities with same number as data sets';
        return
    end
    [ok,xremove] = check_xformat(xremove);
    if ~ok
        [xkeep,xremove,msk] = error_output(nd);
        mess='''remove'' option must be numeric array(s) with size [m,2*ndim], where m = number of ranges';
        return
    end
    if isscalar(xremove)
        xremove=repmat(xremove,1,nd);
    end
else
    xremove=cell(1,nd);     % empty cell array of correct size, for later convenience
end


if ~isempty(msk_in)
    msk=msk_in;
    if ~iscell(msk), msk={msk}; end  % make a single cell, for later convenience
    if ~(isscalar(msk) || numel(msk)==nd)
        [xkeep,xremove,msk] = error_output (nd);
        ok=false;
        mess='''mask'' option must provide a single mask, or a cell array of masks with same number as data sets';
        return
    end
    [ok,msk] = check_mskformat(msk);
    if ~ok
        [xkeep,xremove,msk] = error_output(nd);
        mess='''mask'' option must be logical array(s)';
        return
    end
    if isscalar(msk)
        msk=repmat(msk,1,nd);
    end
else
    msk=cell(cell(1,nd));   % empty cell array of correct size, for later convenience
end

%--------------------------------------------------------------------------------------------------
function [ok,xout] = check_xformat(xin)
% Check that format of a cell array of x values is OK
xout=xin(:)';
empty = cellfun(@isempty,xout);
if any(empty), xout{empty}=[]; end
ok = all(cellfun(@(x)(numel(size(x))==2 && rem(size(x,2),2)==0),xout));

%--------------------------------------------------------------------------------------------------
function [ok,xout] = check_mskformat(xin)
% Check that format of a cell array of masks is OK
xout=xin(:)';
empty = cellfun(@isempty,xout);
if any(empty), xout{empty}=[]; end
ok = all(cellfun(@(x)(isempty(x) || islognum(x)),xout));

%--------------------------------------------------------------------------------------------------
function [xkeep,xremove,mask] = error_output(nd)
xkeep=cell(1,nd);
xremove=cell(1,nd);
mask=cell(1,nd);

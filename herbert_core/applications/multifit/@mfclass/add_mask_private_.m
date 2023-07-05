function [ok, mess, obj] = add_mask_private_ (obj, clear, args)
% Select data points to simulate or fit
%
%   >> [ok, mess, obj] = add_mask_private_ (obj, clear, args)
%
% Set for all datasets:
%   args = {'keep', xkeep, 'remove', xremove, 'mask', mask}
%
% Set for particular datasets:
%   args = {ind, 'keep', xkeep, 'remove', xremove, 'mask', mask}


% Original author: T.G.Perring
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)


% Trivial case of no input arguments; just return without doing anything
if numel(args)==0
    ok = true;
    mess = '';
    return
end

% % Check there is data
% % -------------------
% if isempty(obj.data_)
%     ok = false;
%     mess = 'Cannot set masking before data sets have been set.';
%     return
% end

% Find arguments and optional arguments
% -------------------------------------
keyval_def = struct('keep',[],'remove',[],'mask',[]);
[ind,keyval,~,~,ok,mess] = parse_arguments (args, keyval_def);
if ~ok, error(mess), end
if numel(ind)==0
    ind = {'all'};
elseif numel(ind)>1
    error ('Check number of input arguments')
end

% Check validity of input
% -----------------------
% Get dataset indicies to mask
idata = indices_parse (ind{1}, obj.ndatatot_, 'Dataset');

% Check optional arguments
[ok,mess,xkeep,xremove,msk] = mask_syntax_valid (numel(idata), keyval.keep, keyval.remove, keyval.mask);
if ~ok, error(mess), end

% Create mask arrays
if clear
    [msk_out,ok,mess] = mask_data (obj.w_(idata),[],xkeep,xremove,msk);
else
    [msk_out,ok,mess] = mask_data (obj.w_(idata),obj.msk_(idata),xkeep,xremove,msk);
end
if ok && ~isempty(mess)
    display_message(mess)
elseif ~ok
    error_message(mess)
end

% Update object
% -------------
obj.msk_(idata) = msk_out;

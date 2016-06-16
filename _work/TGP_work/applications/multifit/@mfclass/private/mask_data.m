function [msk_out,ok,mess] = mask_data (w,msk_in,xkeep,xremove,msk)
% Mask data
%
%   >> [msk_out,ok,mess] = mask_data (w,msk_in,xkeep,xremove,msk)
%
% Input:
% ------
%   w           Cell array (row) of datasets
%
%   msk_in      Cell array (row) of current mask arrays, one per dataset.
%               Same size as data.
%               If a mask array is empty, then ignored.
%               If msk_in is empty, then treated as cell(size(w))
%
%   xkeep       Cell array (row) of keep ranges, one per data set. 
%               - General case of n-dimensions: 
%                   [x1_lo, x1_hi, x2_lo, x2_hi,..., xn_lo, xn_hi] 
%               - More than one range to keep can be specified in additional rows: 
%                   [Range_1; Range_2; Range_3;...; Range_m] 
%               where each of the ranges are given in the format above.
%
%               If empty, then ignored.
% 
%   xremove     Cell array (row) of keep ranges, one per data set. 
%               Same syntax as xkeep
%
%   mask        Cell array (row) of mask arrays, one per data set. 
%               Same size as data.
%               If empty, then ignored.
% 
% Output:
% -------
%   msk_out     Cell array (row) of updated mask arrays, one per data set.
%               Same size as data.
%
%   ok          True if all OK, false otherwise
%
%   mess        If  ok, then '' or, if not empty, contains warning message
%               If ~ok, then contains error message
%
% Objects need a method sigvar_getx or mask_points. See elsewhere for required syntax.


if isempty(msk_in), msk_in=cell(size(w)); end
sz=size(w);
msk_out = cell(size(w));
mess='';

for i=1:numel(w)
    if isstruct(w{i})    % xye triple
        [msk_out{i},ok,mess_tmp]=mask_points_xye(w{i}.x,xkeep{i},xremove{i},msk{i});
    else % a different data object
        if ismethod(w{i},'mask_points')
            [msk_out{i},ok,mess_tmp]=mask_points(w{i},'keep',xkeep{i},'remove',xremove{i},'mask',msk{i});
        else
            x=sigvar_getx(w{i});
            if ~iscell(x),x={x}; end    % if a single array, make a cell array length unity
            [msk_out{i},ok,mess_tmp]=mask_points_xye(x,xkeep{i},xremove{i},msk{i});
        end
    end
    if ok
        if ~isempty(msk_in{i})
            msk_out = msk_in{i} & msk_out;      % accumulate mask
        end
        if ~isempty(mess_tmp)
            mess=accumulate_mess(mess,mess_tmp);
            display_mess(data_id_mess(sz,i),mess)  % display warning messages
        end
    elseif ~ok
        mess=[data_id_mess(sz,i),mess_tmp];
    end
end

%--------------------------------------------------------------------------------------------------
function mess = data_id_mess(sz,i)
% Dataset identifier string
if prod(sz)==1
    mess='Dataset:';
else
    mess=['Dataset ',arraystr(sz,i),':'];
end

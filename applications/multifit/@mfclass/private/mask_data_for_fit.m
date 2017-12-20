function [wmask,msk_out,ok,mess] = mask_data_for_fit (w,msk_in)
% Mask data
%
%   >> [msk_out,ok,mess] = mask_data_for_fit (w,msk_in,xkeep,xremove,msk)
%
% Input:
% ------
%   w           Cell array (row) of datasets
%
%   msk_in      Cell array (row) of mask arrays, one per data set.
%               Same size as data.
%               If empty, then ignored.
%
% Output:
% -------
%   wmask       Cell array (row) of masked datasets.
%               If there was an error, wmask is an empty cell array size (1,0)
%
%   msk_out     Cell array (row) of mask arrays, one per data set.
%               Same size as input data.
%               If there was an error, msk_out is an empty cell array size (1,0)
%
%   ok          True if all OK, false otherwise
%
%   mess        If  ok, then '' or, if not empty, contains warning message
%               If ~ok, then contains error message
%
% Objects need a method sigvar_getx or mask_points. See elsewhere for required syntax.


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


sz=size(w);
wmask = w;
msk_out = cell(size(w));
mess='';

for i=1:numel(w)
    % Accumulate bad points (y=NaN, zero error bars etc.) to the mask array
    if isstruct(w{i})    % xye triple
        [msk_out{i},ok,mess_tmp]=mask_points_for_fit_xye(w{i}.x,w{i}.y,w{i}.e,msk_in{i});
    else % a different data object
        [ytmp,vtmp,msk_null]=sigvar_get(w{i});
        [msk_out{i},ok,mess_tmp]=mask_points_for_fit_xye({},ytmp,vtmp,(msk_in{i}&msk_null));
    end
    if ok
        if ~isempty(mess_tmp)
            mess=accumulate_message(mess,[data_id_mess(sz,i),mess_tmp]);
        end
    else
        wmask=cell(1,0);
        msk_out=cell(1,0);
        mess=[data_id_mess(sz,i),mess_tmp];
        return
    end
    % Mask data - only if there is some to be masked (don't want to change array sizes otherwise)
    if ~all(msk_out{i}(:))
        if isstruct(w{i})    % xye triple
            wmask{i}.x = cellfun(@(x)x(msk_out{i}),w{i}.x,'UniformOutput',false);
            wmask{i}.y=w{i}.y(msk_out{i});
            wmask{i}.e=w{i}.e(msk_out{i});
        else % a different data object
            wmask{i}=mask(w{i},msk_out{i});
        end
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

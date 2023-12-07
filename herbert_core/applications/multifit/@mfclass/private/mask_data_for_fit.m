function [wmask,keep_out] = mask_data_for_fit (w,msk_in)
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
%   keep_out    Cell array (row) of mask arrays, one per data set.
%               Same size as input data.
%               If there was an error, keep_out is an empty cell array size (1,0)
%
% Objects need a method sigvar_getx or mask_points. See elsewhere for required syntax.


% Original author: T.G.Perring
%


    sz = size(w);
    wmask = w;
    keep_out = cell(size(w));
    for i = 1:numel(w)
        % Accumulate bad points (y = NaN, zero error bars etc.) to the mask array
        if isstruct(w{i})    % xye triple
            [keep_out{i}, mess_tmp] = mask_points_for_fit_xye(w{i}.x,w{i}.y,w{i}.e,msk_in{i});
        else % a different data object
            [ytmp,vtmp,msk_null] = sigvar_get(w{i});
            [keep_out{i}, mess_tmp] = mask_points_for_fit_xye({},ytmp,vtmp,(msk_in{i}&msk_null));
        end
        if ~isempty(mess_tmp)
            mess = [data_id_mess(sz,i),mess_tmp];
            if iscell(mess)
                mess = [mess{:}];
            end
            warning('HERBERT:mask_data_for_fit:bad_points', mess);
        end

        % Mask data - only if there is some to be masked (don't want to change array sizes otherwise)
        if ~all(keep_out{i}(:))
            if isstruct(w{i})    % xye triple
                wmask{i}.x = cellfun(@(x)x(keep_out{i}),w{i}.x,'UniformOutput',false);
                wmask{i}.y = w{i}.y(keep_out{i});
                wmask{i}.e = w{i}.e(keep_out{i});
            else % a different data object
                wmask{i} = mask(w{i},keep_out{i});
            end
        end
    end
end

%--------------------------------------------------------------------------------------------------

function mess = data_id_mess(sz,i)
    % Dataset identifier string
    if prod(sz) == 1
        mess = 'Dataset:';
    else
        mess = ['Dataset ',arraystr(sz,i),':'];
    end

end

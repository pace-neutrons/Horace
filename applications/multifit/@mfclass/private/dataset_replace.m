function [ok, mess, data_out] = dataset_replace (data_in, idata, data)
% Replace one or more datasets with ones of the same type
%
%   >> [ok, mess, data_out] = dataset_replace (data_in, idata, data)
%
% Input:
% ------
%   data_in     Valid datasets as given by user (see is_valid_data for details)
%
%   idata       Indicies of datasets to be replaced. Assumesd to be a unique list
%              with valid indicies in the range 1 to number of datasets in data_in
%               If empty (i.e. []), then nothing is done
%
%   data        Replacement valid datasets as provided by the user. Assumed that
%              the number of datasets is equal to numel(idata)
%
% Output:
% -------
%   data_out    Datasets with replacements inserted
%
% Datsets can only be replace ones of the same type. The exception is if
% the input was a trio of nunmeric arrays (x,y,e) that will replace a cell
% array.


% Original author: T.G.Perring
%
% $Revision:: 832 ($Date:: 2019-08-11 23:25:59 +0100 (Sun, 11 Aug 2019) $)


% Initialise output (accounts also for trivial case of no dat to replace)
ok = true;
mess = '';
data_out = data_in;

if ~isempty(idata)
    % Determine if replacement dataset is {x,y,e}
    if numel(data)==3 && isnumeric(data{2})
        xye_trio = true;
    else
        xye_trio = false;
    end
    
    % Replace datasets
    if numel(data_in)==3 && isnumeric(data_in{2})   % {x,y,e}
        % Can only replace {x,y,e} with {x,y,e} (do not allow {{x,y,e}}
        % because the output data will not have the same format as the
        % input data
        if ~xye_trio
            ok = false;
            mess = 'Can only replace a datset defined by three numeric array by the same format dataset';
            return
        end
    else
        % Input data is a set of cellarrays, structures or objects
        [~, ~, item_in, ix_in] = data_indicies(data_in);
        [~, ~, item, ix] = data_indicies(data);
        if xye_trio
            data = {data};  % turn into {{x,y,e}} for later convenience
        end
        for i=1:numel(idata)
            item_cur = item_in(idata(i));
            ix_cur = ix_in(idata(i));
            if iscell(data_in{item_cur}) && iscell(data{item(i)})
                % One of: {x,y,e} or {{x1,y1,e1},{x2,y2,e2},...}
                if cell_is_xye(data_in{item_cur})
                    if cell_is_xye(data{item(i)})
                        data_out{item_cur} = data{item(i)};
                    else
                        data_out{item_cur} = data{item(i)}{ix(i)};
                    end
                else
                    if cell_is_xye(data{item(i)})
                        data_out{item_cur}{ix_cur} = data{item(i)};
                    else
                        data_out{item_cur}{ix_cur} = data{item(i)}{ix(i)};
                    end
                end
                
            elseif isstruct(data_in{item_cur}) && isstruct(data{item(i)})
                % Structures
                data_out{item_cur}(ix_cur) = data{item(i)}(ix(i));
                
            elseif isobject(data_in{item_cur}) && isobject(data{item(i)})
                % Objects
                data_out{item_cur}(ix_cur) = data{item(i)}(ix(i));
                
            else
                ok = false;
                mess = ['Attempting to replace dataset ',num2str(idata(i)),...
                    ' with one of a different type'];
                return
            end
        end
    end
end


%------------------------------------------------------------------------------
function status = cell_is_xye(var)
% Assuming a cellarray is one of:
% - {x,y,e}
% - {{x1,y1,e1},{x2,y2,e2},...} (including case of {{x,y,e}} )
% this function returns true if the former, false if the latter
status = ~all(cellfun(@iscell,var(:)));

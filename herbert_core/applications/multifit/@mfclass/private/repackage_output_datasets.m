function data_out = repackage_output_datasets(data, w, msk, keep_only_unmasked)
% Repackage calculated data into the form of the input data.
%
%   >> data_out = repackage_output_datasets(data, w, msk, keep_only_unmasked)
%
% Input:
% ------
%   data        Cell array (row) with input data as provided by user (i.e. elements
%               may be cell arrays of {x,y,e}, structure arrays, object arrays);
%               a special case is thee elements x, y, e.
%               If an element is an array it can be entered with any shape, but if
%               a dataset is removed from the array, then it will turned into a column
%               or a row vector (depending on its initial shape, according to usual
%               matlab reshaping rules for logically indexed arrays)
%
%               This data is used as the template to unpack the contents of wout
%
%   w           Cell array of datasets (row) that contain repackaged data:
%               every entry is either
%                - an x-y-e triple with wout{i}.x a cell array of arrays,
%                  one for each x-coordinate,
%                - a scalar object
%
%   msk         Cell array (row) of mask arrays, one per data set. 
%               Same size as signal array of corresponding element in data
%
%   keep_only_unmasked  Keep only unmasked data points. This option is used to
%                       determine how x-y-e data (i.e. non-object data) is
%                       returned:
%                       - if true, then if there are any masked data points
%                        they are removed and (i) the signal and error arrays
%                        are turned into columns, and (ii) if the x array(s)
%                        are in the form of a cell array, each x array is turned
%                        into a column; if a single array with outer dimension
%                        the dimensionality, then the s array becomes a 2D array
%                       - if false, then masked y values are filled with NaNs
%                        and masked errors filled with zeros. The arrays shapes
%                        are the same as the input data.
%
% Output:
% -------
%   data_out    The repackaged data unpacked according to the template
%               defined by input argumnet data


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


if numel(w)==1 && numel(data)==3
    % x,y,e supplied as separate arguments
    tmp = is_cell_xye ({data}, w, msk, keep_only_unmasked);
    data_out = tmp{1};
    
else
    % All other cases
    data_out=cell(size(data));
    nbeg=1;
    for item=1:numel(data)
        if iscell(data{item})
            % One of: {x,y,e} or {{x1,y1,e1},{x2,y2,e2},...}
            if all(cellfun(@iscell,data{item}(:)))
                % {{x1,y1,e1},{x2,y2,e2},...} (including case of {{x,y,e}} )
                ndata=numel(data{item});
                data_out{item} = is_cell_xye (data{item},...
                    w(nbeg:nbeg+ndata-1), msk(nbeg:nbeg+ndata-1), keep_only_unmasked);
            else
                % {x,y,e}
                ndata=1;
                data_out(item) = is_cell_xye (data(item),...
                    w(nbeg:nbeg+ndata-1), msk(nbeg:nbeg+ndata-1), keep_only_unmasked);
            end
            
        elseif isstruct(data{item})
            ndata=numel(data{item});
            data_out{item} = is_struct_xye (data{item},...
                w(nbeg:nbeg+ndata-1), msk(nbeg:nbeg+ndata-1), keep_only_unmasked);
            
        elseif isobject(data{item})
            % For some reason, cell2mat doesn't work with arbitrary objects, so fix-up
            ndata=numel(data{item});
            if ndata>1
                data_out{item} = reshape(cell2mat_obj(w(nbeg:nbeg+ndata-1)),size(data{item}));
            else
                data_out{item} = w{nbeg};
            end
            
        else
            error('Logic error. Contact developers')
        end
        nbeg=nbeg+ndata;
    end
    if size(data)==1
        data_out=data_out{1};
    end
end

%--------------------------------------------------------------------------------------------------
function data_out = is_cell_xye (data, w, msk, keep_only_unmasked)
% Repackage simulated data array in form of input data, if cell array
% of form {{x1,y1,e1},{x2,y2,e2},...} (including case of {{x,y,e}} )
data_out = data;
for ind=1:numel(data)
    masked = ~all(msk{ind}(:));
    if keep_only_unmasked && masked
        data_out{ind}{1} = repackage_x (data{ind}{1}, data{ind}{2}, w{ind}.x);
        data_out{ind}{2} = w{ind}.y;
        data_out{ind}{3} = w{ind}.e;
    else
        if masked
            data_out{ind}{2} = NaN(size(data{ind}{2}));
            data_out{ind}{3} = zeros(size(data{ind}{3}));
            data_out{ind}{2}(msk{ind}) = w{ind}.y;
            data_out{ind}{3}(msk{ind}) = w{ind}.e;
        else
            data_out{ind}{2} = w{ind}.y;
            data_out{ind}{3} = w{ind}.e;
        end
    end
end

%--------------------------------------------------------------------------------------------------
function data_out = is_struct_xye (data, w, msk, keep_only_unmasked)
% Repackage simulated data array in form of input data, if structure
data_out = data;
for ind=1:numel(data)
    masked = ~all(msk{ind}(:));
    if keep_only_unmasked && masked
        data_out(ind).x = repackage_x (data(ind).x, data(ind).y, w{ind}.x);
        data_out(ind).y = w{ind}.y;
        data_out(ind).e = w{ind}.e;
    else
        if masked
            data_out(ind).y = NaN(size(data(ind).y));
            data_out(ind).e = zeros(size(data(ind).e));
            data_out(ind).y(msk{ind}) = w{ind}.y;
            data_out(ind).e(msk{ind}) = w{ind}.e;
        else
            data_out(ind).y = w{ind}.y;
            data_out(ind).e = w{ind}.e;
        end
    end
end

%--------------------------------------------------------------------------------------------------
function xout = repackage_x (x,y,xmsk)
if iscell(x)
    xout = xmsk;
else
    if isequal(size(x),size(y))
        xout = xmsk{1}; % one-dimensional data set
    else
        % Outer dimension of unmasked x gives the dataset dimensionality
        % Masked x arrays will be columns or rows (the latter if each x{i}
        % was a row)
        szy = size(y);
        if numel(szy)==2 && szy(end)==1
            nd = 2;
        else
            nd = numel(szy)+1;
        end
        xout = cat(nd,xmsk{:});
    end
end


function sz_data = get_size_data (val, npnt)
% Determine the size of the value array for a single point
% Removes trailing singleton dimensions

if npnt<=0 || rem(npnt,1)~=0
    error('The number of points must be an integer greter than zero')
end

nval = numel(val);
sz_val = size(val);
nval_per_pnt = nval/npnt;
if rem(nval_per_pnt,1)~=0
    error('Number of data values per point is not an integer')
end

if nval_per_pnt>1
    ix = find(cumprod(sz_val)==nval_per_pnt,1,'first');
    if ~isempty(ix)
        sz_data = sz_val(1:ix);
        if numel(sz_data)==1
            sz_data = [sz_data,1];
        end
    else
        error('The value array cannot be resolved into leading sub-arrays for data values per point')
    end
else
    sz_data = [1,1];
end

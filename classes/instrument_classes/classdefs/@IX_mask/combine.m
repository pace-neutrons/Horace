function mask_out = combine(varargin)
% Combine mask data to form a single mask object
%
%   >> mask_out = combine(mask1, mask2,...)
%
% Input:
% ------
%   mask1       Mask object
%   mask2       Mask object, name of .msk file, or array (see >> help IX_mask for details)
%   mask3           :
%     :             :
%
% Output:
% -------
%   mask_out    Combined mask object, with duplicate masked elemets removed

classname='IX_mask';
c=cell(1,numel(varargin));
for i=1:numel(c)
    if isa(varargin{i},classname)
        c{i}=varargin{i}.msk;
    else
        try
            tmp=IX_mask(varargin{i});
            c{i}=tmp.msk;
        catch
            error('Check all input arguments form a valid mask object if passed to IX_mask')
        end
    end
end

mask_out=IX_mask(cell2mat(c));

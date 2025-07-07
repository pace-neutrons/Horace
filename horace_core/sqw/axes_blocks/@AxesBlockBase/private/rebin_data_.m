function out = rebin_data_(obj,data_in,other_ax)
% Rebin data,defined on this axes grid into other axes grid
%
% The other axes grid has to be aligned with this axes block
% according to realigh_axes method of this axes block


data_nodes = obj.get_bin_nodes('-bin_centre');
out = cell(1,3);
use_mex = config_store.instance().get_value('hor_config','use_mex');
if use_mex
    for i=1:numel(data_in)
        data_in{i} = data_in{i}(:);
    end
end
%
[out{1},out{2},out{3}] = other_ax.bin_pixels(data_nodes,[],[],[],data_in);


if use_mex
    bin_pixels_c('clear'); % release memory hold by the mex plugin as it would not be reused at the next call
end
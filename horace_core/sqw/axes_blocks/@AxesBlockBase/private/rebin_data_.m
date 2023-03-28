function data_out = rebin_data_(obj,data_in,other_ax)
% Rebin data,defined on this axes grid into other axes grid
%
% The other axes grid has to be aligned with this axes block
% according to realigh_axes method of this axes block


data_nodes = obj.get_bin_nodes('-bin_centre');
data_out = cell(numel(data_in),1);
%
[~,data_out{1},data_out{2},data_out{3}] = other_ax.bin_pixels(data_nodes,[],[],[],data_in);
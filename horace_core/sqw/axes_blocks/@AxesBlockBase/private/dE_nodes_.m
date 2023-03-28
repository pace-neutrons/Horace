function  nodes = dE_nodes_(obj,varargin)
%DE_NODES_  helper function returns list of energy axis nodes

[ok,mess,bin_centers] = parse_char_options(varargin,'-bin_centers');
if ~ok
    error('HORACE:AxesBlockBase:invalid_argument', mess)
end
nodes = linspace(obj.img_range(1,4),obj.img_range(2,4),obj.nbins_all_dims(4)+1);    
if bin_centers
    nodes = 0.5*(nodes(1:end-1)+nodes(2:end));
end
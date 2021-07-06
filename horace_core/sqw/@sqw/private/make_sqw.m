function d = make_sqw(ndims) 
% Create a valid structure for an sqw object
%
% Input:
% -------
% ndim            Number of dimensions
%
    d.main_header = make_sqw_main_header;
    d.header_x = make_sqw_header;
    d.detpar_x = make_sqw_detpar;
    d.data = data_sqw_dnd(ndims);
end

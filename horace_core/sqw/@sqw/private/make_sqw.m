function d = make_sqw(ndims) 
% Create a valid structure for an sqw object
%
% Input:
% -------
% ndim            Number of dimensions
%
    d.experiment_info = make_sqw_header;
    d.detpar = make_sqw_detpar;
    d.data   = data_sqw_dnd(ndims);
    d.runid_map= containers.Map(1,1);
end

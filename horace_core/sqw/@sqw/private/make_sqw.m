function d = make_sqw(ndims)
    % Create a structure for an sqw object
    d.main_header=make_sqw_main_header;
    d.header=make_sqw_header;
    d.detpar=make_sqw_detpar;
    d.data=data_sqw_dnd(ndims);
end
function [d,position,npixtot]=test_put_sqw_tmp(w,outfile)
% Write sqw object to sparse format file

d=sqw_sparse(w);

[mess,position,npixtot,data_type] = put_sqw (outfile,d.main_header,d.header,d.detpar,d.data);

mess
position
npixtot
data_type

function [d,position,npixtot]=test_get_sqw_tmp(w,infile,varargin)
% read sqw object from sparse format file

[mess,main_header,header,detpar,data,position,npixtot,data_type,file_format,current_format] = ...
    get_sqw (infile,varargin{:});

d.main_header=main_header;
d.header=header;
d.detpar=detpar;
d.data=data;

mess
position
npixtot
data_type
file_format
current_format

function [fmt_dble,fmt_int,nbyte_dble,nbyte_int]=fmt_sqw_fields(fmt_ver)
% Return the format for reading or writing doubles as floating and integer values to sqw files
%
%   >> [fmt_dble,fmt_int]=fmt_sqw_fields(fmt_ver)
%
% Input:
% ------
%   fmt_ver     Version of file format e.g. appversion('-v3')
%
% Output:
% -------
%   fmt_dble    Format for writing floating scalars or small arrays
%   fmt_int     Format for writing integer scalars or small arrays
%   nbyte_dble  Number of bytes for a scalar double in the file
%   nbyte_int   Number of bytes for a scalar integer in the file
%
% This routine does not provide the formats for the s,e,npix,pix arrays, which are defined
% in the particular put_* and get_* functions specifically for reading these variables

ver3p1=appversion(3.1);
if fmt_ver>=ver3p1
    fmt_dble='float64';
    fmt_int='float64';
    nbyte_dble=8;
    nbyte_int=8;
else
    fmt_dble='float32';
    fmt_int='int32';
    nbyte_dble=4;
    nbyte_int=4;
end

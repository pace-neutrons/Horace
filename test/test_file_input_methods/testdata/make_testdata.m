function [sqw1d_arr,sqw2d_arr,d1d_arr,d2d_arr,sqw1d_name,sqw2d_name,d1d_name,d2d_name]=make_testdata
% Function to read test data into matlab for testing various functions, and
% create files in the temporary folder
%
%   >> [sqw1d_arr,sqw2d_arr,d1d_arr,d2d_arr,...
%           sqw1d_name,sqw2d_name,d1d_name,d2d_name]=read_testdata
%
%   sqw1d_arr   sqw object array: two 1D cuts
%   sqw2d_arr   sqw object array: two 2D cuts
%
%   d1d_arr     d1d object array: two 1D cuts
%   d2d_arr     d2d object array: two 2D cuts
%
%   sqw1d_name  cell array of the names of the two files with 1D sqw data
%   sqw2d_name  cell array of the names of the two files with 1D sqw data
%
%   d1d_name  cell array of the names of the two files with 1D sqw data
%   d2d_name  cell array of the names of the two files with 1D sqw data

root=fileparts(which(mfilename));

sqw1d_arr(1)=read(sqw,fullfile(root,'sqw_1d_1.sqw'));
sqw1d_arr(2)=read(sqw,fullfile(root,'sqw_1d_2.sqw'));

sqw2d_arr(1)=read(sqw,fullfile(root,'sqw_2d_1.sqw'));
sqw2d_arr(2)=read(sqw,fullfile(root,'sqw_2d_2.sqw'));

d1d_arr=dnd(sqw1d_arr);
d2d_arr=dnd(sqw2d_arr);

sqw1d_name{1}=fullfile(tempdir,'sqw_1d_1.sqw');
sqw1d_name{2}=fullfile(tempdir,'sqw_1d_2.sqw');
save(sqw1d_arr(1),sqw1d_name{1})
save(sqw1d_arr(2),sqw1d_name{2})

sqw2d_name{1}=fullfile(tempdir,'sqw_2d_1.sqw');
sqw2d_name{2}=fullfile(tempdir,'sqw_2d_2.sqw');
save(sqw2d_arr(1),sqw2d_name{1})
save(sqw2d_arr(2),sqw2d_name{2})

d1d_name{1}=fullfile(tempdir,'d1d_1.d1d');
d1d_name{2}=fullfile(tempdir,'d1d_2.d1d');
save(d1d_arr(1),d1d_name{1})
save(d1d_arr(2),d1d_name{2})

d2d_name{1}=fullfile(tempdir,'d2d_1.d2d');
d2d_name{2}=fullfile(tempdir,'d2d_2.d2d');
save(d2d_arr(1),d2d_name{1})
save(d2d_arr(2),d2d_name{2})

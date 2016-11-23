function [sqw1d_arr,sqw2d_arr,d1d_arr,d2d_arr,sqw1d_name,sqw2d_name,d1d_name,d2d_name]=create_testdata(get_names)
% Function to return sqw and dnd test data and also save the same objects in the temporary folder
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
%
% Author: T.G.Perring
if ~exist('get_names','var')
    get_names = false;
else
    get_names = true;
end


sqw1d_name{1}=fullfile(tempdir,'test_file_input_sqw_1d_1.sqw');
sqw1d_name{2}=fullfile(tempdir,'test_file_input_sqw_1d_2.sqw');
sqw2d_name{1}=fullfile(tempdir,'test_file_input_sqw_2d_1.sqw');
sqw2d_name{2}=fullfile(tempdir,'test_file_input_sqw_2d_2.sqw');
d1d_name{1}=fullfile(tempdir,'test_file_input_d1d_1.d1d');
d1d_name{2}=fullfile(tempdir,'test_file_input_d1d_2.d1d');
d2d_name{1}=fullfile(tempdir,'test_file_input_d2d_1.d2d');
d2d_name{2}=fullfile(tempdir,'test_file_input_d2d_2.d2d');
if get_names
    sqw1d_arr = [];
    sqw2d_arr = [];
    d1d_arr   = [];
    d2d_arr   = [];
    return
else
    
    root=fileparts(which(mfilename));
    
    sqw1d_arr(1)=read(sqw,fullfile(root,'sqw_1d_1.sqw'));
    sqw1d_arr(2)=read(sqw,fullfile(root,'sqw_1d_2.sqw'));
    
    sqw2d_arr(1)=read(sqw,fullfile(root,'sqw_2d_1.sqw'));
    sqw2d_arr(2)=read(sqw,fullfile(root,'sqw_2d_2.sqw'));
    
    d1d_arr=dnd(sqw1d_arr);
    d2d_arr=dnd(sqw2d_arr);
    
    save(sqw1d_arr(1),sqw1d_name{1})
    save(sqw1d_arr(2),sqw1d_name{2})
    
    save(sqw2d_arr(1),sqw2d_name{1})
    save(sqw2d_arr(2),sqw2d_name{2})
    
    save(d1d_arr(1),d1d_name{1})
    save(d1d_arr(2),d1d_name{2})
    
    save(d2d_arr(1),d2d_name{1})
    save(d2d_arr(2),d2d_name{2})
end

function [fpath,filename,fext]=get_source_fname(this)
% the method returns the name of the file, which contains experiment data 
%
% 
%>>[fpath,filename,fext]= get_source_fname(rundata_instance)
%Input:
% rundata_instance -- fully initated instance of rundata class.
%Output:
%filepath          -- the path to the source file
%filename          -- the name of the source file 
%fext              -- the source file exitension
%


if isempty(this.loader)
    error('RUNDATA:get_sqw_fname',' rundata class is not fully defined\n')
end
%
[fpath,filename,fext]=fileparts(this.loader.file_name);


function [fpath,filename]=get_sqw_fname(this)
% the method returns temportary file name to write sqw data to. 
%
% 
%>>filename = get_sqw_fname(rundata_instance)
%Input:
% rundata_instance -- fully initated instance of rundata class.
%Output:
%filename          -- the name of the file to write sqw data. 
%                     this name coinside with the name of spe file, which
%                     contains results of the experiment. The extension of
%                     the file and its postion is defined by
%                     rundata_config. The defauls are 
% folder              The same folder as the initial spe file
% extension --  .tmp 
% These data can be changed by setting different values in rundata_config
%
%

if isempty(this.loader)
    error('RUNDATA:get_sqw_fname',' rundata class is not fully defined\n')
end
%
[fpath,fname]=fileparts(this.loader.file_name);
new_ext = get(rundata_config,'sqw_ext');

filename = [fname,new_ext];
if ~isempty(get(rundata_config,'sqw_path'))
    fpath = get(rundata_config,'sqw_path');
end



function [fpath,filename,fext]=get_source_fname(this)
% Returns the name of the file which contains experimental data 
%
%   >> [fpath,filename,fext] = get_source_fname (rundata_instance)
%
% Input:
% ------
%   rundata_instance    Fully initated instance of rundata class
%
% Output:
% -------
%   filepath            The path to the source file
%   filename            The name of the source file (including extension)
%   fext                The source file extension

if isempty(this.loader)
    error('RUNDATA:get_sqw_fname',' rundata class is not fully defined\n')
end

[fpath,filename,fext]=fileparts(this.loader.file_name);
filename=[filename,fext];

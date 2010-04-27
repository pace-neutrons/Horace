function [filepath,filename]=set_file_name(this,file_path,file_name,varargin)
% spe_header method sets up internal fields describing cuccent file name 
% checking if this name is correct and can be used for a file
%
% usage: 
% [filepath,filename]=spe_header.set_file_name(file_path,file_name,varargin)
% or
% [filepath,filename]=set_file_name(new_header,file_path,file_name,varargin)
%
% where:
%
% file_path  -- the path where the file should be located;
% file_name  -- the file name
% varargin{1}-- optional - non-default file extention
%
%
% $Revision$ ($Date$)
%
if isempty(file_name)
          file_name=this.default_fileName;
end

if ~exist(file_path,'dir')
     file_path=pwd;
end
% for compartibility with hdf routines simpe path of type '/' is not
% allowed
if strcmp(file_path,filesep)
          file_path=pwd;
end
if nargin>3
         if ~ischar(varargin{1})
              error('HORACE:hdf_tools','spe_header::set_file_nam -> third parameter, if present, has to be string describing valid file extension');
          end
          if ~isa(this,'spe_header')
              warning('HORACE:hdf_tools','non-default extenstion %s used for the file',varargin{1});
          end
          ext = varargin{1};
          if ext(1)~='.'
              ext = ['.',ext];
          end
          this.file_ext = ext;
end
       
       
file = fullfile(file_path,file_name); 
[filepath,filename]=fileparts(file); 


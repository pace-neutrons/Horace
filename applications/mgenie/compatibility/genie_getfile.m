function file_out = genie_getfile (varargin)
% Utility to get file name for input:  file_out = genie_getfile (filterspec,dialogtitle).
%
% It is identical to the Matlab built-in function uigetfile, except that
%  - Returns filename including path; ='' if no file selected
%
%  - If a dialog box is opened, the default operation of uigetfile is altered:
%    (1) the default directory is that of the file most recently selected by genie_getfile (if filespec is a simple string)
%    (2) the default extension is *.* rather than Matlab files
%    (3) it does not fail if dialogtitle is not a string
%
% Syntax:
%   >> filename = genie_getfile (filterspec)
%   e.g.    >> file = genie_getfile                          'Select File' box opened, default path is path
%                                                          of most recent file selected
%
%           >> file = genie_getfile ('c:\temp')              'Select File' box opened, default path is c:\temp\
%
%           >> file = genie_getfile ('*.spe')                 'Select File' box opened, default path is path
%                                                          of most recent file selected; default extension .spe
%
%           >> file = genie_getfile ('d:\data\*.spe')         'Select File' box opened, default path is d:\data\
%                                                          and default extension is .spe
%
%           >> file = genie_getfile ('c:\mprogs\add_spe.m')   Default file name
%
%   >> filename = genie_getfile (filterspec, dialogtitle)     Title of 'Select File' box changed to dialogtitle
%
%
% See also genie_putfile (essentially the same as uiputfile)
%
% This is a compatibility function that calls getfile

file_out=genie_getfile(varargin{:});

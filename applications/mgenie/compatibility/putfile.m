function file_out = putfile (varargin)
% Utility to get file name for input:  file_out = genie_putfile (filterspec,dialogtitle)
%
% It is identical to the Matlab built-in function uiputfile, except that
%  - Returns filename including path; ='' if no file selected
%
%  - If a dialog box is opened, the default operation of uiputfile is altered:
%    (1) the default directory is that of the file most recently selected by genie_putfile (if filespec is a simple string)
%    (2) the default extension is *.* rather than Matlab files
%    (3) it does not fail if dialogtitle is not a string
%
% Syntax:
%   >> filename = genie_putfile (filterspec)
%   e.g.    >> file = genie_putfile                          'Select File' box opened, default path is path
%                                                          of most recent file selected
%
%           >> file = genie_putfile ('c:\temp')              'Select File' box opened, default path is c:\temp\
%
%           >> file = genie_putfile ('*.spe')                 'Select File' box opened, default path is path
%                                                          of most recent file selected; default extension .spe
%
%           >> file = genie_putfile ('d:\data\*.spe')         'Select File' box opened, default path is d:\data\
%                                                          and default extension is .spe
%
%           >> file = genie_putfile ('c:\mprogs\add_spe.m')   Default file name
%
%   >> filename = genie_putfile (filterspec, dialogtitle)     Title of 'Select File' box changed to dialogtitle
%
%
% See also genie_getfile (essentially the same as uigetfile)
%
% This is a compatibility function that calls putfile

file_out=genie_putfile(varargin{:});

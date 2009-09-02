function varargout = read(varargin)
% Read d1d object from a file
% 
%   >> w=read(d1d,file)
%
% Need to give first argument as a d1d object to enforce the execution of this method.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> read(d1d,'c:\temp\my_file.sqw')
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

argout=read(sqw(varargin{1}),varargin{2:end});     % output is a cell array
varargout{1}={dnd(argout{1})};      % must ensure output is still a cell array after conversion to dnd

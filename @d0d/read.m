function varargout = read(varargin)
% Read d0d object from a file
% 
%   >> w=read(d0d,file)
%
% Need to give first argument as a d0d object to enforce the execution of this method.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> read(d0d,'c:\temp\my_file.sqw')
% Gives the same information as display for an sqw object

% Original author: T.G.Perring
%
% $Revision: 259 $ ($Date: 2009-08-18 13:03:04 +0100 (Tue, 18 Aug 2009) $)

% ----- The following shoudld be independent of d0d, d1d,...d4d ------------
% Work via sqw class type

argout=read(sqw(varargin{1}),varargin{2:end});     % output is a cell array
varargout{1}={dnd(argout{1})};      % must ensure output is still a cell array after conversion to dnd

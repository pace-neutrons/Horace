function w = read_sqw(varargin)
% Read sqw object from named file or an array of sqw objects from a cell array of file names
% 
%   >> w=read_sqw           % prompts for file
%   >> w=read_sqw(file)     % read named file or cell array of file names into array

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

% Catch trivial case of sqw object
if nargin==1 && isa(varargin{1},'sqw')
    w=varargin{1};
    return
elseif nargin>=2
    error('Check number of arguments')
end

% Check file name(s), prompting if necessary
if nargin==0
    [file_internal,mess]=function_getfile('*.sqw');
else
    [file_internal,mess]=function_getfile(varargin{:});
end
if ~isempty(mess)
    error(mess)
end

% Make object
w=function_sqw(file_internal,@read);

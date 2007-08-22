function wout = section (win, varargin)
% Takes a section out of a 1-dimensional dataset.
%
% Syntax:
%   >> wout = section (win, xlo, xhi)
%   >> wout = section (win, [xlo, xhi])     % for syntactical consistency with 2,3,4 dimensional section     
%
% Input:
% ------
%   win                 1-dimensional dataset.
%   xlo                 Lower integration limit
%   xhi                 Upper integration limit
%
% Output:
% -------
%   wout                Output dataset.
%
%
% Example: 
%   >> wout = section (win, 1.9, 2.1)
%                                                           

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring


if nargin==1
    wout = win; % trivial case of no sectioning being required
else
    if length(varargin)==2 && (isa_size(varargin{1},[1,1],'double') && isa_size(varargin{2},[1,1],'double'))  % syntax must be cut(w1,xlo,xhi)
        args = {[varargin{1}, varargin{2}]};
    else
        args = varargin;
    end
    wout = dnd_create(dnd_section(get(win), args));
end

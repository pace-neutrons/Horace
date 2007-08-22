function wout = rebunch(win, varargin)
% REBUNCH - rebunch data points into groups of nbin points.
%
% Syntax:
%
%   >> w_out = rebunch(w_in, nbin)   rebunches the data of W_IN in groups of nbin
%
%   >> w_out = rebunch(w_in)         same as NBIN=1 i.e. W_OUT is just a copy of W_IN
%
%  Syntax is the same as the IXTdataset_1d operation. See this help for
%  details on syntax.

% The help section above should be identical to that for spectrum/rebunch

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

if (nargin==1)
    wout = win;
else
    wout = dnd_data_op(win, @rebunch, 'd1d' , 1 , varargin{:});
end
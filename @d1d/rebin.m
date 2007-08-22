function wout = rebin(win, varargin)
% REBIN - Rebins a 1D dataset
%
% Syntax:
%
%  wout = rebin(w1,w2)      rebin w1 with the bin boundaries of w2 (*** Note: reverse of Genie-2)
%  -------------------
%
%  wout = rebin(w1,x_array)  x_array is an array of boundaries and intervals. Linear or logarithmic
%  ------------------------ rebinning can be accommodated by conventionally specifying the rebin
%                           interval as positive or negative respectively:
%   e.g. rebin(w1,[2000,10,3000])  rebins from 2000 to 3000 in bins of 10
%
%  Syntax is the same as the IXTdataset_1d operation. See this help for
%  details on advanced syntax.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J.Van Duijn, T.G.Perring

% The help section above should be identical to that for spectrum/rebin

if (nargin==1)
    wout = win;
else
    wout = dnd_data_op(win, @rebin, 'd1d' , 1 , varargin{:});
end

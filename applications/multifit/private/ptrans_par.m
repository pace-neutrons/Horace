function [p,bp]=ptrans_par(pf,w)
% Transform free parameter values to parameter values needed for function evaluation
%
%   >> [p,bp]=ptrans_par(pf,w)
%
% Input:
% ------
%   pf      Array of free parameters
%   w       Structure containing information to convert to function parameters
%          (See the function ptrans_initialise for details)
%
% Output:
% -------
%   p       Column cell array of column vectors, each with the parameter values
%          for the foreground function(s)
%   bp      Column cell array of column vectors, each with the parameter values
%          for the background function(s)

% Update list of parameter values
pp=w.pp0;
pp(w.free)=pf;
pp(w.bound)=w.ratio(w.bound).*pp(w.ib(w.bound));

% Convert to cell arrays for foreground and background functions
p=mat2cell(pp(1:w.nptot),w.np(:),1);
bp=mat2cell(pp(w.nptot+1:end),w.nbp(:),1);

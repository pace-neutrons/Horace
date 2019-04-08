function [p,bp]=ptrans_par(pf,p_info)
% Transform free parameter values to parameter values needed for function evaluation
%
%   >> [p,bp]=ptrans_par(pf,p_info)
%
% Input:
% ------
%   pf      Array of free parameters
%   p_info  Structure containing information to convert to function parameters
%          (See the function ptrans_initialise for details)
%
% Output:
% -------
%   p       Column cell array of column vectors, each with the parameter values
%          for the foreground function(s)
%   bp      Column cell array of column vectors, each with the parameter values
%          for the background function(s)


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 16:16:02 +0100 (Mon, 8 Apr 2019) $)


% Update list of parameter values
pp=p_info.pp0;
pp(p_info.free)=pf;
pp(p_info.bound)=p_info.ratio(p_info.bound).*pp(p_info.ib(p_info.bound));

% Convert to cell arrays for foreground and background functions
if numel(p_info.np)==1
    p={pp(1:p_info.nptot)};
else
    p=vec_to_cell(pp(1:p_info.nptot),p_info.np);
end

if numel(p_info.nbp)==1
    bp={pp(p_info.nptot+1:end)};
else
    bp=vec_to_cell(pp(p_info.nptot+1:end),p_info.nbp);
end

function [xc,ok,mess]=bin_centres(xb)
% Get bin centres
%
%   >> [xc,ok,mess]=bin_centres(xb)
%
% Input:
% ------
%   xb      Vector of bin boundaries; must be strictly monotonic increasing
%           Must have at least one bin boundary.
%
%
% Output:
% -------
%   xc      Vector of point positions; same orientation (i.e row or column) as input
%          Set to [] if only one bin boundary, or if there is a problem.
%   ok      =true if all OK, =false otherwise. If called with only one return argument
%          then an error is thrown.
%   mess    Message; ='' if OK

if numel(xb)>1
    if all(diff(xb)>0)
        xc=0.5*(xb(2:end)+xb(1:end-1));
        ok=true; mess='';
    else
        xc=[];
        ok=false;
        mess='Bin boundaries must be strictly monotonic increasing';
        if nargout==1, error(mess), end
    end
elseif numel(xb)==1
    xc=[];
    ok=true; mess='';
else
    xc=[];
    ok=false;
    mess='Must have at least two bin boundaries';
    if nargout==1, error(mess), end
end

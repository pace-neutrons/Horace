function [xb,ok,mess]=bin_boundaries_simple(xc)
% Get simple set of bin boundaries - set at halfway between points
%
%   >> [xb,ok,mess]=bin_boundaries_simple(xc)
%
% Input:
% ------
%   xc      Vector of point positions, must be strictly monotonic increasing
%
%
% Output:
% -------
%   xb      Vector of bin boundaries; same orientation (i.e row or column) as input
%          Set to [] if there is a problem.
%   ok      =true if all OK, =false otherwise. If called with only one return argument
%          then an error is thrown.
%   mess    Message; ='' if OK
%
% If one point only, then bin boundaries are set to row vector [x-0.5,x+0.5]

if numel(xc)>1
    if isvector(xc)
        del=diff(xc);
        if any(del<=0);
            xb=[]; ok=false; mess='Points must be strictly monotonic increasing';
            if nargout>1, return, else error(mess), end
        end
        if size(xc,1)>1, row=false; else row=true; end
        if numel(xc)>2
            xc=xc(:);
            del0=0.5*(xc(2)-xc(1));
            del1=0.5*(xc(end)-xc(end-1));
            xb=[xc(1)-del0; 0.5*(xc(2:end)+xc(1:end-1)); xc(end)+del1];
        else
            xb=[xc(1)-0.5*del; 0.5*(xc(2)+xc(1)); xc(2)+0.5*del];
        end
        if row, xb=xb'; end
    else
        xb=[]; ok=false; mess='Input array must be a vector';
        if nargout>1, return, else error(mess), end
    end
elseif numel(xc)==1
    xb=[xc-0.5,xc+0.5];
else
    xb=[]; ok=false; mess='No points in input array';
    if nargout>1, return, else error(mess), end
end
if nargout>=2, ok=true; end
if nargout>=3, mess=''; end

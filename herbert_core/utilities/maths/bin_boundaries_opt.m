function [xb,ok,mess]=bin_boundaries_opt(xc)
% Get best estimate of bin boundaries as a row vector
%
%   >> [xb,ok,mess]=bin_boundaries_opt(xc)
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

% T.G.Perring, 7 September 2009

if numel(xc)>1
    if isvector(xc)
        del=diff(xc);
        if any(del<=0);
            xb=[]; ok=false; mess='Points must be strictly monotonic increasing';
            if nargout>1, return, else error(mess), end
        end
        if all(del==del(1))
            xb=[xc(:)-del(1)/2;xc(end)+del(1)/2];
        else
            del_max=xc(2)-xc(1);    % Maximum possible value for half width of first bin
            [del,fval,exitflag,output]=fminbnd(@(x) bin_boundaries_special(xc,x),0,del_max,optimset('TolX',1e-12));
            
            % Get boundaries at the optimum value of del
            [tmp,xb]=bin_boundaries_special(xc,del);
            if ~isreal(xb)
                xb=[]; ok=false; mess='Complex solution for bin boundaries';    % e.g. xc=[2,4,5]
                if nargout<2, error(mess), end
            elseif any(diff(xb)<=0)
                xb=[]; ok=false; mess='Solution for bin boundaries not strictly monotonic';
                if nargout<2, error(mess), end
            end
        end
        if size(xc,1)==1, xb=xb'; end
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

%========================================================================================
function [dev,xb]=bin_boundaries_special(xc,del)
% Get the bin boundaries for a given value for half-bin-width for first bin,
% and also return a measure of the deviation to minimise

% Get solution for bin boundaries
nc=numel(xc);
dm1=ones(nc+1,1);
d0=[-1;ones(nc,1)];
dp1=[0;1;zeros(nc-1,1)];
A=0.5*spdiags([dm1,d0,dp1],[-1,0,1],nc+1,nc+1);
xb=A\[del;xc(:)];

% % Measure of the deviation from the mid-points of the supplied bin centres.
% xc_mid=0.5*(xc(2:end)+xc(1:end-1));
% xc_sep=diff(xc);
% % dev=sum(abs(xb(2:end-1)-xc_mid(:)));    % sum of absolute deviations
% % dev=sum((xb(2:end-1)-xc_mid(:)).^2);    % sum of squared deviations
% % dev=sum(abs(xb(2:end-1)-xc_mid(:)).^20);    % sum of high power of deviations
% % dev=max(abs(xb(2:end-1)-xc_mid(:)));    % minimise the maximum deviation
% dev=max(abs(xb(2:end-1)-xc_mid(:))./xc_sep(:));    % minimise the maximum deviation as fraction of separation between bin centres

% Try to maximise the entropy
bin_size=diff(xb);
bin_size=bin_size./sum(bin_size); % normalised bin sizes
dev=sum(bin_size.*log(bin_size));


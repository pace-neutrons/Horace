function [xb,output]=bin_boundaries_opt(xc)
% Get best estimate of bin boundaries as a row vector
%
%   >> xb=bin_boundaries(xc)
%
%       xc  Vector of point positions
%       xb  Vector of bin boundaries; same orientation (i.e row or column) as input
%
% Does some elementary checks on the input bin centres (more than one, strictly monotonic increasing)
% and checks if all equally spaced.

% T.G.Perring, 7 September 2009

if numel(xc)<=1
    error('Must have at least two bin centres')
end
if ~isvector(xc)
    error('Input array must be a vector')
end
del=diff(xc);
if any(del<=0);
    error('Bin centres must be strictly monotonic increasing')
end

if all(del==del(1))
    xb=[xc(:)-del(1)/2;xc(end)+del(1)/2];
    output=[];
else
    del_max=xc(2)-xc(1);    % Maximum possible value for half width of first bin
    [del,fval,exitflag,output]=fminbnd(@(x) bin_boundaries_special(xc,x),0,del_max,optimset('TolX',1e-12));

    % Get boundaries at the optimum value of del
    [tmp,xb]=bin_boundaries_special(xc,del);
    if ~isreal(xb)
        error('Complex solution for bin boundaries')    % e.g. xc=[2,4,5]
    elseif any(diff(xb)<=0)
        error('Solution for bin boundaries not strictly monotonic')
    end
end
if size(xc,1)==1, xb=xb'; end

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


function xb=bin_boundaries_simple(xc)
% Get simple set of bin boundaries - set at halfway between points
%
%   >> xb=bin_boundaries_simple(xc)
%
%   xc  Vector of point positions, assumed monotonic increasing
%   xb  Vector of bin boundaries; same orientation (i.e row or column) as input
%
% If one point only, then bin boundaries are set to row vector [x-0.5,x+0.5]

if numel(xc)>1
    if any(diff(xc)<=0);
        error('Bin centres must be strictly monotonic increasing')
    end
    if isvector(xc)
        if size(xc,1)>1, row=false; else row=true; end
        xc=xc(:);
        if numel(xc)>2
            del0=0.5*(xc(2)-xc(1));
            del1=0.5*(xc(end)-xc(end-1));
            xb=[xc(1)-del0; 0.5*(xc(2:end)+xc(1:end-1)); xc(end)+del1];
        else
            del=0.5*(xc(2)-xc(1));
            xb=[xc(1)-del; 0.5*(xc(2)+xc(1)); xc(2)+del];
        end
        if row, xb=xb'; end
    else
        error('Input array must be a vector')
    end
elseif numel(xc)==1
    xb=[xc-0.5,xc+0.5];
else
    error('No points in input array')
end

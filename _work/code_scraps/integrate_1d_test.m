function [sout,eout]=integrate_1d_test (x,s,e,b)
%
%   x   x coords of points
%   b   boundaries of integration ranges (numel(b)>=2)

nx=numel(x);
nb=numel(b)-1;

sout=zeros(1,nb);
eout=zeros(1,nb);

% Check that there is an overlap between the integration range and the points
if x(end)<=b(1) || b(end)<=x(1)
    return
end 

% Get to starting output bin and input data point
if b(1)>=x(1)
    ml=lower_index(x,b(1));     % b(1) <= x(ml)
    ib=1;
else
    ml=1;
    ib=upper_index(b,x(1));     % b(ib) <= x(1)
end

% At this point, we have b(ib)<=x(ml) for the first output bin, index ib, that overlaps with input data range
% Now get mu s.t. x(mu)<=b(ib+1)
while ib<=nb
    mu=ml-1;    % can have mu=ml-1 if there are no data points in the interval [b(ib),b(ib+1)]
    while mu<nx && x(mu+1)<=b(ib+1)
        mu=mu+1;
    end
    % Gets here if (1) x(mu+1)>b(ib+1), or (2) mu=nx in which case the last x point is in output bin index ib
    [sout(ib),eout(ib)]=single_integrate_1d_points(x,s,e,b(ib),b(ib+1),ml,mu);
    % Update ml for next output bin
    if mu==nx || ib==nb
        return  % no more output bins in the range [x(1),x(end)], or completed last output bin
    end
    ib=ib+1;
    if x(mu)<b(ib)
        ml=mu+1;
    else
        ml=mu;
    end
end

%----------------------------------------------------------------------------
function [sout,eout]=single_integrate_1d_points(x,s,e,blo,bhi,ml,mu)
sout=ml;
eout=mu;

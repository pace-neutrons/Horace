function xb=rebin_boundaries_for_rebin(x,point)
% Bin boundaries for rebin and regroup routines. Needs to catch case when just one point
% The rebin or regroup routine is assumed to set finite bounds from the rebin descriptor
if point
    xb=bin_boundaries_simple(x);
    if numel(xb)==2
        xb=[-Inf,Inf];
    end
else
    xb=x;
end

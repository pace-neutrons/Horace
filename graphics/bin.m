function bin (n)
% Alter the binning for 1D graphics display.
%
%   >> bin(n)   % n=0 or n=1 corresponds to no binning being applied

% Display current value if no input argument
if nargin==0
    binning=get_global_var('genieplot','oned_binning');
    disp(['Present 1D graphics binning = ' num2str(binning)])
    return
end

small = 1.0e-10;
if isnumeric(n) && isscalar(n)
    binning=round(double(n));   % account for int32 uint8 etc
    if abs(binning-double(n))>small || binning<0
        error('Graphics binning must be an integer >= 0')
    end
    set_global_var('genieplot','oned_binning',binning);
end

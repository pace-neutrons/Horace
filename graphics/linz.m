function linz
% Change the z-axis to a linear scale for current and subsequent plots.
%
%   >> linz

% Change for future plots
zscale = 'linear';
set_global_var('genieplot','zscale',zscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'ZScale', zscale);
end

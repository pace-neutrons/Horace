function logz
% Change the z-axis to a logarithmic scale for current and subsequent plots.
%
%   >> logz

% Change for future plots
zscale = 'log';
set_global_var('genieplot','zscale',zscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'ZScale', zscale);
end

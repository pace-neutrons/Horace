function linx
% Change the x-axis to a linear scale for current and subsequent plots.
%
%   >> linx

% Change for future plots
xscale = 'linear';
set_global_var('genieplot','xscale',xscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'XScale', xscale);
end

function liny
% Change the y-axis to a linear scale for current and subsequent plots.
%
%   >> liny

% Change for future plots
yscale = 'linear';
set_global_var('genieplot','yscale',yscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'YScale', yscale);
end

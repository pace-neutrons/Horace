function logy
% Change the y-axis to a logarithmic scale for current and subsequent plots.
%
%   >> logy

% Change for future plots
yscale = 'log';
set_global_var('genieplot','yscale',yscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'YScale', yscale);
end

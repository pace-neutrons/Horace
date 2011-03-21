function logx
% Change the x-axis to a logarithmic scale for current and subsequent plots.
%
%   >> logx

% Change for future plots
xscale = 'log';
set_global_var('genieplot','xscale',xscale);

% Change current plot (if there is one)
if ~isempty(findall(0,'Type','figure'))
    set (gca, 'XScale', xscale);
end

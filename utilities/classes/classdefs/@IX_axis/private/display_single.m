function display_single (w)
% Display IX_axis object to screen
%
%   >> display_single(w)

% Original author: T.G.Perring

if isempty(w.ticks.positions) && isempty(w.ticks.labels)
    disp(rmfield(struct(w),'ticks'))
else
    disp(struct(w))
end

function wout = compact(win)
% Squeezes the data range in the dnd image of an sqw object to
% eliminate empty bins on borders
%
% Particularly of use for compacting dnds for removing excess
% whitespace from plotting
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input sqw object
%
% Output:
% -------
%
%   wout        Output sqw object, which is a copy of win with length of axes
%               in its dnd component reduced to yield the smallest
%               cuboid that contains the non-empty bins.
%

% Initialise output argument
wout = copy(win);

%Loop over the number of inputs objects:
for n = 1:numel(win)
    wout(n).data = win(n).data.compact();
end

end

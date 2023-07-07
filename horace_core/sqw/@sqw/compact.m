function wout = compact(win)
% Squeezes the data range in an sqw object to eliminate empty bins on
% borders
%
% Particularly of use for contracting dnds for plotting
%
% Syntax:
%   >> wout = compact(win)
%
% Input:
% ------
%   win         Input object
%
% Output:
% -------
%   wout        Output object, with length of axes reduced to yield the
%               smallest cuboid that contains the non-empty bins.
%

% Initialise output argument
wout = copy(win);

%Loop over the number of inputs objects:
for n = 1:numel(win)
    wout(n).data = win(n).data.compact();
end

end

function [state, old_state] = seed_rng(seed)
% Seed Matlab's random number generator
%   If no explicit seed is passed to this function, a new seed will be
%   generated using the current time.

old_state = rng();
if nargin < 1
    seed = mod(posixtime(datetime('now'))*1e3, 1e6);
end
rng(seed);
state = rng();

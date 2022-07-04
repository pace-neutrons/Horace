% Fit 5 datasets simultaneously to Gaussians which are constrained to have
% the same position but can have different widths and heights. They are
% on independent linear backgrounds.
%
%   >> f = mfclass (w1,w2,w3,w4,w5);
%   >> f = f.set_local_foreground;        % change default
%   >> f = f.set_fun (@gaussian);
%   >> f = f.set_pin ([100,25,0.5]);  % could have just done f.set_fun (@gaussian,[100,25,0.5])
%   >> f = f.set_bind ({[2,2],[1,1]}, {[2,3],[1,1]}, {[2,4],[1,1]}, {[2,5],[1,1]});
%   >> f = f.set_bfun (@straight_line, [0,0]]);
%   >> for ifun=2:5
%   >>     f = f.set_bbind (ifun, {1,[1,1]}, {2,[2,1]})
%   >> end
%
% An alternative syntax is available for the binding: when the functions are local
% then you can specify that all parameters with the same index are bound together
%
%   >> ipar = 2;    % second parameter (in this case the position of the Gaussian)
%   >> f = f.set_bind_all (ipar)    % bind then all with the current ratios (looks for a non-zero value to use as 'master')
%   >> f = f.set_bind_all (ipar, [NaN, 1, 1, 1, 1])    % The first function is taken as the 'master'
%   >> f = f.set_bind
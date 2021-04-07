function wout = sigvar(w)
% Create sigvar object from input testsigvar object
%
%   >> wout = sigvar(w)


wout = sigvar(w.s, w.e, w.msk);

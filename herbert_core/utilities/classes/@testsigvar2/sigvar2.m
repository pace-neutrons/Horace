function wout = sigvar2(w)
% Create sigvar object from input testsigvar object
%
%   >> wout = sigvar(w)


wout = sigvar2(w.s, w.e, w.msk);

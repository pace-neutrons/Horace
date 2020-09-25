function [mod_opts,ok,mess] = tobyfit_refine_moderator_options(varargin)
% *** Obsolete function ***
%
% This function was used with the obsolete Tobyfit syntax
% Please migrate to the new Tobyfit syntax supported since January 2018'
% For details of the new syntax:  <a href="matlab:doc(''sqw/tobyfit'');">Click here</a>'

mess = ['\nThis function was used with the obsolete Tobyfit syntax.',...
    '\nPlease migrate to the new Tobyfit syntax supported since January 2018',...
    '\nFor details of the new syntax:  <a href="matlab:doc(''sqw/tobyfit'');">Click here</a>'];
error('Tobyfit:legacySyntax',mess)

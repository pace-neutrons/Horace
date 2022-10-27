function out_str = disp2str(in_obj)
% Return string value of an input object as obtained from 'disp' function
% but without leading and traling control characters and whitespaces.
%
% Normally used for reporting incorrect values of arbitrary objects
% in call 'error' function
% Usage:
% >>out_str = dist2str(in_obj)
% where:
% in_obj  -- the input object to convert to string using internal Matlab
%            'disp' function
% out_str -- the string the object is converted to.

out_str = strtrim(evalc('disp(in_obj)'));

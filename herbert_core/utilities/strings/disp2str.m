function out_str = disp2str(in_obj)
% Return string value of an input object as obtained from 'disp' function
% but without leading and trailing control characters and whitespaces.
%
% Normally used for reporting incorrect values of arbitrary objects
% in call 'error' function
% Usage:
% >>out_str = disp2str(in_obj)
% where:
% in_obj  -- the input object to convert to string using internal Matlab
%            'disp' function
% out_str -- the string the object is converted to.
stl = evalc('disp(in_obj)');
sts = strsplit(stl,newline);
not_empty = cellfun(@(x)~isempty(x),sts);
sts = cellfun(@strtrim,sts(not_empty),'UniformOutput',false);
out_str = strjoin(sts,newline);


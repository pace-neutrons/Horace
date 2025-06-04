function out_str = disp2str(in_obj,constraint_length,constraint_text)
% Return string value of an input object as obtained from 'disp' function
% but without leading and trailing control characters and whitespaces.
%
% Normally used for reporting incorrect values of arbitrary objects
% in call 'error' function
% Usage:
% >>out_str = disp2str(in_obj);
% >>out_str = disp2str(in_obj,constraint_length);
% >>out_str = disp2str(in_obj,constraint_length,constraint_text);
% Inputs:
% in_obj  -- the input object to convert to string using internal MATLAB
%            'disp' function
% Optional:
% constraint_length
%         -- if provided, maximum length the output string beyond which
%            it is truncated.
% constraint_text
%         -- the text which is appended when the length of the string
%            is truncated. Default value: "...truncated."
% Output:
% out_str -- the string the object is converted to.
%            If constraint_length is provided, the string is truncated to
%            up to specified number of characters accompanied by constraint
%            text. I.g. if you do: s= disp2str(1:100,80)
%            The result would be:
%      'Columns 1 through 18
%       1     2     3     4     5     6     7     8     9    10    ...truncated.'
stl = evalc('disp(in_obj)');
sts = strsplit(stl,newline);
not_empty = cellfun(@(x)~isempty(x),sts);
sts = cellfun(@strtrim,sts(not_empty),'UniformOutput',false);
out_str = strjoin(sts,newline);
if nargin<2
    return
end
if ~isnumeric(constraint_length) || constraint_length<1
    error('HERBERT:utilities:invalid_argument', ...
        'Constraint length, if provided should be positive number larger then 1')
end
if nargin<3
    constraint_text = '...truncated.';
else
    if ~istext(constraint_text)
        error('HERBERT:utilities:invalid_argument', ...        
            'constraint text, if provided, should be a text string. Provided class: "%s"', ...
            class(constraint_text));
    end
end
if strlength(out_str)>constraint_length
    out_str = extractBetween(out_str,1,constraint_length);
    out_str = [out_str{:},constraint_text];    
end



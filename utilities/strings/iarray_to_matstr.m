function str=iarray_to_matstr (val,lenlin)
% Convert array of integers to string with compressed form
%
%   >> str = iarray_to_matstr (val)
%   >> str = iarray_to_matstr (val,lenlin)
%
% Input:
% ------
%   val     Integer array (converted to row vector)
%   lenlin  [Optional] maximum length of a line
%           Default: Inf (so that all in one string
%
% Output:
% -------
%   str     Character string of form '[n1:n2,n3,...]'
%           Contiguous ranges in the array val are converted to n1:n2 (ascending)
%          or n1:-1:n2 (descending).
%           If spans more than one line, output will be a cell array (column) of form
%          e.g. str{1}='[n1:n2,n3,...'
%               str{2}='    n4:n5,n6]'
%
%
% EXAMPLE
%   >> iarray_to_matstr([-5,-4,-3,21,20,19,5,7,9,10,11,12])
%   ans =
%       '[-5:-3,21:-1:19,5,7,9:12]'
%
%   >> iarray_to_matstr([-5,-4,-3,21,20,19,5,7,9,10,11,12],20)
%   ans = 
%       '[-5:-3,21:-1:19,...'
%       '    5,7,9:12]'

if nargin==1
    tmp=iarray_to_str(val,Inf,'m');
else
    tmp=iarray_to_str(val,lenlin,'m');
end

if numel(tmp)==1
    if ~isempty(tmp)
        tmp=str_compress(tmp,',');
        str=['[',tmp{1},']'];
    else
        str=[];
    end
else
    tmp=str_compress(tmp,',');
    str=cell(numel(tmp),1);
    str{1}=['[',tmp{1},',...'];
    for i=2:numel(str)-1
        str{i}=['    ',tmp{i},',...'];
    end
    str{end}=['    ',tmp{end},']'];
end

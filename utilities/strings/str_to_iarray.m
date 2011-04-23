function x = str_to_iarray (string)

% Reads an array of integers from a character string, interpreting the following delimited tokens
%        single integers: 'mmm', '-mmm'
%       list of integers: 'mmm-nnn', '-mmm-nnn', 'mmm--nnn', '-mmm--nnn'
% Any tokens that do not conform to the above are ignored.

% Find positions of tokens:
%  [Add final position, so that beg(i):beg(i+1) contains a token, including any trailing delimiters
%  which it turns out that sscanf happily ignores]
delim=[0,sort([strfind(string,char(9)),strfind(string,char(32)),strfind(string,',')]),length(string)+1];
beg=[delim(find(diff(delim)>1))+1,length(string)+1];

x=[];
if length(beg)>1
    for i = 1:length(beg)-1
        x=[x,str_token_to_iarray(string(beg(i):beg(i+1)-1))];
    end
end


%-------------------------------------------------------------------------------------
% The above replaced the following code, which turns out to be rather slow
 
% function x = str_to_iarray (input_string)
% 
% delimiters = [char(9) char(32) ','];
% remainder = input_string;
% x=[];
% 
% while (any(remainder))
%   [chopped,remainder] = strtok(remainder,delimiters);
%   x=[x,str_token_to_iarray(chopped)];
% end
%-------------------------------------------------------------------------------------

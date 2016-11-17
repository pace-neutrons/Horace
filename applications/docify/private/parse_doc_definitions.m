function [S_out,ok,mess]=parse_doc_definitions(cstr,args,S)
% Accumulate the values of variables from the documentation definitions block.
%
%   >> [S_out,ok,mess]=parse_doc_definitions(cstr,args,S)
%
% Input:
% ------
%   cstr    Cell array of strings, all beginning with '%'. Assumed trimmed
%          of leading and trailing whitespace. These can be any valid
%          lines of code that define variables as:
%               - logical scalar (or 0 or 1)
%               - a string
%               - a cell array of strings
%           Any assignments to the strings '#1', '#2', ... (up to the number
%          of arguments in args, below) will be substituted by the 
%          corresponding element of args.
%           If you want a variable to actually be the character string '#1',
%          then in the definition block give it the value '\#1'. Similarly,
%          if you actually want the varaible to be '\#1' use '\\#1' etc.
%
%   args    Cell array of arguments (each must be a string or cell array of
%          strings or logical scalar (or 0 or 1)
%
%   S       Structure whose fields are the names of variables and their
%          values. Fields can be:
%               - string
%               - cell array of strings (column vector)
%               - logical true or false (retain value for blocks)
%
% Output:
% -------
%   S_out   Updated structure whose fields are the names of variables and
%          their values.
%
%   ok      If all OK, then true; otherwise false
%
%   mess    Error message if not OK; empty if all OK
%               
%
% EXAMPLE: (lines can have comments at the end or terminal semi-colons)
%
%   % main = 1
%   % fname = 'c:\temp\weasel.txt'
%   % lines = {'% c:\temp\weasel.txt','% hello'...
%   %            '% there'}
%   % warn = '#1'           % warn will be set to arg{1}
%   % odd_string = '\#1'    % odd_string will be set to '#1'


% Parse the definition block
[Snew, ok, mess] = parse_doc_definitions_block_vals (cstr);
if ~ok
    S_out=struct([]);
    return
end

% Check the contents
if isempty(Snew)    % Nothing to add
    S_out=S;
    ok=true;
    mess='';
    return
end

% Check that all variables have one of the valid forms
name=fields(Snew);
for i=1:numel(name)
    value=Snew.(name{i});
    if iscellstr(value) || islognumscalar(value) || is_string(value)
        if islognumscalar(value)
            Snew.(name{i})=logical(value);          % convert to scalar logical
        elseif iscellstr(value)
            Snew.(name{i})=str_trim_cellstr(value); % remove blank lines and trim
        else
            Snew.(name{i})=strtrim(value);          % trim
        end
    else
        S_out=struct([]);
        ok=false;
        mess=['''',name{i},''' must be set to a character string,'...
            ' cell array of strings or logical scalar (or 0 or 1)'];
        return
    end
end

% Substitute arguments
for i=1:numel(name)
    [val_out,changed,ok,mess]=parse_doc_definitions_subst_arg(Snew.(name{i}),args);
    if ok && changed
        Snew.(name{i})=val_out;
    elseif ~ok
        S_out=struct([]);
        mess=['''',name{i},''' : ',mess];
        return
    end
end

% Accumulate new definitions
S_out=mergestruct(Snew,S);

% Succesful return
ok=true;
mess='';

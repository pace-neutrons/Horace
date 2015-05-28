function [var,iskey,isend,args,ok,mess]=parse_key(str)
% Determine if a line consists solely of keywords or logical block names
%
%   >> [var,iskey,isend,args,ok,mess]=parse_key(str)
%
% Input:
% ------
%   str     Character string. Assumed to be non-empty and trimmed.
%
% Output:
% -------
%   var     Name of keyword or logical. Empty if not.
%   iskey   Flag: =true if keyword (i.e. begins with '#'; false if logical
%   isend   Flag: =true if has form /end
%   args    Cell array of arguments. This can be non-empty only if a
%          keyword without /end
%   ok      =true if a valid keyword or logical block name
%               [%][white_space]<#varname[/end]:>  arg1 arg2 ...
%           OR  [%][white_space]<block_name[/end]:>
%           =false if not
%   mess    Message if not ok (empty otherwise)


% Default return (corresponds to valid line with no keyword or block name)
var='';
iskey=false;
isend='';
ok=true;
mess='';
args={};

% Parse string
if str(1)=='%'
    iscomment=true;
    str=strtrim(str(2:end));
    if isempty(str)
        ok=false;
        return
    end
else
    iscomment=false;
end

if length(str)>3 && str(1)=='<'
    ind=strfind(str,'>');
    if ind>0
        ind=ind(1);
        nam=strtrim(str(2:ind-1));
        arglist=strtrim(str(ind+1:end));
    else
        if ~iscomment
            ok=false;
            mess=['Invalid line: ',str];
        end
        return
    end
    % Find a keyword or block name
    [tok,remain]=strtok(nam,':');
    if isempty(remain) || ~isempty(strtrim(remain(2:end)))
        ok=false;
        mess=['Invalid construct: ',str(1:ind),' in line: ',str];
        return
    end
    if ~isempty(tok)
        if tok(1)=='#'
            iskey=true;
            tok=tok(2:end);
        else
            iskey=false;
        end
    else    % neither a keyword or block name
        if ~iscomment
            ok=false;
            mess=['Invalid construct: ',str(1:ind),' in line: ',str];
        end
        return
    end
    % Determine if /end applies
    [var,isend,ok,mess]=parse_name(tok);
    if ~ok
        iskey=false;    % ensure set back to default
        mess=[mess,' in line: ',str];
        return
    end
    % Get arguments - only valid if keyword without /end
    if ~isempty(arglist)
        if iskey && ~isend
            args=strsplit(arglist);
        else
            var='';
            iskey=false;
            isend=false;
            ok=false;
            mess=['Cannot have following arguments in line:',str];
            return
        end
    end
else
    ok=false;
    mess=['Invalid line: ',str];
    return
end

%------------------------------------------------------------------------------
function [var,isend,ok,mess]=parse_name(str)
% Determine if form is var_name/end

var='';
isend=false;
ok=true;
mess='';

[tok,remain]=strtok(str,'/');
tok=strtrim(tok);
opt=strtrim(remain(2:end));
if isvarname(tok)
    if strcmpi(opt,'end')
        isend=true;
    elseif isempty(remain)
        isend=false;
    else
        ok=false;
        mess=['Invalid option: ',remain];
    end
    var=tok;
else
    ok=false;
    if ~isempty(tok)
        mess=['Invalid name: ',tok];
    else
        mess='Missing name';
    end
end

%------------------------------------------------------------------------------
function v=strsplit(str)
% Get a cell array of tokens separated by whitespace
remain=str;
v={};
while true
    [tok,remain]=strtok(remain);
    if ~isempty(tok)
        v=[v,tok];
    else
        break
    end
end

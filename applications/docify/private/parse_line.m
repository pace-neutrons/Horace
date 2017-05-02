function [ok, mess, var, iskey, isblock, isdcom, issub, ismcom, args, isend] = parse_line (cstr)
% Determine if a line is keyword, block name, docify comment, or Matlab comment line
%
%   >> [ok, mess, var, iskey, isblock, isdcom, issub, ismcom, args, isend] = parse_line (cstr)
%
% Input:
% ------
%   cstr    Character string. Assumed to be non-empty and trimmed of leading
%          and trailing whitespace.
%
% Output:
% -------
%   ok      =true if a valid line for
%               - keyword:              [%][white_space]<#keyword:>  arg1 arg2 ...
%               - logical block name:   [%][white_space]<block_name[/end]:>
%               - docify comment:       [%][white_space]<<-...
%               - line replacement:     <var_name>
%               - Matlab comment:       %...
%           =false if not
%   mess    Empty if OK; error message if not.
%   var     Keyword or block name. Empty if neither. Always set to lower case.
%   iskey   Flag: =true if keyword (i.e. begins with '#')
%   isblock Flag: =true if block name
%   isdcom  Flag: =true if docify comment line (i.e. begins with '<<-')
%   issub   Flag: =true if line substitution name
%   ismcom  Flag: =true if matlab comment line
%   args    Cell array of arguments (row vector). This can be non-empty only
%          in the case of a keyword 
%   isend   Flag: =true if block name and has form /end


% Default return (corresponds to valid line with no keyword, block name or docify comment)
var='';
iskey=false;
isblock=false;
isdcom=false;
issub=false;
ismcom=false;
args={};
isend=false;
ok=true;
mess='';

% Determine if string starts with '%' or notstring
if cstr(1)=='%'
    if length(cstr)==1
        % string is simply '%' which must be a valid matlab comment; a common case
        % so handle right now
        ismcom=true;
        return
    end
    cstr=strtrim(cstr(2:end));
    iscomment_line=true;
else
    iscomment_line=false;
end

% Determine type of string
if length(cstr)>=3 && strcmp(cstr(1:3),'<<-')
    % Determine if a docify comment line
    isdcom=true;
    
elseif ~iscomment_line && length(cstr)>=3 && cstr(1)=='<' && cstr(end)=='>' &&...
        isvarname(cstr(2:end-1))
    % Determine if line substitution
    var=lower(cstr(2:end-1));
    issub=true;
    
elseif length(cstr)>3 && cstr(1)=='<'
    % Determine if keyword or block name
    % Look for start of form: '<x:>' where x is at least one character long
    ind=strfind(cstr,':>');
    if ~isempty(ind)
        ind=ind(1);
        nam=cstr(2:ind-1);
        arglist=strtrim(cstr(ind+2:end));    % the stuff that follows <...:>
    else
        if iscomment_line
            ismcom=true;
        else
            ok=false;
            mess='Invalid line';
        end
        return
    end
    % Find a keyword or block name
    if length(nam)>1 && strcmp(nam(1),'#') && isvarname(nam(2:end))
        % Has form <#var_name:>
        var=lower(nam(2:end));
        iskey=true;
        if ~isempty(arglist)
            tmp=textscan(arglist,'%s');
            args=tmp{1}';
        end
    elseif length(nam)>4 && strcmpi(nam(end-3:end),'/end') &&...
            isvarname(nam(1:end-4)) && isempty(arglist)
        % Has form <var_name/end:>
        var=lower(nam(1:end-4));
        isblock=true;
        isend=true;
    elseif ~isempty(nam) && isvarname(nam) && isempty(arglist)
        % Has form <var_name:>
        var=lower(nam);
        isblock=true;
    else
        if iscomment_line
            ismcom=true;
        else
            ok=false;
            mess='Invalid line';
        end
    end
    
else
    if iscomment_line
        ismcom=true;
    else
        ok=false;
        mess='Invalid line';
    end
end

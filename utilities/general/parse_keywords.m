function [ok,mess,ind,val]=parse_keywords(keywords,varargin)
% Simple verification that argument list has form: key1, val1, key2, val2, ...
%
%   >> [ok,mess,ind,val]= parse_keywords (keywords, key1, val1, key2, val2, ...)
%
% Input:
% ------
%   keywords        Cell array of strings containing the keywords
%   key1, key2, ... Keywords
%   val1, val2, ... Associated values
%
% Output:
% -------
%   ok              =true all ok, otherwise =false
%   mess            Empty if ok, otherwise contains error message
%   ind             Index of supplied keyword(s) into list of valid keywords
%   val             Cell array of corresponding values (empty cell array if none found)
%
% Notes:
%  - Simple function: it is assumed that the keywords are all different
%  - does not check that keywords are a cell array of strings

% T.G.Perring 20/3/11: Changes w.r.t. Libisis and mgenie version
%  - now check for unambiguous abbreviations

narg=numel(varargin);
if rem(narg,2)~=0
    ind=[]; val=[]; ok=false; mess='Check number of arguments'; return
end
% if~iscellstr(keywords)
%     ind=[]; val=[]; ok=false; mess='Check list of valid keywords is a cell array of strings'; return
% end

i=1;
ind=zeros(1,narg/2);
val=cell(1,narg/2);
keyword_appeared=false(1,numel(keywords));

while i <= narg/2
    name = varargin{2*i-1};
    if ~ischar(name) || size(name,1)~=1 || isempty(name)
        ind=[]; val={}; ok=false; mess='Keywords must be must be character strings'; return
    end
    tmp=find(strncmpi(name,keywords,length(name)));
    if numel(tmp)>1 % more than one match, see if can find an exact length match
        tmp=find(strcmpi(name,keywords));
        if isempty(tmp)
            ind=[]; val={}; ok=false; mess='Ambiguous abbreviation of a keyword - check input'; return
        elseif numel(tmp)>1
            ind=[]; val={}; ok=false; mess='List of keywords is in error - problem in calling program'; return
        end
    end
    if numel(tmp)==1
        if ~keyword_appeared(tmp)
            ind(i)=tmp;
            val{i}=varargin{2*i};
            keyword_appeared(tmp)=true;
        else
            ind=[]; val={}; ok=false; mess='A keyword appears more than once - check input'; return
        end
    elseif isempty(tmp)
        ind=[]; val={}; ok=false; mess='Unrecognised keyword - check input'; return
    end
    i=i+1;
end
ok=true;
mess='';

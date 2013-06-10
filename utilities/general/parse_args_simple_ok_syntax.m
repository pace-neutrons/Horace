function [ok,mess,par,ind,val]=parse_args_simple_ok_syntax (keywords,varargin)
% Simple verification that argument list has form: par1, par2, par3, ..., key1, val1, key2, val2, ...
%
%   >> [ok,mess,par,ind,val]= ...
%         parse_args_simple_ok_syntax (keywords, par1, par2, ..., key1, val1, key2, val2, ...)
%
% Input:
% ------
%   keywords        Cell array of strings containing the keywords
%   par1, par2 ...  Arguments (end of list determined by appearance of a key word in keywords)
%   key1, key2 ...  Keywords
%   val1, val2 ...  Associated values
%
% Output:
% -------
%   ok              =true all ok, otherwise =false
%   mess            Empty if ok, otherwise contains error message
%   par             Cell array of the leading parameters (1xn)
%   ind             Index of supplied keyword(s) into list of valid keywords
%   val             Cell array of corresponding values (empty cell array if none found)
%
% Notes:
%  - Simple function: it is assumed that the keywords are all different
%  - does not check that keywords are a cell array of strings
%

% Determine start of valid keywords
ikeystart=numel(varargin)+1;
for i=1:numel(varargin)
    if ischar(varargin{i}) && ~isempty(varargin{i}) && size(varargin{i},1)==1 &&...
            any(strncmpi(varargin{i},keywords,length(varargin{i})))
        ikeystart=i;
        break
    end
end

% Check validity
if ikeystart<=numel(varargin)   % at least one keyword
    [ok,mess,ind,val]=parse_keywords(keywords,varargin{ikeystart:end});
    if ~ok, par=cell(1,0); return, end
else
    ok=true;
    mess='';
    ind=[];
    val={};
end

% Fill remaining output arguments
if nargout>=3   % only create this extra argument if required
    if ikeystart>1
        par=varargin(1:ikeystart-1);
    else
        par=cell(1,0);
    end
end

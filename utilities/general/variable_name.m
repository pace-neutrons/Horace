function varname = variable_name (name,iscell,sz,ind,defname)
% Create string with array index from name, if cell, size, and linear index
% If scalar then no index string is appended
% If name is empty, then uses defname (default name) if given, else uses 'arg'
%
% EXAMPLE
%   variable_name ('myvar',false,[3,4],5)   ==>  'myvar(2,2)'
%   variable_name ('myvar',true, [3,4],5)   ==>  'myvar{2,2}'
%   variable_name ('myvar',false,[1,1],1)   ==>  'myvar'
% If a vector, then just a linear index:
%   variable_name ('myvar',false,[3,1],2)   ==>  'myvar(2)'

if prod(sz)~=1
    if iscell
        str = ['{',arraystr(sz,ind),'}'];
    else
        str = ['(',arraystr(sz,ind),')'];
    end
else
    str = '';
end

if ~isempty(name)
    varname = [name,str];
else
    if nargin==5 && ~isempty(defname)
        varname = [defname,str];
    else
        varname = ['arg',str];
    end
end


%--------------------------------------------------------------------------------------------------
function str=arraystr(sz,i)
% Make a string of the form '2,3,1' (or '23' if vector) from a size array and single index

if numel(sz)==2 && (sz(1)==1||sz(2)==1)
    str=num2str(i);
else
    ind=cell(1,numel(sz));
    [ind{:}]=ind2sub(sz,i);
    str='';
    for j=1:numel(ind)
        str=[str,num2str(ind{j}),','];
    end
    str=str(1:end-1);
end

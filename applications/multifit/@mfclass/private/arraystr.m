function str=arraystr(sz,i)
% Make a string of the form '[2,3,1]' (or '23' if vector) from a size array and single index


% Original author: T.G.Perring
%
% $Revision:: 830 ($Date:: 2019-04-08 17:54:30 +0100 (Mon, 8 Apr 2019) $)


if numel(sz)==2 && (sz(1)==1 ||sz(2)==1)
    str=num2str(i);
else
    ind=cell(1,numel(sz));
    [ind{:}]=ind2sub(sz,i);
    str='[';
    for j=1:numel(ind)
        str=[str,num2str(ind{j}),','];
    end
    str(end:end)=']';
end

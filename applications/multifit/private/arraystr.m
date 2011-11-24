function str=arraystr(sz,i)
% Make a string of the form '[2,3,1]' from a size array and single index
ind=cell(1,numel(sz));
[ind{:}]=ind2sub(sz,i);
str='[';
for j=1:numel(ind)
    str=[str,num2str(ind{j}),','];
end
str(end:end)=']';

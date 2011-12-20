function namecell=contents_to_namecellstr(contents,ind)
% Make a cellstr from the names of the indicated contents from a call to dir 
n=numel(ind);
namecell=cell(1,n);
for i=1:n
    namecell{i}=contents(ind(i)).name;
end

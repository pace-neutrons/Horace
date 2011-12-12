function delta_IX_dataset_nd_struct(w1,w2,varargin)

fname1=sort(fields(w1));
fname2=sort(fields(w2));

if ~isequal(fname1,fname2)
    error('Structures do not have the same fields')
end

for i=1:numel(fname1)
    if numel(w1.(fname1{i}))~=numel(w1.(fname1{i}))
        error('Number of elements do not match')
    end
end

for i=1:numel(fname1)
    for j=1:numel(w1.(fname1{i}))
        disp([num2str(i),'  ',num2str(j)])
        delta_IX_dataset_nd(w1.(fname1{i})(j),w2.(fname2{i})(j),varargin{:});
    end
end




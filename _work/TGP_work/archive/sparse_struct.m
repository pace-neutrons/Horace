function S=sparse_struct(S0)
% Convert numeric arrays in a structure to sparse arrays

nams=fieldnames(S0)';
emptycells=repmat({{}},1,numel(nams));
args=[nams;emptycells];
S=struct(args{:});

for i=1:numel(nams)
    if isnumeric(S0.(nams{i})) && numel(S0.(nams{i}))>1
        S.(nams{i})=sparse(S0.(nams{i}));
    end
end

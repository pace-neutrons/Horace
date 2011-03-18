function cout = str_trim_cellstr(cin)
% trim leading and trailing whitespace and remove empty strings from a cellstr
ok=true(size(cin));
cout=strtrim(cin);
for i=1:numel(cout)
    ok(i)=~isempty(cout{i});
end
cout=cout(ok);

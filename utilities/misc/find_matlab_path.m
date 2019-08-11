function matlab_path = find_matlab_path()
%
% found path where current matlab session is started from
%
cs = regexp(path,pathsep,'split');
for i=1:numel(cs)
    if ~isempty(regexp(cs{i},'toolbox','once'))
        sp = regexp(cs{i},'toolbox','split');
        matlab_path = fullfile(sp{1},'bin');
        return;
    end
end
matlab_path = '';

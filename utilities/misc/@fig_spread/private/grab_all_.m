function obj = grab_all_(obj,varargin)
% retrieve all existing (plotted) figures under the class
% control for further operations (e.g. replotting)

if verLessThan('matlab','8.4')
    figHandles = get(0, 'Children');      % Earlier versions
else
    figHandles = get(groot, 'Children');  % Since version R2014b
end
if verLessThan('matlab','8.4')
    existing_num  = [obj.fig_list_{:}];
    all_num = figHandles;
else
    existing_num = cellfun(@(fg)(get(fg,'Number')),obj.fig_list_);
    all_num = arrayfun(@(fg)(get(fg,'Number')),figHandles);    
end
existing_num = sort(existing_num);

[all_num,all_ind] = sort(all_num);

existing = ismember(all_num,existing_num);
new_ind = all_ind(~existing);
if ~isempty(new_ind)
    obj.fig_list_(end+1:end+numel(new_ind)) = num2cell(figHandles(new_ind))';
end
obj.fig_count_ = numel(obj.fig_list_);

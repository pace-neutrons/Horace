function self = load_figs_(self,filename)
% load previously saved figs to memory, add then to
% fig controlled list and replot all
if ~(exist(filename,'file')==2)
    if exist([filename,'.fig'],'file')==2
        filename = [filename,'.fig'];
    else
        error('FIG_SPREAD:invalid_argument',...
            'Can not find figures file: %s',filename);
    end
end

figs = openfig(filename);
nfigs = numel(figs);
n_tot_figs = self.fig_count_+nfigs;
% cell2num does not work for cellarray of fig handles
fig_there = cellfun(@(x)(x), self.fig_list_);
fig_list = [fig_there;figs'];
% exclude figures with the same handles
[~,ind]  = sort(fig_list);
fig_list = fig_list(ind);
ind = 1:n_tot_figs-1;
valid = (fig_list(ind)~=fig_list(ind+1));
valid = [true;valid];
fig_list = fig_list(valid);

n_tot_figs = numel(fig_list);

% Store resulting figs
self.fig_list_ = num2cell(fig_list,n_tot_figs);
self.fig_count_ = n_tot_figs;

self = self.replot_figs('-rise');

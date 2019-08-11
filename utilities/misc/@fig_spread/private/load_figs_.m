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
if size(figs,1)==1
    figs = figs';
end
nfigs = numel(figs);
n_tot_figs = self.fig_count_+nfigs;
% cell2num does not work for cellarray of fig handles
if verLessThan('matlab','9.3')
    fig_there  = repmat(self.fig_list_{1},numel(self.fig_list_),1);
    for i=2:numel(fig_there)
        fig_there (i) = self.fig_list_{i};
    end
else
    fig_there = cellfun(@(x)(x), self.fig_list_);
end
if size(fig_there,1)==1
    fig_there = fig_there';
end
fig_list = [fig_there;figs];
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

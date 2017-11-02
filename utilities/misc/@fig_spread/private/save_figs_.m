function save_figs_(self,filename)
% save all controlled valid figures into Maltab figures file.

valid  = get_valid_ind(self);
if any(valid)
    all_fig_cel = self.fig_list_(valid);
    % get array of fig handles
    all_fig =  cellfun(@(x)(x),all_fig_cel);
    %
    savefig(all_fig,filename);
else
    warning('FIG_SPREAD:invalid_argument',...
        'Nothing to do, no valid figures')
end



function save_figs_(self,filename)
% save all controlled valid figures into Maltab figures file.

valid  = get_valid_ind(self);
if any(valid)
    all_fig_cel = self.fig_list_(valid);
    % get array of fig handles
    if verLessThan('matlab','9.3')
        all_fig = repmat(all_fig_cel{1},numel(all_fig_cel),1);
        for i=2:numel(all_fig_cel)
            all_fig(i) = all_fig_cel{i};
        end
    else
        all_fig =  cellfun(@(x)(x),all_fig_cel);
    end
    %
    try
        savefig(all_fig,filename);
    catch
        [fp,fn,~] = fileparts(filename);
        for i=1:numel(all_fig)
            filename = fullfile(fp,[fn,num2str(i)]);
            saveas(all_fig(i),filename,'fig');
        end
    end
else
    warning('FIG_SPREAD:invalid_argument',...
        'Nothing to do, no valid figures')
end



function [pix_cellarray,nonempty_bin_ind] = split_pix_per_bin_(pix_buf,...
    pix_per_bin,run_label,change_runid)
% divide pixels block read from a file into cells, containing pixels
% belonging to bins,
%
if nargin > 2
    if change_runid
        if(numel(pix_buf) > 0)
            pix_buf(5,:) = run_label; % set run_id to run_label provided. It may be filenum
        end
    end
end
%pix_ind_end   = cumsum(pix_per_bin);
%pix_ind_start = pix_end-pix_per_bin+1;

nonempty_bin_ind = find(pix_per_bin);
n_nonempty_cells = numel(nonempty_bin_ind);
pix_cellarray = cell(1,n_nonempty_cells);
pix_ind_end   = cumsum(pix_per_bin);
pix_ind_start = pix_ind_end-pix_per_bin+1;
for i=1:n_nonempty_cells
    nid = nonempty_bin_ind(i); % 80% of time is spent on the following row:
    pix_cellarray{i} = pix_buf(:,pix_ind_start(nid):pix_ind_end(nid));
end


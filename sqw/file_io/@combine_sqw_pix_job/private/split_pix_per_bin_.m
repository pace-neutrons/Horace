function [pix_cellarray,nonempty_bin_ind] = split_pix_per_bin_(pix_buf,pix_per_bin,n_file,run_label,change_fileno,relabel_with_fnum)
% divide pixels block read from a file into cell 

if change_fileno
    if(numel(pix_buf) > 0)
        if relabel_with_fnum
            pix_buf(5,:)=n_file;
        else
            pix_buf(5,:) =pix_buf(5,:)+run_label; % offset the run index
        end
    end
end



nonempty_bin_ind = find(pix_per_bin);
n_nonempty_cells = numel(nonempty_bin_ind);
pix_cellarray = cell(n_nonempty_cells ,1);
pix_start = cumsum(pix_per_bin)-pix_per_bin;
for i=1:n_nonempty_cells 
    nid = nonempty_bin_ind(i);
    pix_cellarray{i} = pix_buf(:,pix_start(nid)+1:pix_start(nid)+pix_per_bin(nid ));
end


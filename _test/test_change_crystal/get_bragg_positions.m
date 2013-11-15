function rlu0=get_bragg_positions(w, proj, rlu, half_len, half_thick, bin_width)
% Get true positions of Bragg peaks from 1D cuts
%
% Author: T.G.Perring

% Fit peak positions
rlu0=zeros(size(rlu));

for i=1:size(rlu,1)
    hcent=rlu(i,1); kcent=rlu(i,2); lcent=rlu(i,3);
    w1a_h=cut_sqw(w,proj,[hcent-half_len,bin_width,hcent+half_len],[kcent-half_thick,kcent+half_thick],[lcent-half_thick,lcent+half_thick],[-Inf,Inf]);
    w1a_k=cut_sqw(w,proj,[hcent-half_thick,hcent+half_thick],[kcent-half_len,bin_width,kcent+half_len],[lcent-half_thick,lcent+half_thick],[-Inf,Inf]);
    w1a_l=cut_sqw(w,proj,[hcent-half_thick,hcent+half_thick],[kcent-half_thick,kcent+half_thick],[lcent-half_len,bin_width,lcent+half_len],[-Inf,Inf]);
    rlu0(i,1)=peak_cwhh(IX_dataset_1d(w1a_h));
    rlu0(i,2)=peak_cwhh(IX_dataset_1d(w1a_k));
    rlu0(i,3)=peak_cwhh(IX_dataset_1d(w1a_l));
end


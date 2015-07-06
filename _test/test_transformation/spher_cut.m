function spher_cut()
% Sample spherical cut
data_source= fullfile('d:\users\abuts\SVN\Fe\Feb2013\sqw','Fe_ei200.sqw');
proj = spher_proj();

cut = cut_sqw(data_source,proj,[0.9,1.1],1,1,[40,60]);
plot(cut)
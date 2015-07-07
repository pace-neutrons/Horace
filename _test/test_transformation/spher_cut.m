function spher_cut()
% Sample spherical cut
sample = false;
if sample
    data_source= fullfile('d:\Data\Fe\Jan2015\sqw','Fe_ei200.sqw');
    proj = projection([1,1,0],[-1,1,0]);
    cut = cut_sqw(data_source,proj,[0.9,1.1],0.05,0.05,[40,60]);    
else    
    data_source= fullfile('d:\users\abuts\SVN\Fe\Feb2013\sqw','Fe_ei200.sqw');
    proj = spher_proj([1,1,0]);
    cut = cut_sqw(data_source,proj,[0.9,1.1],[-90,0.5,90],1,[40,60]);
end
plot(cut)
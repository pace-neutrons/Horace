function sphere_cut()
% Sample spherical cut
sample = false;
if sample
    data_source= fullfile('d:\Data\Fe\Jan2015\sqw','Fe_ei200.sqw');
    proj = line_proj([1,0,0],[0,1,0]);
    cut = cut_sqw(data_source,proj,[0.9,1.1],0.05,0.05,[40,60]);    
else    
    data_source= fullfile('d:\users\abuts\SVN\Fe\Feb2013\sqw','Fe_ei200.sqw');
    proj = sphere_proj([1,-1,0]);
    cut = cut_sqw(data_source,proj,[0.15,0.25],[-90,2,90],4,[40,60]);
    %cut = cut_sqw(data_source,proj,[0,0.01,0.6],[-90,90],[-180,4,180],[40,60]);
end
plot(cut)
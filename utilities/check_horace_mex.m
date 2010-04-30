function rez=check_horace_mex()
% function checks if horace mex files are compiled correctly and return
% their SVN version
%
% $Revision$    $Date$
%
rez = cell(5,1);
try
    rez{1}=['accumulate_cut_c: ',accumulate_cut_c()];    
catch
    rez{1}=[' Error in accumulate_cut_c:  ',lasterr];
end
try
    rez{2}=['bin_pixels_c    : ',bin_pixels_c()];    
catch
    rez{2}=[' Error in bin_pixels_c:      ',lasterr];    
end
try
    rez{3}=['calc_projections: ',calc_projections_c()];    
catch
    rez{3}=[' Error in calc_projections_c:  ',lasterr];    
end
try
    rez{4}=['get_ascii_file  : ',get_ascii_file()];    
catch
    rez{4}=[' Error in get_ascii_file:      ',lasterr];        
end
try
    rez{5}=['sort_pixels_by_b: ',sort_pixels_by_bins()];    
catch
    rez{5}=[' Error in sort_pixels_by_bins: ',lasterr];        
end



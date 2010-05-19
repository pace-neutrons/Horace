function [rez,n_errors,minVer,maxVer,compilation_date]=check_horace_mex(varargin)
% function checks if horace mex files are compiled correctly and return
% their SVN min and max version and the latest date these files were
% compiled
%
% If some mex files are can not be launched,the function returns the number of erros
% as n_errors and empty mex-files versions and dates
% 
% if varargin is present, the function also returns min and max svn
% versions of the mex files 
%
% $Revision$    $Date$
%
rez = cell(5,1);
n_errors=0;
compilation_date  =[];
try
    rez{1}=['accumulate_cut_c: ',accumulate_cut_c()];    
catch
    rez{1}=[' Error in accumulate_cut_c:  ',lasterr];
    n_errors=n_errors+1;    
end
try
    rez{2}=['bin_pixels_c    : ',bin_pixels_c()];    
catch
    rez{2}=[' Error in bin_pixels_c:      ',lasterr];    
    n_errors=n_errors+1;    
end
try
    rez{3}=['calc_projections: ',calc_projections_c()];    
catch
    rez{3}=[' Error in calc_projections_c:  ',lasterr];    
    n_errors=n_errors+1;    
end
try
    rez{4}=['get_ascii_file  : ',get_ascii_file()];    
catch
    rez{4}=[' Error in get_ascii_file:      ',lasterr];        
    n_errors=n_errors+1;    
end
try
    rez{5}=['sort_pixels_by_b: ',sort_pixels_by_bins()];    
catch
    rez{5}=[' Error in sort_pixels_by_bins: ',lasterr];        
    n_errors=n_errors+1;    
end
% calculate minumal and maximal versions of mex files; if there are errors
% in deploying mex-files, the versions become undefined;
minVer = 1e+32;
maxVer = -1;
if nargin>0 && n_errors==0
    n_mex=numel(rez);
    
    for i=1:n_mex
        ver_str=rez{i};
        ind = regexp(ver_str,':');
        ver_s=ver_str(ind(3)+1:ind(3)+5);
        ver=sscanf(ver_s,'%d');
        if ver>maxVer;       
            maxVer=ver;
            al=regexp(ver_str,'\(','split');
            compilation_date  = al{2};
        end
        if ver<minVer;       minVer=ver;
        end
    end
else
    minVer=[];
    maxVer=[];   
end



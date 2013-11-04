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

n_errors=0;
compilation_date  =[];
functions_name_list={'accumulate_cut_c: ','bin_pixels_c    : ','calc_projections: ','sort_pixels_by_b: '};
functions_handle_list={@accumulate_cut_c,@bin_pixels_c,@calc_projections_c,@sort_pixels_by_bins};
rez = cell(numel(functions_name_list),1);
for i=1:numel(functions_name_list)
    try
        rez{i}=[functions_name_list{i},functions_handle_list{i}()];    
    catch Err
        rez{i}=[' Error in',functions_name_list{i},Err.message];
        n_errors=n_errors+1;    
    end
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



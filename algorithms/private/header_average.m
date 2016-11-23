function [header_ave, ebins_all_same]=header_average(header)
% Get average header information from header field of sqw object
%
% *** Assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

if nargout>=1   % requested average header
    if iscell(header)
        header_ave=header{1};
    else
        header_ave=header;
    end
end

if nargout>=2   % requested energy bin information
    if iscell(header)
        ebins_all_same=true;
        en=header{1}.en;
        for i=2:numel(header)
            if numel(en)~=numel(header{i}.en) || ~all(en==header{i}.en)
                ebins_all_same=false;
                break
            end
        end
    else
        ebins_all_same=true;  % only one contributing dataset, so energy bins of all datasetsets are the same, by definition
    end
end

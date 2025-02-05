function [range,nbin,ok,mess]=pbin_parse_(~,p,p_defines_bin_centers,range_limits)
% Check form of the bin descriptions and return bin boundaries
% and number of bins for axes block built from the bin descriptors provided
% as input.
%
%   >> [range,nbin]=pbin_parse(obj,p,p_defines_bin_centers,range_limits)
%
% Input:
% ------
%   p  --   Bin description
%           - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%           - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%  p_defines_bin_centers
%     --   4-elements logical array, containing true if 3-component bin
%          parameters define bin centers (default) or false if bin edges
%          (exotic case)
%  range_limits
%      --  limits for ranges (min_range,max_range) this bins can have.
%          For linear axis the bin limits are -inf,inf, but for spherical
%          or cylindrical bins they have limited value for angles or radial
%          components of momentum.
%
%
% Output:
% -------
%   range  --  The min/max values of the range, covered by axis number i
%              in selected direction.
%   nbin   --  number of bins, the range is divided into (from 1(integration axis)
%              to number of bins in projection axis)
%
ok = true;
mess = '';
if isempty(p)
    range=[0;0];
    nbin = 1;
elseif isnumeric(p)
    if numel(p)==1
        % Scalar pbin ==> zero thickness integration? Useless. Current algorithm always leads to empty cut.
        % May be left for a future, for doing interpolated 0-thin cuts on
        % dnd objects? Ticket Re #1481 should explore this. 
        range=[p;p];
        nbin  = 1;
    elseif numel(p)==2
        % pbin has form [plo,phi]
        if p(1)<=p(2)
            range=[p(1);p(2)];
            nbin  = 1;
        else
            ok = false;
            mess = sprintf('Upper integration range: %g must be greater than or equal to the lower integration range: %g', ...
                p(2),p(1));
        end
    elseif numel(p)==3
        % pbin has form [plo,pstep,phi]. Always include p(3),
        % shifting it to move close to the rightmost bin centre
        if p(1)<=p(3) && p(2)>0 %
            if p_defines_bin_centers % always recalculate to avoid round-off errors when generating axis points.
                half_step = p(2)/2;
                min_v = p(1)-half_step;
                max_v = p(3)+half_step;
                range_constrained = false;
                if min_v  < range_limits(1)
                    if abs(p(1)-range_limits(1))<eps('single')
                        max_v = max_v+p(2)/2;                        
                    end
                    min_v = range_limits(1);
                    range_constrained = true;
                end
                if max_v > range_limits(2)
                    max_v = range_limits(2);
                    range_constrained = true;
                end
                nbin = floor((max_v-min_v)/p(2));
                if abs(min_v + nbin*p(2) - max_v) > eps('single')
                    if range_constrained
                        p(2) = (max_v-min_v)/nbin;
                    else
                        nbin = nbin+1;
                    end
                end
                % recalculate max range to avoid round/off errors
                max_v = min_v+nbin*p(2);
                range = [min_v;max_v];
            else % bin centres provided
                min_v = p(1);
                max_v = p(3);
                nbin = floor((max_v-min_v)/p(2));
                step = (max_v-min_v)/nbin;
                max_v = p(1)+nbin*step;
                range=[min_v;max_v];
            end
        else
            ok = false;
            mess = sprintf(['Range should have form [plo,pstep,phi], plo<=phi and pstep>0\n' ...
                'Actually it is: %s'], ...
                disp2str(p));
            return
        end
    else
        ok = false;
        mess =  sprintf(['Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries.\n' ...
            'Actually they are %s'],disp2str(p));
    end
else
    ok = false;
    mess =  sprintf([ 'Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent]\n' ...
        'Actually they are: %s'],disp2str(p));
end

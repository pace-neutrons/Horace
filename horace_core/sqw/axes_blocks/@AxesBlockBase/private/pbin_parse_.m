function [range,nbin]=pbin_parse_(obj,p,p_defines_bin_centers,i)
% Check form of the bin descriptions and return bin boundaries
%
%   >> [range,nbin]=pbin_parse(p,i)
%
% Input:
% ------
%   p  --   Bin description
%           - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%           - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%   i  --  Axis number (for displaying error information)
%
%
% Output:
% -------
%   range  --  The min/max values of the range, covered by axis number i
%              in selected direction.
%   nbin   --  number of bins, the range is divided into (from 1(integration axis)
%              to number (projection axis))
%


if isempty(p)
    range=[0;0];
    nbin = 1;
elseif isnumeric(p)
    if numel(p)==1
        % Scalar pbin ==> zero thickness integration? Useless. Current algorithm always leads to empty cut.
        % May be left for a future, for doing interpolated 0-thin cuts on dnd objects?
        range=[p;p];
        nbin  = 1;
    elseif numel(p)==2
        % pbin has form [plo,phi]
        if p(1)<=p(2)
            range=[p(1);p(2)];
            nbin  = 1;
        else
            error('HORACE:AxesBlockBase:invalid_argument',...
                'Range N%d: Upper integration range must be greater than or equal to the lower integration range',i);
        end

    elseif numel(p)==3
        % pbin has form [plo,pstep,phi]. Always include p(3),
        % shifting it to move close to the rightmost bin centre
        if p(1)<=p(3) && p(2)>0 %
            if p_defines_bin_centers % always recalculate to avoid round-off errors when generating axis points.
                min_v = p(1)-p(2)/2;
                max_v = p(3)+p(2)/2;
                nbin = floor((max_v-min_v)/p(2));
                if min_v + nbin*p(2)< max_v
                    nbin = nbin+1;
                end
                max_v = min_v+nbin*p(2); % bin edges provided
                range=[min_v;max_v];                
            else % bin centres provided
                min_v = p(1);
                max_v = p(3);
                nbin = floor((max_v-min_v)/p(2));
                step = (max_v-min_v)/nbin;
                max_v = p(1)+nbin*step;
                range=[min_v;max_v];                
            end
        else
            error('HORACE:AxesBlockBase:invalid_argument',...
                'Range N%d: Check that range has form [plo,pstep,phi], plo<=phi and pstep>0',i);
        end

    else
        error('HORACE:AxesBlockBase:invalid_argument',...
            'Range N%d: Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries',i);
    end
else
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent]');
end


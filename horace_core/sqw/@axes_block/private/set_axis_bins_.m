function obj=set_axis_bins_(obj,varargin)
% Calculates and sets plot and integration axes from binning information
%
%   >> obj=calc_axis_bins_(obj,p1,p2,p3,p4)
% where the routine sets the following object fields:
% iax,iint,pax,p and dax
%
% Input:
% ------
%   p1,p2,p3,p4 Binning descriptions
%               - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%               - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%               - [pint]                    (interpreted as [pint,pint]
%               - [] or empty               (interpreted as [0,0]
%               - scalar numeric cellarray  (interpreted as bin boundaries)
%
% Output:
% -------
%   Sets up img_range and nbin_all_dim parameters of the axes block, which
%   in turn define all axes block parameters, namely:
%
%   iax         Index of integration axes into the projection axes [row vector]
%              Always in increasing numerical order
%                   e.g. if data is 2D, data.iax=[1,3] means summation has
%                        been performed along u1 and u3 axes
%   iint        Integration range along each of the integration axes.
%              [iint(2,length(iax))]
%                   e.g. in 2D case above, is the matrix vector
%                        [u1_lo, u3_lo; u1_hi, u3_hi]
%   pax         Index of plot axes into the projection axes  [row vector]
%              Always in increasing numerical order
%                   e.g. If data is 3D, pax=[1,2,4] means u1, u2, u4 axes
%                        are x,y,z in any plotting
%                        If data is 2D, pax=[2,4] means u2, u4 axes are
%                        x,y   in any plotting
%   p           Cell array of bin boundaries along the plot axes [column vectors]
%                   i.e. row cell array{data.p{1}, data.p{2} ...}
%                       (for as many plot axes as given by length of data.pax)

% Original author: T.G.Perring
%


if nargin ~=5
    error('HORACE:axes_block:invalid_argument',...
        'Must have four and only four binning descriptors');
end

range = zeros(2,4);
nbins  = zeros(4,1);
for i=1:4
    [range1,nbins1]=pbin_parse(varargin{i},i);
    range(:,i) = range1;
    nbins(i) = nbins1;
end
obj.img_range = range;
obj.nbins_all_dims = nbins;


%----------------------------------------------------------------------------------------
function [range,nbin]=pbin_parse(p,i)
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
            error('HORACE:axes_block:invalid_argument',...
                'Range N%d: Upper integration range must be greater than or equal to the lower integration range',i);
        end

    elseif numel(p)==3
        % pbin has form [plo,pstep,phi]. Always include p(3),
        % shifting it to move close to the rightmost bin centre
        if p(1)<=p(3) && p(2)>0
            min_v = p(1)-p(2)/2;
            max_v = p(3)+p(2)/2;
            nbin = floor((max_v-min_v)/p(2));
            if min_v + nbin*p(2)< max_v
                nbin = nbin+1;
            end
            max_v = min_v+nbin*p(2); % always recalculate to avoid round-off errors when generating axis points.
            range=[min_v;max_v];
        else
            error('HORACE:axes_block:invalid_argument',...
                'Range N%d: Check that range has form [plo,pstep,phi], plo<=phi and pstep>0',i);
        end

    else
        error('HORACE:axes_block:invalid_argument',...
            'Range N%d: Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries',i);
    end
else
    error('HORACE:axes_block:invalid_argument',...
        'Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent]');
end


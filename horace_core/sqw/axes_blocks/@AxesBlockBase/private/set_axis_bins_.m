function obj=set_axis_bins_(obj,ndims,varargin)
% Calculates and sets plot and integration axes from binning information
%
%   >> obj=set_axis_bins_(obj,p1,p2,p3,p4)
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


if nargin ~=6
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Must have four and only four binning descriptors');
end
one_bn_is_iax = obj.single_bin_defines_iax_;
if isempty(ndims)
    nb = num2cell(one_bn_is_iax);
    ndims = sum(cellfun(@(x,y)(~isempty(x)&&numel(x)>2||numel(x)==2&&(~y)), ...
        varargin,nb));
end

range = zeros(2,4);
nbins  = zeros(4,1);
for i=1:4
    [range1,nbins1]=obj.pbin_parse(varargin{i},one_bn_is_iax(i),i);
    range(:,i) = range1;
    nbins(i) = nbins1;
end
% reset up dimensions for empty constructor
nd_avail = sum(nbins>1 | (~one_bn_is_iax' & nbins==1));
if nd_avail  ~= ndims
    for i=1:4
        if nbins(i)==1 && obj.single_bin_defines_iax_(i)
            obj.single_bin_defines_iax_(i) = false;
            nd_avail = nd_avail+1;
            if nd_avail == ndims
                break;
            end
        end
    end
end
obj.img_range = range;
obj.nbins_all_dims = nbins;

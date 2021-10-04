function obj=set_axis_bins_(obj,varargin)
% Caclulates and sets plot and integration axes from binning information
%
%   >> obj=calc_axis_bins_(obj,p1,p2,p3,p4)
% where the routine sets the following object fields:
% iax,iint,pax,p
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

iax=zeros(1,4);
iint=zeros(2,4);
pax=zeros(1,4);
p=cell(1,4);

if nargin ~=5
    error('HORACE:axes_block:invalid_argument',...
        'Must have four and only four binning descriptors');
end

ni=0; np=0;
for i=1:4
    pout=pbin_check(varargin{i});
    
    if ~iscell(pout)
        ni=ni+1;
        iax(ni)=i;
        iint(:,ni)=pout;
    else
        np=np+1;
        pax(np)=i;
        p(np)=pout;
    end
end
obj.iax = iax(1:ni);
obj.iint = iint(:,1:ni);
obj.pax = pax(1:np);
obj.p = p(1:np);

obj.dax = 1:np;


%----------------------------------------------------------------------------------------
function pout=pbin_check(p)
% Check form of the bin descriptions and return bin boundaries
%
%   >> [pout,mess]=pbin_check(p)
%
% Input:
% ------
%   p       Bin description
%           - [pcent_lo,pstep,pcent_hi] (pcent_lo<=pcent_hi; pstep>0)
%           - [pint_lo,pint_hi]         (pint_lo<=pint_hi)
%           - [pint]                    (interpreted as [pint,pint]
%           - [] or empty               (interpreted as [0,0]
%           - scalar numeric cellarray  (interpreted as bin boundaries)
%
% Output:
% -------
%   pout    If a permissible input, then
%           - Scalar cell array with a column vector og bin boundaries
%           - Column vector, length two, with lower an upper integration ranges
%           If a problem, then pout==[]
%


if isempty(p)
    pout=[0;0];
    
elseif isnumeric(p)
    if numel(p)==1
        % Scalar pbin ==> zero thickness integration
        pout=[p;p];
        
    elseif numel(p)==2
        % pbin has form [plo,phi]
        if p(1)<=p(2)
            pout=p(:);
        else
            error('HORACE:axes_block:invalid_argument',...
                'Upper integration range must be greater than or equal to the lower integration range');
        end
        
    elseif numel(p)==3
        % pbin has form [plo,pstep,phi]. Handle a Matlab oddity when using x1:dx:x2
        if p(1)<=p(3) && p(2)>0
            pout=(p(1)-p(2)/2: p(2): p(3)+p(2)/2)';
            if pout(end)<p(3)
                pout=[pout;pout(end)+p(2)];
            elseif numel(pout)>1 && pout(end-1)>=p(3)
                pout=pout(1:end-1);
            end
            pout={pout};
        else
            error('HORACE:axes_block:invalid_argument',...
                'Check that range has form [plo,pstep,phi], plo<=phi and pstep>0');
        end
        
    else
        error('HORACE:axes_block:invalid_argument',...
            'Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries');
    end
    
elseif iscell(p) && isscalar(p) && isnumeric(p{1}) && numel(p{1})>1
    pstep=(p{1}(end)-p{1}(1))/(numel(p{1})-1);
    tol=4*eps('single');
    if pstep>0 && all(abs(diff(p{1})-pstep)<tol*pstep)
        pout={p{1}(:)};
    else
        error('HORACE:axes_block:invalid_argument',...
            'Bin boundaries must be equslly spaced');
    end
    
else
    error('HORACE:axes_block:invalid_argument',...
        'Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries');
end


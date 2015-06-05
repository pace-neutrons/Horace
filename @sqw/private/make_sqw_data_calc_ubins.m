function [iax,iint,pax,p,mess]=make_sqw_data_calc_ubins(varargin)
% Get plot and integration axes from binning information
%
%   >> [iax,iint,pax,p,mess]=make_sqw_data_calc_ubins(p1,p2,p3,p4)
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
%
%   mess        Error message if there was a problem; ='' if no problem.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)


iax=zeros(1,4);
iint=zeros(2,4);
pax=zeros(1,4);
p=cell(1,4);mess='';

if numel(varargin)~=4
    mess='Must have four and only four binning descriptors';
    return
end

ni=0; np=0;
for i=1:4
    [pout,mess]=pbin_check(varargin{i});
    if isempty(mess)
        if ~iscell(pout)
            ni=ni+1;
            iax(ni)=i;
            iint(:,ni)=pout;
        else
            np=np+1;
            pax(np)=i;
            p(np)=pout;
        end
    else
        return
    end
end
iax=iax(1:ni);
iint=iint(:,1:ni);
pax=pax(1:np);
p=p(1:np);


%----------------------------------------------------------------------------------------
function [pout,mess]=pbin_check(p)
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
%   mess    If all OK, empty string ''
%           If not OK, error message

pout=[];
mess='';

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
            mess='Upper integration range must be greater than or equal to the lower integration range';
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
            mess='Check that range has form [plo,pstep,phi], plo<=phi and pstep>0';
        end
        
    else
        mess='Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries';
    end
    
elseif iscell(p) && isscalar(p) && isnumeric(p{1}) && numel(p{1})>1
    pstep=(p{1}(end)-p{1}(1))/(numel(p{1})-1);
    tol=4*eps('single');
    if pstep>0 && all(abs(diff(p{1})-pstep)<tol*pstep)
        pout={p{1}(:)};
    else
        mess='Bin boundaries must be equslly spaced';
    end
    
else
    mess='Binning description must have form [plo,pstep,phi], [plo,phi], or [pcent] or cell array of bin boundaries';
end

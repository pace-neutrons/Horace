function [iax, iint, pax, p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin, pin, nbin)
% Create bin boundaries for integration and plot axes from requested limits and step sizes
% Uses knowledge of the range of the data and energy bins of the data to set values for those
% not provided.
%
% Syntax:
%   >> [iiax, ipax, p, noffset, nkeep, mess] = cut_dnd_calc_ubins (pbin, pin, nbin)
%
% Input:
% ------
%   pbin        Cell array of requested limits and bins for plot axes:
%       pbin{1}     Binning along first plot axis
%       pbin{2}     Binning along second plot axis
%                           :
%                   for as many axes as there are plot axes. For each binning entry:
%               - [] or ''          Plot axis: use bin boundaries of input data
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range of the input data is contained within
%                                  the bin boundaries.
%               - [plo, phi]        Integration axis: range of integration - those bin centres that lie inside this range 
%                                  are included.
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%                                   If pstep=0 then use current bin size and synchronise
%                                  the output bin boundaries with the current boundaries. The overall range is
%                                  chosen to ensure that the range plo to phi is contained within
%                                  the bin boundaries.
%   pin         Cell array current bin boundaries on plot axes.
%
%   nbin        [2 x ndim] array containing the lower and upper indices of the 
%               extremal elements along each axis
%
% Output:
% -------
%   iax         Index of integration axes into the incoming plot axes  [row vector]
%   iint        Integration range for the new integration axes [(2 x length(iax)) vector]
%   pax         Index of plot axes into the incoming plot axes  [row vector]
%   p           Call array containing bin boundaries along the remaining plot axes [column vectors]
%                   i.e. data.p{1}, data.p{2} ... (for as many plot axes as given by length of data.pax)
%   noffset     Offset along the remaining plot axes of the section from the input signal array (nkeep, below)
%              once the axes to be integrated over have been summed [row vector, length=no. elements of p]
%   nkeep       Section of the input signal array to be retained: [2xndim], ndim=length(pin)
%   mess        Error message; empty if all was OK; non-empty otherwise (in which case all other output are empty)
%               Use this as the sole criterion of succesful operation because empty arrays for other outputs
%               can be valid e.g. iax=[] and iint=[] if all axes are plot axes.
%
% Notes:
%   - if the range of the data is zero along a plot axis, then the two bin boundaries
%    will both have the same value, even if a non-zero bin size was input.
%


% Original author: T.G.Perring
%
% $Revision:: 1750 ($Date:: 2019-04-08 17:55:21 +0100 (Mon, 8 Apr 2019) $)

tol=1e-7;   % relative tolerance for single<=>double comparisons

% Check number and format of integration range / plotting description
% ------------------------------------------------------------------------
npax_in = numel(pbin);
for i=1:npax_in
    if ~(isempty(pbin{i})||(isa_size(pbin{i},'row','double') && length(pbin{i})>=1 && length(pbin{i})<=3))
        iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
        mess = 'Check format of binning arguments';
        return
    end
end


% Check values are acceptable, and make ranges 1x3 (for plot) or 1x2 for integration axes
% ---------------------------------------------------------------------------------------
% At this point, we are just filling in the values for the missing elements according to
% the convention that missing ranges are +inf, -inf (upper, lower) and missing bin width
% for energy is 0.
% Will combine with the limits of the data in the block of code that follows the this block
niax = 0;
npax = 0;
iax = zeros(1,npax_in);
pax = zeros(1,npax_in);
iint = zeros(2,npax_in);
p=cell(1,npax_in);
noffset = zeros(1,npax_in);
nkeep = zeros(2,npax_in);

for i=1:npax_in
    if isempty(pbin{i})         % keep the existing plot axis
        npax=npax+1;
        pax(npax)=i;
        p{npax}=pin{i};
        noffset(npax)=0;
        nkeep(:,i)=[1;numel(pin{i})-1];
        
    elseif length(pbin{i})==1   % bin step only given
        pstep=(pin{i}(end)-pin{i}(1))/(length(pin{i})-1);  % current step size
        if pbin{i}==0 || equal_to_relerr(pbin{i},pstep,tol)     % use current step size
            if isempty(nbin)
                iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
                mess='Input data is empty. No autoscaling of limits no possible';
                return
            end
            npax=npax+1;
            pax(npax)=i;
            p{npax}=pin{i}(nbin(1,i):nbin(2,i)+1);  % the axis is compressed
            noffset(npax)=0;
            nkeep(:,i)=nbin(:,i);
        else
            iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
            mess='Cannot have step size different to current step size';
            return
        end

    elseif length(pbin{i})==2   % integration range
        if pbin{i}(1)>=pbin{i}(2)
            iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
            mess='Check upper limit is greater than lower limit in integration range request';
            return
        end
        niax=niax+1;
        iax(niax)=i;
        pcent=0.5*(pin{i}(2:end)+pin{i}(1:end-1));
        lis=find(pcent>=pbin{i}(1) & pcent<=pbin{i}(2));
        if isempty(lis)     % no bin centres in the integration range
            iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
            mess='No data in integration range';
            return
        end
        iint(:,niax)=[pin{i}(lis(1));pin{i}(lis(end)+1)];
        nkeep(:,i)=[lis(1);lis(end)];
        
    elseif length(pbin{i})==3   % plot range
        if pbin{i}(1)>=pbin{i}(3)
            iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
            mess='Check upper limit is greater than lower limit in plot range request';
            return
        end
        pstep=(pin{i}(end)-pin{i}(1))/(length(pin{i})-1);  % current step size
        if pbin{i}(2)==0 || equal_to_relerr(pbin{i}(2),pstep,tol)     % use current step size
            nlo = floor((pbin{i}(1)-pin{i}(1))/pstep);
            nhi = ceil((pbin{i}(3)-pin{i}(end))/pstep);
            if nhi+length(pin{i})-nlo>2     % at least two bins, so a plot axis
                npax=npax+1;
                pax(npax)=i;
                % If the requested bin limits or extent of the data are the same as the limits of the default bin
                % boundaries, then we are guaranteed to have nlo=nhi=0
                if nlo==nhi && nlo==0
                    p{npax} = pin{i};
                else
                    p{npax} = (pin{i}(1)+pstep*(nlo:nhi+length(pin{i})-1))';
                end
                if nlo>=0
                    noffset(npax)=0;
                    nbeg=nlo+1;     % first data array element to be kept
                else
                    noffset(npax)=-nlo;
                    nbeg=1;
                end
                if nhi<=0
                    nend=nhi+length(pin{i})-1;  % last data array element to be kept
                else
                    nend=length(pin{i})-1;
                end
                nkeep(:,i)=[nbeg;nend];
            else    % only one bin
                str=str_compress(num2str(pbin{i}));
                iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
                mess=['Only one bin needed to cover the plot range in [',str,'] - cannot make this a plot axis'];
                return
            end
        else
            iax=[]; pax=[]; p=[]; noffset=[]; nkeep=[];
            mess='Cannot have step size different to current step size';
            return
        end
    end

end
iax = iax(1:niax);
pax = pax(1:npax);
noffset=noffset(1:npax);
p = p(1:npax);
iint = iint(:,1:niax);
mess=[];

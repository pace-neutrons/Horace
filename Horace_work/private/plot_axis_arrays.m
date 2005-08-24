function [d, mess] = plot_axis_arrays (pax, data_range, vstep, vlims, en0, ebin_def)
% Calculate the step size and (equally spaced) bin centres for an orthogonal plot grid, applying
% various rules for default input.
%
% It is assumed that input is valid, as this is expected to be used internally only where type and
% validity have already been ensured. Requiremenets on input arguments are:
%   pax: elements lie in range 1-4
%   data_range: min_value <= max_value for each axis and values are finite
%   vstep: elements are >0 for those indexed by pax, except vstep(4)=0 is valid (i.e. for energy axis)
%   vlims: min_value <= max_value for each axis
%   en0: monotonically increasing and equally spaced
%   ebin: ebin>0
%
% Therefore, if the error message is filled, this is because there really are no data points in the
% range asked for.
%   
%
% Syntax:
%   >> [pstep, p1, p2, p3, p4] = plot_axis_arrays (pax, data_range, vstep, vlims, ebin_def, en0)
%
% Input:
% ------
%   pax         Plot axis index numbers (in range 1-4, energy axis is axis 4). pax is used as
%              an index into the arrays data_range, vstep and vlims. Output will be calculated
%              for each axis in pax e.g. if pax = [1,3,4] output is for axes 1,3 and 4
%   data_range  Range of pixel centres along each axis: [xlo(1), xlo(2), xlo(3), xlo(4); xhi(1), xhi(2), xhi(3), xhi(4)]
%   vstep       Input step size along each axis: [vstep(1), vstep(2), vstep(3), vstep(4)]
%   vlims       Requested limits for bin centres along each axis (can include -inf, inf, and vlo(i)=vhi(i)): array has
%              form: [vlo(1), vlo(2), vlo(3), vlo(4); vhi(1), vhi(2), vhi(3), vhi(4)]
%   en0         Default energy bin centres to be used in construction of output array if input energy step
%              size is less than or equal to the step size of en0 i.e. if vstep(4)<=ebin0==(en0(2)-en0(1)).
%              In this case:
%                - if vlims(:,4) = [-inf,inf]: output bins are en0
%                - if vlims(:,4)   are finite: output bins communsurate with en0, range contained within vlims
%   ebin_def    Set ebin0 = ebin_def if en0 has length=1 (i.e. only one enrgy bin). Ignored if length(en0)>1.
%
%
% Output:
% -------
%   d           Data structure with fields
%                   pstep   Step sizes [row vector]
%                   p1      Bin centres along first plot axis
%                   p2      Bin centres along second plot axis
%                    :                  :
%               The structure is empty if a problem was encountered.
%   
%   mess        Message: all OK then blank and d is populated; otherwise contains error description and d is empty

% Original author: T.G.Perring
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring


mess = '';
npax = length(pax);

% Get default energy bin size
if length(en0)==1
    ebin0 = ebin_def;
else
    ebin0 = (en0(end)-en0(1))/(length(en0)-1);
end

if npax>0
    % if any of the limits is infinite, then use the value given by the extent of the data
    plims = vlims;
    plims(~isfinite(vlims)) = data_range(~isfinite(vlims));
    plims = plims(:,pax(1:npax));
    d.pstep = vstep(pax(1:npax));
    for i=1:npax
        iax = pax(i);
        nam = ['p',num2str(i)];
        if plims(2,i)<plims(1,i)
            d = [];
            mess = ['No data within data range on axis ',num2str(iax),' - check limits'];
            return
        end
        if iax<4 | (iax==4 & d.pstep(i)>ebin0)  % treat energy axis like other axes if provided with energy bin greater than default
            d.(nam) = plims(1,i):d.pstep(i):plims(2,i);
        else
            if vlims(:,4)==[-inf;inf]
                d.pstep(i) = ebin0;
                d.(nam) = en0;
            else
                d.pstep(i) = ebin0;
                d.(nam) = ebin0*ceil((plims(1,i)-en0(1))/ebin0)+en0(1):d.pstep(i):plims(2,i);   % tweak limits to ensure boundaries communsurate with en0
                if length(d.(nam))==0; 
                    d = []; 
                    mess = ['No data within data range on energy axis - check limits']; 
                    return; 
                end
            end
        end
        % error conditions have caught cases when had infinite or semi-infinite limits, or where
        % on energy axis tweaking to commensurate bins, caused data to lie outside the data range.
        % Now catch case of out-of-range finite limits:
        if (d.(nam)(1)-0.5*d.pstep(i) > data_range(2,iax)) | (d.(nam)(end)+0.5*d.pstep(i) < data_range(1,iax))
            d = [];
            mess = ['No data within data range on axis ',num2str(iax),' - check limits'];
            return
        end            
    end
elseif npax==0
    d = [];
    mess = 'No plot axes given'; 
    return;
end



function [elo_out,ehi_out]=estimate_erange(efix,emode,elo,ehi)
% Make an estimate of the energy transfer range for construction of urange
% 
%   >> [elo,ehi]=estimate_erange(efix,emode,elo,ehi)
%
% The estimate is made on the basis of those runs for which elo, ehi have
% been specified, if any. If none provided, then use default ranges
%
% Input:
% ------
%   efix        Column vector of fixed energies (meV)
%   emode       Direct geometry (=1) or indirecet geometry (=2)
%              Scalar or column vector; all values must be the same.
%   elo         Column vector of lower energy transfer limits.
%              For those runs where not specified, relevant entry must be NaN
%   ehi         Column vector of upper energy transfer limits.
%              For those runs where not specified, relevant entry must be NaN
%
% Output:
% -------
%   elo_out     Column vector of lower energy transfer limits with NaNs 
%              replaced by a multiple of efix determined as the maximum 
%              fraction for those runs where elo was actually given, or if
%              none given, default fraction -0.2 (emode=1), -0.99 (emode=2).
%   ehi_out     Column vector of upper energy transfer limits with NaNs 
%              replaced by a multiple of efix determined as the maximum 
%              fraction for those runs where ehi was actually given, or if
%              none given default fraction 0.99 (emode=1 and emode=2).


if ~all(emode==emode(1))
    error('Must have the same value of emode for all data sets')
end

ind=isfinite(elo);
if all(~ind(:))
    if emode(1)==1
        elo_out=-0.20*efix;
    elseif emode(1)==2
        elo_out=-0.99*efix;
    else
        error('Only applicable for inelastic data (emode=1 or emode=2)')
    end
elseif ~all(ind(:))
    elo_out=zeros(size(efix));
    elo_out(ind)=elo(ind);
    elo_out(~ind)=min(elo(ind)./efix(ind))*efix(~ind);
else
    elo_out=elo;
end

ind=isfinite(ehi);
if all(~ind(:))
    if emode(1)==1
        ehi_out= 0.99*efix;
    elseif emode(1)==2
        ehi_out= 0.99*efix;
    else
        error('Only applicable for inelastic data (emode=1 or emode=2)')
    end
elseif ~all(ind(:))
    ehi_out=zeros(size(efix));
    ehi_out(ind)=ehi(ind);
    ehi_out(~ind)=max(ehi(ind)./efix(ind))*efix(~ind);
else
    ehi_out=ehi;
end

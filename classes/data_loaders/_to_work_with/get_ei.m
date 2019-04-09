function ei =get_Ei(this)
% usage: 
%>> Ei =getEi(spe)
%
%The methor returns input energy if this energy if such data
%exist in spe class; Returns empty array if it is not; Ei data usually loaded to spe
%structure from nxspe file or spe_h5 file;
%
% $Revision:: 830 ($Date:: 2019-04-09 10:03:50 +0100 (Tue, 9 Apr 2019) $)
%

if  isa(this,'speData') % called on spe and this is morden spe
    Ei = getEi(this.spe);
else
    error('speData:getEi','this function can not be called on non-speData object');
end


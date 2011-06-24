function this = load_par(this)
% method tires to load Horace par data from existing nxspe fiel
% if data not present, does nothing
%
% Currently par data are not present in nxspe and it is unclear how to
% place it there (MANTID question)
%
% $Revision: 508 $ ($Date: 2010-11-29 15:50:24 +0000 (Mon, 29 Nov 2010) $)
%
% non-nxspe file does not have par-data in it;
if ~strcmpi(this.fileExt,'.nxspe') 
    this.par = [];
    return;
end

end


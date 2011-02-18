function [par,this] =getPar(this)
% usage: 
%>> par =get_par(spe)
%
%The methor returns phx data contained in spe data structure if such data
%exist; Returns empty array if it is not. Phx data usually loaded to spe
%structure from nxspe file;
%
% $Revision: 508 $ ($Date: 2010-11-29 15:50:24 +0000 (Mon, 29 Nov 2010) $)
%

if strcmpi(this.hdfFileExt{2},this.fileExt) % hdf_spe can have par field
    if(~this.data_loaded&&isempty(this.par))
        this = load_par(this);       
    end
    par = this.par;
else
     par = [];
end


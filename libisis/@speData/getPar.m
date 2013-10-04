function [par,this] =getPar(this)
% usage: 
%>> par =get_par(speData)
%
%The methor returns phx data contained in spe data structure if such data
%exist; Returns empty array if it is not. Phx data usually loaded to spe
%structure from nxspe file;
%
% $Revision$ ($Date$)
%

if strcmpi(this.hdfFileExt{2},this.fileExt) % hdf_spe can have par field
    if(~this.data_loaded||isempty(this.par))
        if isempty(this.nxspe_root_folder)
            this.nxspe_root_folder = find_root_nexus_dir(fullfile(this.fileDir,this.fileName,this.fileExt),'NXSPE');
        end
        this = load_par(this);       
    end
    par          = this.par;
    par.filename = [this.fileName,this.fileExt];
    if isempty(this.fileDir)
        par.filepath  =  ['.',filesep];   
    else
        par.filepath  =  [this.fileDir,filesep];   
    end
else
     par = [];
end


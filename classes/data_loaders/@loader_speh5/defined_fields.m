function [fields,this] = defined_fields(this)
% the method returns the cellarray of fields names
%
% the fields whith these names have to be defined by 
% the loader_speh5 class
%
%>>[fields,loader_speh5]= defined_fields(loader_speh5);
%
% if spe_h5 file version has not been defined before, it will be read from
% the file


fields='';
if ~isempty(this.file_name)
    if isempty(this.speh5_version)
        ver=hdf5read(this.file_name,'spe_hdf_version');      
        this.speh5_version=ver;
    end
    if ver>=2
        fields ={'S','ERR','en','efix'};
    else
        fields ={'S','ERR','en'}; 
    end   
end

end


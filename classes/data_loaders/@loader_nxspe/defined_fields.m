function fields = defined_fields(loader_nxspe)
% the method returns the cellarray of fields names
% the fields which these names have to be defined by 
% the loader_nxspe class
%
%>> fields= defined_fields(loader_nxspe);

fields='';
if ~isempty(loader_nxspe.file_name)
    fields = loader_nxspe.nxspe_defines;
end



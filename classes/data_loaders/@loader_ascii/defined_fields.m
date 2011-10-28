function fields = defined_fields(loader_ascii)
% the method returns the cellarray of fields names, 
% which are defined by current instance of loader_ascii 
% class
%usage:
%>> fields= defined_fields(loader_ascii);
%   loader_ascii -- a loader_ascii constructor or 
%                     loader_ascii type variable
%
% $Author: Alex Buts; 20/10/2011
%
% $Revision: 1 $ ($Date:  $)
%

fields='';
if ~isempty(loader_ascii.file_name)
    fields = loader_ascii.spe_defines;
end
if ~isempty(loader_ascii.par_file_name)
    if ~isempty(fields)
        fields = [fields,loader_ascii.par_defines];
    else
        fields = loader_ascii.par_defines;
    end
end

end


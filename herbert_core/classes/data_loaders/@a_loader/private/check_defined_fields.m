function fields = check_defined_fields(this)
% method checks what fields in the structure are defined fromn the fields
% the data file should define.
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%

% a data file usually defines the following fields:
loader_def = this.loader_defines;
% par file can define the following fields:
par_def    =  this.par_file_defines();

if isempty(this.file_name) % no data file
    % find the fields which are defined by the file structure. 
    is_def = @(field)(is_field_def(this,field));
    def_fiels = cellfun(is_def,loader_def);
    loader_def = loader_def(def_fiels);   
end
% find the fields which are defined by both par and data file
duplicates = ismember(par_def,loader_def);
    % combine unique fields
fields  = [loader_def,par_def(~duplicates)];


function is=is_field_def(struct,field)
    is = true;
    if isempty(struct.(field))
        is = false;
    end



function fields = check_defined_fields(this)
% method checks what fields in the structure are defined fromn the fields
% the data file should define.
%
% $Revision: 311 $ ($Date: 2013-11-27 09:57:20 +0000 (Wed, 27 Nov 2013) $)
%

loader_def = this.loader_defines;
par_def    =  this.par_file_defines();
if isempty(this.file_name) % no data file
    fields = par_def;
    ic = numel(fields);
    for i=1:numel(loader_def)
        field = loader_def{i};
        if ~isempty(this.(field));
            if ~ismember(field,fields)
                ic =ic +1;
                fields{ic} = field;
            end
        end
    end
else % file is there
    fields = loader_def;
    ic = numel(fields);
    for i=1:numel(par_def)
        field = par_def{i};
        if ~ismember(field,fields)
            ic =ic +1;
            fields{ic} = field;
        end
    end
    
end

function fields = check_par_defined_(obj)
% method checks what fields in the structure are defined from the fields
% the par file should define.
%
% $Revision:: 840 ($Date:: 2020-02-10 16:05:56 +0000 (Mon, 10 Feb 2020) $)
%

df = obj.par_can_define();
if ~isempty(obj.par_file_name)
    fields  = df;
else
    % find the fields which are defined by the file structure.
    is_def = @(field)(is_field_def(obj,field));
    def_fiels = cellfun(is_def,df);
    fields    = df(def_fiels);
end


function is=is_field_def(struct,field)
is = true;
if isempty(struct.(field))
    is = false;
end



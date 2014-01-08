function fields = check_par_defines(this)
% method checks what fields in the structure are defined from the fields
% the par file should define.
%
% $Revision$ ($Date$)
%

defines = {'det_par','n_detectors'};
if isempty(this.par_file_name);
    fields ={};
    ic = 0;
    for i=1:numel(defines)
        field = defines{i};
        if ~isempty(this.(field))
            ic=ic+1;
            fields{ic}=field;
        end
    end
else
    fields=defines;
end

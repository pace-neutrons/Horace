function data = copy_data_from_structure(data,sqw_data_structure,conv2double)
% method copies data from structure to internal class structure
%
% The structure should fields with names, correspondent to class names.
% the fiels with names absent in class will be rejected
% if structure contains fields with data not appropriate for the class,
% the verification procedure will flag them later.

fields = fieldnames(sqw_data_structure);
for i=1:numel(fields)
    fld = fields{i};
    
    if isempty(data.(targ_fld)) && isempty(sqw_data_structure.(fld))  
        continue; %keep the shape of the empty source structure, ignore shape of the input
    end
    if isa(sqw_data_structure.(fld),'single') && conv2double
        data.(targ_fld) = double(sqw_data_structure.(fld));
    else
        data.(targ_fld) = sqw_data_structure.(fld);
    end
end


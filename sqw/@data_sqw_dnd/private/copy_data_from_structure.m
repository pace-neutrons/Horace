function data = copy_data_from_structure(data,sqw_data_structure,conv2double)
% method copies data from structure to internal class structure
%
% The structure should fields with names, correspondent to class names.
% the fiels with names absent in class will be rejected
% if structure contains fields with data not appropriate for the class,
% the verification procedure will flag them later.
%
% $Revision$ ($Date$)
%

fields = fieldnames(sqw_data_structure);
proj_fields = data.proj.get_old_interface_fields();
oif = ismember(fields,proj_fields);
proj_stuct = struct();
for i=1:numel(fields)
    fld = fields{i};
    if oif(i)
        proj_stuct.(fld) = sqw_data_structure.(fld);
    else
        if isempty(data.(fld)) && isempty(sqw_data_structure.(fld))
            continue; %keep the shape of the empty source structure, ignore shape of the input
        end
        if isa(sqw_data_structure.(fld),'single') && conv2double
            data.(fld) = double(sqw_data_structure.(fld));
        else
            data.(fld) = sqw_data_structure.(fld);
        end
    end
end

% old interface files support only rectilinear projection;
proj = projection();
data.proj = proj.set_from_old_interface(proj_stuct);

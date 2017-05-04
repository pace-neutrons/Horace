function   obj = set_from_old_interface(obj,old_struct)
% fill object structure from old interface data. Used for
% restoring data stored in old data formats.
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
%

flds = obj.get_old_interface_fields();
u_to_rlu  = [];
if isfield(old_struct,'u_to_rlu')
    u_to_rlu = old_struct.u_to_rlu;
    old_struct = rmfield(old_struct,'u_to_rlu');
end
fld_present = fields(old_struct);
nf = numel(flds);
is_present = ismember(flds,fld_present);
%
calc_urange = ~ismember('urange',fld_present);


for i=1:nf
    fld = flds{i};
    if strcmp(fld,'ulen')
        obj = calc_urange_fun(obj,old_struct,calc_urange);
        continue;
    end
    if is_present(i)
        obj.([fld,'_']) = old_struct.(fld);
    end
end
if ~isempty(u_to_rlu)
    obj.u_to_rlu = u_to_rlu;
end


function obj=calc_urange_fun(obj,old_struct,calc_urange)

ulen = old_struct.ulen;
if calc_urange
    p  = old_struct.p;
    urange = zeros(2,numel(p));
    for i=1:numel(p)
        urange(:,i) = [p{i}(1),p{i}(end)];
    end
else
    urange = old_struct.urange;
end
grid_size = floor((urange(2,:)-urange(1,:)./ulen));
obj=build_4D_proj_box_(obj,grid_size,urange);


function   obj = set_from_old_interface(obj,old_struct)
% fill object structure from old interface data. Used for
% restoring data stored in old data formats.
%
% $Revision: 536 $ ($Date: 2016-09-26 16:02:52 +0100 (Mon, 26 Sep 2016) $)
%

flds = obj.get_old_interface_fields();
nf = numel(flds);

for i=1:nf
    fld = flds{i};
    obj.([fld,'_']) = old_struct.(fld);
end



function ok = check_equal_size(obj,other_obj)
% check if other map describes the same size as the one
% from another object.
%
% $Revision: 1315 $ ($Date: 2016-11-03 14:36:26 +0000 (Thu, 03 Nov 2016) $)
%

bs1 = obj.get_must_fit();
bs2 = other_obj.get_must_fit();

keys = bs1.keys();
for i=1:numel(keys)
    theKey = keys{i};
    bl1= bs1(theKey);
    bl2 = bs2(theKey);
    if numel(bl1) == numel(bl2)
        for j=1:size(bl1,2)
            if bl1(2,j) ~= bl2(2,j)
                ok = false;
                return
            end
        end
    else
        ok=false;
        return
    end
end
ok = true;

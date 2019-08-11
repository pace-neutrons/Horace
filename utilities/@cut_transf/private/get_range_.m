function range = get_range_(obj,dir)
% Return cut range in specified direction
% dir -- direction of cut (1,2 or 3)
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%
if dir<4
    shift = obj.zone_center(dir);
else
    shift = 0;
end
if isnan(obj.dqe_(dir))
    range = obj.qe_range_(dir,:)+shift;
else
    range = [obj.qe_range_(dir,1)+shift,...
        obj.dqe_(dir),obj.qe_range_(dir,2)+shift];
end


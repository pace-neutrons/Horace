function ok = set_upgrade(obj,other_obj)
% checj if this object can be upgraded using position information
% from another object and set upgrade depending on the information received
%
% $Revision: 1315 $ ($Date: 2016-11-03 14:36:26 +0000 (Thu, 03 Nov 2016) $)
%
error('SQW_FILE_IO:runtime_error','set_upgrade: set global upgrade is not yet implemented');
% 
% bs1 = obj.calc_cblock_sizes();
% 
% bs2 = other_obj.calc_cblock_sizes();
% 
% keys = bs1.keys();
% for i=1:numel(keys)
%     theKey = keys{i};
%     bl1= bs1(theKey);
%     bl2 = bs2(theKey);
%     if bl1(2) ~= bl2(2) 
%         ok = false;
%         return
%     end
% end
% ok = true;
% 
% %data_form = obj.get_dnd_form('-const');


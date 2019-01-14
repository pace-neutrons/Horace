function [T1,T2] = hat_times(disk)
% Return the FWHH of the two hat functions that when convoluted give the pulse
%
%   >> [T1,T2] = hat_times(disk)
%
% Input:
% ------
%   disk    IX_doubledisk_chopper object
%
% Output:
% -------
%   T1      Narrower hat FWHH (microseconds)
%   T2      Wider hat function (microseconds)

T_slot = 1e6*disk.slot_width/(2*pi*disk.radius*disk.frequency);
T_aperture = 1e6*disk.aperture_width/(2*pi*disk.radius*disk.frequency);
if T_aperture <= T_slot
    T1 = T_aperture/2;
    T2 = T_slot - T1;
else
    T1 = Tslot/2;
    T2 = T1;
end

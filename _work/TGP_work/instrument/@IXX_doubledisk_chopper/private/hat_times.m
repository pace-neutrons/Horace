function [T1,T2] = hat_times(self)
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

T_slot = 1e6*self.slot_width_/(2*pi*self.radius_*self.frequency_);
T_aperture = 1e6*self.aperture_width_/(2*pi*self.radius_*self.frequency_);
if T_aperture <= T_slot
    T1 = T_aperture/2;
    T2 = T_slot - T1;
else
    T1 = T_slot/2;
    T2 = T1;
end

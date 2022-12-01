function [T1, T2] = hat_times (obj)
% Return the FWHH of the two hat functions that when convoluted give the pulse
%
%   >> [T1, T2] = hat_times (obj)
%
% Input:
% ------
%   obj     IX_doubledisk_chopper object (scalar)
%
% Output:
% -------
%   T1      Narrower hat FWHH (microseconds)
%
%   T2      Wider hat function (microseconds)


if obj.slot_width_==0 && obj.radius_==0 && obj.frequency_==0 && ...
        obj.aperture_width==0
    % Special case of the null chopper
    % If all the chopper parameters are zero, then we take this to permit
    % a delta function pulse shape. This is so that the default constructor
    % permits transmission, but does not correspond to a special set i.e. a
    % parochial set of parameters
    T1 = 0;
    T2 = 0;
    
else
    % One or more chopper parameters have been set
    T_slot = 1e6 * obj.slot_width_ / (2*pi * obj.radius_ * obj.frequency_);
    T_aperture = 1e6 * obj.aperture_width/(2*pi * obj.radius_ * obj.frequency_);
    if T_aperture <= T_slot
        T1 = T_aperture / 2;
        T2 = T_slot - T1;
    else
        T1 = T_slot / 2;
        T2 = T1;
    end
    
end

end

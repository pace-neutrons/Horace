function wout=fix_magnetic_ff(self,win)
% Correct scattering intensity in a dataset for the magnetic scattering
% form factor of the magnetic ion defined by the class.
%
% Deprecated method. Use correct_mag_ff instead
%
%
%
% $Revision:: 1759 ($Date:: 2020-02-10 16:06:00 +0000 (Mon, 10 Feb 2020) $)
%


warning('HORACE:fix_magnetic_ff:deprecated',...
    '"fix_magnetic_ff" method is deprecated. Use "correct_mag_ff" instead');
wout=self.correct_mag_ff(win);

function wout=fix_magnetic_ff(self,win)
% Correct scattering intensity in a dataset for the magnetic scattering
% form factor of the magnetic ion defined by the class.
%
% Deprecated method. Use correct_mag_ff instead
%
%
%
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
%


warning('MAGNETICIONS:depricated_method',...
    'fix_magnetic_ff method is deprecated. Use correct_mag_ff instead');
wout=self.correct_mag_ff(win);


function wout=fix_magnetic_ff(self,win)
% Correct scattering intensity in a dataset for the magnetic scattering
% form factor of the magnetic ion defined by the class.
%
% Deprecated method. Use correct_mag_ff instead
%
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%


warning('MAGNETICIONS:depricated_method',...
    'fix_magnetic_ff method is deprecated. Use correct_mag_ff instead');
wout=self.correct_mag_ff(win);


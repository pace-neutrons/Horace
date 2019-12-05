function wout=apply_mag_ff(self,win)
% Calculate magnetic form-factor of selected magnetic ion and apply this
% form factor to the dataset proviede as input
%
%
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>sqw_mag = mi.apply_mag_ff(sqw_data)
%where:
% 'Fe0'    -- the name of the ion, which scattering is corrected.
% sqw_data -- dnd or sqw dataset to modify.
%
% Returns:
% sqw_mag  -- input dataset multiplied by the magnetic form factor of
%             the selected ion.
%             Signal on each pixel in sqw dataset is also multiplied if
%             a sqw dataset is modified.
%
%
% Note:
% * Repetetive applications of the corrections to the same dataset works and
%   causes wrong corrections.
% * Subsequent appliations of apply_mag_ff and correct_mag_ff  should return
%   initial dataset (within the round-off errors caused by multiplitation and then
%   division by the same (often large or small) numbers.

%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)
%



%
% conversion factor to change from rlu to wave-vector in A^(-1)
%
sqw_magFF = self.calc_mag_ff(win);

wout=mtimes(win,sqw_magFF);



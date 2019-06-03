function wout=correct_mag_ff(self,win)
% Correct scattering intensity in a dataset for the magnetic scattering
% form factor of the magnetic ion defined by the class.
%
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>sqw_corrected = mi.correct_mag_ff(sqw_data)
%where:
% 'Fe0'    -- the name of the ion, which scattering is corrected.
% sqw_data -- dnd or sqw dataset to correct.
%
% Returns:
% sqw_corrected  -- input dataset divided by the magnetic form factor of
%                   the selected ion.
%                   Signal on each pixel in sqw dataset
%                   is also divided if sqw dataset is corrected.
%
%
% Notes:
% * Repetetive applications of the corrections to the same dataset works and
%   causes wrong corrections.
% * Subsequent appliations of correct_mag_ff and apply_mag_ff should return
%   initial dataset (within the round-off errors caused by division and then
%   multiplication by the same (often large or small) numbers.
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%


%
sqw_magFF = self.calc_mag_ff(win);
%
wout=mrdivide(win,sqw_magFF);


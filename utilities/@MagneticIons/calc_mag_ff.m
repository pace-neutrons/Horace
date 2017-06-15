function magFF=calc_mag_ff(self,win)
% Calculates magnetic form factor of the magnetic ion, defined by the class
% on the dataset, provided as input
%
% List of magnetic ions with defined form factors can be retrieved from
% MagneticIons class.
%
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>mag_ff_dataset = mi.calc_mag_ff(sqw_data)
%where:
% 'Fe0'    -- the name of the ion, which scattering is corrected.
% sqw_data -- dnd or sqw dataset used as base to calculate magnetic
%             form factor on.
%
% Returns:
% mag_ff_dataset -- The dataset containing the same points as the input dataset
%                   but the values equal to the magnetic form factors values
%                   for the selected magnetic ion.
%
% $Revision$ ($Date$)
%



%
% Get conversion matrix used to change from rlu to wave-vector in A^(-1)
if isa(win,'sqw')
    header_ave=header_average(win);    
    self.u_2_rlu_ = header_ave.u_to_rlu(1:3,1:3);    
    %self.u_2_rlu_ = win.data.u_to_rlu(1:3,1:3);
else
    self.u_2_rlu_ = inv(bmatrix(win.alatt,win.angdeg));
end

magFF=sqw_eval(win,@(h,k,l,en,argi)form_factor(self,h,k,l,en,argi),[]);


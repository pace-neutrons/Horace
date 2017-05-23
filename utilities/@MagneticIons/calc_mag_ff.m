function magFF=calc_mag_ff(self,win)
% Calcualste magnetic form factor of the magnetic ion, defined by the class
% on the dataset, provided as input
%
% List of magnetic ions with defined form factors can be retrived from
% MagneticIons class.
%
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>mag_ff_dataset = mi.calc_mag_ff(sqw_data)
%where:
% 'Fe0'    -- the name of the ion, which scattering is corrected.
% sqw_data -- dnd or sqw dataset to correct.
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
    self.u_2_rlu_ = win.data.u_to_rlu(1:3,1:3);
else
    self.u_2_rlu_ = win.u_to_rlu(1:3,1:3);
end

magFF=sqw_eval(win,@form_factor,self);


%==============================

function FF = form_factor(h,k,l,en,self)
% function calculates magnetic form-factor using exponential representation
%
u_2_rlu = self.u_2_rlu_;
q = u_2_rlu\[h';k';l'];

q2 = (q(1,:).*q(1,:)+q(2,:).*q(2,:)+q(3,:).*q(3,:))/(16*pi*pi);
FF=self.J0_ff_(q2).^2+self.J2_ff_(q2).^2+self.J4_ff_(q2).^2+self.J6_ff_(q2).^2;


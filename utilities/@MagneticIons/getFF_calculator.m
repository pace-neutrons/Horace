function  fint = getFF_calculator(self,win)
% return function hanlde to calculate magnetic form factor on
% q-vector expressed in hkl units.
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>fint = mi.getFF_calc(win);
% Where:
% win -- a dnd or sqw object providing method to transform from hkl to
%        crystal cartesian coordinate system in A^-1 units.
% Retufns:
% function handle to to use as input to sqw_eval function
%>> wout = sqw_eval(win,fint,[]);
%
% or directly in the form:
%>>ff = fint(h,k,l,en,[]);
% where ff then will be vector of the h (k,l) length containing magnetic
% form factor calculated in h,k,l points.
%
% Form factor function has to have 5 parameters for it to be used by sqw_eval
% function despite two last parameters (en and var) are not used by the
% form factor.
%
%

if isa(win,'sqw')
    self.u_2_rlu_ = win.data.u_to_rlu(1:3,1:3);
else
    self.u_2_rlu_ = win.u_to_rlu(1:3,1:3);
end


fint = @(h,k,l,en,argi)form_factor(self,h,k,l,en,argi);


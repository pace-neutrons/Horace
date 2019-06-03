function  fint = getFF_calculator(self,win)
% return function handle to calculate magnetic form factor on
% q-vector expressed in hkl units.
%
%Usage:
%>>mi= MagneticIons('Fe0')
%>>fint = mi.getFF_calculator(win);
%
% Where:
% win -- a dnd or sqw object providing method to transform from hkl to
%        crystal Cartesian coordinate system in A^-1 units
%  or    3x3 Busing & Levy 's B-matrix (Acta Crystallographica, 1967(4) pp.457-464)
%        used to convert from crystal Cartesian to hkl coordinate system
% Returns:
% fint -- function handle to use as input to sqw_eval function:
%>> wout = sqw_eval(win,fint,[]);
% or directly in the form:
%>>ff = fint(h,k,l,en,[]);
%
% where ff then is the vector of the h (k,l) length containing magnetic
% form factor calculated in h,k,l points.
%
% Alternatively, magnetic form factor can be calculated in a form:
%%>> wout = sqw_eval(win,fint,B_mat);
%or
%>>ff = fint(h,k,l,en,B_mat);
% where
%B_mat -- Busing & Levy 's B-matrix (Acta Crystallographica, 1967(4) pp.457-464)
%         used to convert from crystal Cartesian to hkl coordinate
%         system
% If provided, used instead of B-matrix defined by sqw object
%
% Note:
% Form factor function fint has to have 5 parameters for it to be used by sqw_eval
% according to sqw_eval internal interface.
%
% Fourth parameter: energy transfer (en) is not not used by the form factor.
% Fifth parameter:  must be empty (not used) or B-matrix used instead of
%                   the matrix defined by sqw/dnd object
%
%
%
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)
%

if isa(win,'sqw')
    header_ave=header_average(win);
    self.u_2_rlu_ = header_ave.u_to_rlu(1:3,1:3);
    %self.u_2_rlu_ = win.data.u_to_rlu(1:3,1:3);
elseif isnumeric(win) || size(win) == [3,3]
    self.u_2_rlu_ = inv(win);
else
    self.u_2_rlu_ = win.u_to_rlu(1:3,1:3);
end


fint = @(h,k,l,en,argi)form_factor(self,h,k,l,en,argi);


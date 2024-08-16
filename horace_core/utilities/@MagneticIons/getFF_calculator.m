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
%

if isa(win,'sqw')
    self.proj_ = win.data.proj;
elseif isnumeric(win) || all(size(win) == [3,3])
    proj = line_proj([1,0,0], [0,1,0]);
    % Uses the identity:
    % inv(B^T * B) = [aa ab.cos(gamma) ac.cos(beta);
    %                 ab.cos(gamma) bb bc.cos(alpha);
    %                 ac.cos(beta) bc.cos(alpha) cc];
    bb = inv(win' * win);
    alatt = sqrt(diag(bb));
    angdeg(1) = acos(bb(2,3) / prod(alatt(2:3)));
    angdeg(2) = acos(bb(1,3) / prod(alatt([1 3])));
    angdeg(3) = acos(bb(1,2) / prod(alatt(1:2)));
    proj.alatt = 2*pi * alatt;
    proj.angdeg = angdeg * 180 / pi;
    self.proj_ = proj;
else
    self.proj_ = win.proj;
end

fint = @(h,k,l,en,argi)form_factor(self,h,k,l,en,argi);



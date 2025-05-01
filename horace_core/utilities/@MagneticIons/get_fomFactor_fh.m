function  [fh,self] = get_fomFactor_fh(self,varargin)
% Return cellarray fh of function handles used to calculate magnetic form factor.
%
% Method returns cellarray of 4 function handles, used for calculating Magnetic
% form factor of a specific magnetic ion. The functions depend on
% Q2 = q^2/(16*pi^2) where q is the modulo of momentum transfer expressed
% in Horace Crystal Cartesian coordinate system. The magnetic form factor
% is calculated in the form: 
% MFF = fh{1}(Q2).^2+fh{2}(Q2).^2+fh{3}(Q2).^2+fh{4}(Q2).^2;
% (assuming state with 0 orbital and unit spin momentum)
% See https://www.ill.eu/sites/ccsl/ffacts/ffachtml.html and A.T.Boothroyd
% for full computational formulas based on polynomials provided.
%
% Usage:
% >>fh = mi.get_formFactor_fh();
% >>[fh,mi] = mi.get_formFactor_fh(IonName);
%
% Input:
% self     -- initiated instance of MagneticIonClass
%
% Optional:
% IonName  -- if provided, the name of the magnetic ion to return fucntions
%             for if different from the one, already used in MagneticIon.
%             Returned version of class in this case would have this ion
%             set as basis ion.
%Returns:
% fh       -- cellarray of 4 function handles used to calculate magnetic
%             form factor as described above.
% self     -- instance of MagnetiIon class. Modified with different ion
%             name if the name was provided above.

if nargin>1
    self.currentIon = varargin{1};
end
fh = {self.J0_ff_,self.J2_ff_,self.J4_ff_,self.J6_ff_};
end
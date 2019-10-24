function FF = form_factor(self,h,k,l,varargin)
% method calculates magnetic form-factor
%
% Inputs:
% self  - instance of Magnetic ion class with defined u_to_rlu matrix converting
%         from crystal Cartesian coordinate system to hkl representation
% h,k,l - coordinates of Q-vector in hkl representation
%
% optional:
% en       -- unused vector of energy transfers, provided for
%             compartibility with sqw_eval interface.
% b_matrix -- Busing & Levy 's B-matrix (Acta Crystallographica, 1967(4) pp.457-464)
%             used to convert from crystal cartezian to hkl coordinate system
%             If provided, used instead of B-matix defined by sqw object
%
% Returns vector of changes of magnetic form factors along input hkl vector
% for the selected ion.
%
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)
%
if numel(varargin) > 1 && nargin > 5 && ~isempty(varargin{2})
    u_2_rlu = inv(varargin{2});
else
    u_2_rlu = self.u_2_rlu_;    

end
q = u_2_rlu\[h';k';l'];    


q2 = (q(1,:).*q(1,:)+q(2,:).*q(2,:)+q(3,:).*q(3,:))/(16*pi*pi);
FF=self.J0_ff_(q2).^2+self.J2_ff_(q2).^2+self.J4_ff_(q2).^2+self.J6_ff_(q2).^2;


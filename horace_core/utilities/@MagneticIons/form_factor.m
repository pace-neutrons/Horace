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
% proj     -- Instance of aProjection base class initialized to perform
%             transform_hkl_to_pix operation.
%
%
% Returns vector of changes of magnetic form factors along input hkl vector
% for the selected ion.
%
%
%
if numel(varargin) > 1 && nargin > 5 && ~isempty(varargin{2})
    proj = varargin{2};
else
    proj = self.proj_;
end

q = proj.transform_hkl_to_pix([h';k';l']);

q2 = (q(1,:).*q(1,:)+q(2,:).*q(2,:)+q(3,:).*q(3,:))/(16*pi*pi);
FF=self.J0_ff_(q2)+self.J2_ff_(q2)+self.J4_ff_(q2)+self.J6_ff_(q2);



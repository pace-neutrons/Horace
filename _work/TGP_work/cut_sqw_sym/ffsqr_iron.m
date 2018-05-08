function ffsqr = ffsqr_iron (qh,qk,ql)
% Form factor for iron from International tables of crystallography
%
%   >> ffsqr = ffsqr_iron (qh,qk,ql)
%
% Input:
% ------
%   qh, qk, ql  Arrays of components of momentum in r.l.u for bcc iron
%
% Output:
% -------
%   ffsqr       Square of magnetic form factor


ssqr = (((2*pi/2.87))^2/(16*pi^2))*(qh.^2 + qk.^2 + ql.^2);  % assumes iron lattice parameter = 2.87 Ang
ffpar = [0.0706, 35.008, 0.3589, 15.358, 0.5819, 5.561, -0.0114, 0.1398];
ffsqr = (ffpar(1)*exp(-ffpar(2)*ssqr)+ffpar(3)*exp(-ffpar(4)*ssqr)+ffpar(5)*exp(-ffpar(6)*ssqr)+ffpar(7)).^2;

function d = slice_3d (data_source, u, v, p0, u1_bin, u2_bin, qperp, type)
% 
% input:
%   data_source File containing (h,k,l,e) data
%   u(1:3)      Vector defining first plot axis (r.l.u.)
%   v(1:3)      Vector defining plane of plot in Q-space (r.l.u.)
%           The plot plane is defined by u and the perpendicular to u in the
%           plane of u and v. The unit lengths of the axes are determined by the
%           character codes in the variable 'type' described below
%            - if 'a': unit length is one inverse Angstrom
%            - if 'r': then if (h,k,l) in r.l.u., is normalised so max([h,k,l])=1
%           Call the orthogonal set created from u and v: u1, u2, u3.
%   p0(1:3)     Vector defining origin of the plane in Q-space (r.l.u.)
%   ubin(1:3)   Binning along u axis: [u1_start, u1_step, u1_end]
%   vbin(1:3)   Binning perpendicular to u axis within the plot plane:
%                                     [u2_start, u2_step, u2_end]
%   qperp       Thickness of binning perpendicular to plot plane: +/-(qperp/2)
%   type        Units of binning and thickness: a three-character string,
%               each character indicating if u1, u2, u3 normalised to Angstrom^-1
%               or r.l.u., max(h,k,l)=1.

ustep = [u1_bin(2), u2_bin(2), qperp];  % get step sizes

h_main = read_main_header (data_source);
for iblock = 1:h_main.nblock
    h = read_block_header (data_source);
    [rlu_to_ustep, u_to_rlu, ulen] = rlu_to_ustep_matrix (h.alatt, h.angdeg, u, v, ustep, type)
    
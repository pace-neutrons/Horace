function qw=calculate_qw_bins(win,varargin)
% Calculate qh,qk,ql,en for the centres of the bins of an n-dimensional sqw or dnd dataset
%
%   >> qw=calculate_qw_bins(win)
%   >> qw=calculate_qw_bins(win,'boundaries')
%   >> qw=calculate_qw_bins(win,'edges')
%
% Input:
% ------
%   win         Input sqw or dnd object
%
% Optional arguments:
% 'boundaries'  Return qh,qk,ql,en at verticies of bins, not centres
% 'edges'       Return qh,qk,ql,en at verticies of the hyper cuboid that
%               encloses the plot axes
% '3D'          return only q-edges (no
%
% Output:
% -------
%   qw          Components of momentum (in rlu) and energy for each bin in
%              the dataset Arrays are packaged as cell array of column vectors
%              for convenience with fitting routines etc.
%                   i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en
%               Note that the centre of the integration range is used in
%              the calculation of qh,qk,ql,en even with the options
%              'boundaries' or 'edges'
%               If one or both of the integration ranges is infinite, then
%              the value of the corresponding coordinate is taken as zero.

if numel(win)~=1
    error('HORACE:DnDBase:invalid_argument', ...
        'Only a single object is valid - cannot take an array of %s objects',...
        class(win))
end
options = {'-boundaries','-edges','-3D'};
argi = cellfun(@check_dash,varargin,'UniformOutput',false);
[ok,mess,boundaries,edges,do_3D] = parse_char_options(argi,options);
if ~ok
    error('HORACE:DnDBase:invalid_argument',mess)
end
if boundaries && edges
    error('HORACE:DnDBase:invalid_argument', ...
        'boundaries and edges can not be provided together')
end
if boundaries
    argi = {'-plot_edges'};
elseif edges
    argi = {'-plot_edges','-hull'};
else
    argi = {'-bin_centre'};
end
if do_3D
    argi = ['-3D';argi(:)'];
end

nodes = win.axes.get_bin_nodes(argi{:});

proj = win.proj;
pix_cc = proj.from_img_to_pix(nodes);
% Optimization possible as new method of aProjection!
if isempty(proj.ub_inv_legacy)
    b_mat = bmatrix(proj.alatt,proj.angdeg);
    pix_hkl = b_mat\pix_cc(1:3,:);    
else
    pix_hkl = proj.ub_inv_legacy*pix_cc(1:3,:);    
end
% package as cell array of column vectors for convenience with fitting routines etc.
if do_3D
    qw = {pix_hkl(1,:)', pix_hkl(2,:)', pix_hkl(3,:)'};
else
    qw = {pix_hkl(1,:)', pix_hkl(2,:)', pix_hkl(3,:)',pix_cc(4,:)'};
end

function out_str = check_dash(in_str)
if strncmp(in_str,'-',1)
    out_str = in_str;
else
    out_str =strjoin({'-',in_str},'');
end
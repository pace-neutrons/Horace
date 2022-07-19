function qw=calculate_qw_bins(win,optstr)
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
qw = win.data.calculate_qw_bins(optstr);
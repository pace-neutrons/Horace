function wout = slice_3d (win, u, v, p0, p1_bin, p2_bin, p3_bin, varargin)
% Creates a 3D data set by integrating over one of the momentum or energy axes.
% Generalised version of cut function.
%
% Syntax:
%   >> wout = slice_3d (win, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type)
%
%  To give custom labels to the momentum axis labels
%   >> wout = slice_3d (win, u, v, p0, p1_bin, p2_bin, p3_bin, p4_bin, type, ...
%                                                     p1_lab, p2_lab, p3_lab)
% 
% Input:
% ------
%   win             Data source: 4D dataset object
%   u(1:3)          Vector defining first plot axis (r.l.u.)
%   v(1:3)          Vector defining plane of plot in Q-space (r.l.u.)
%        These two directions define a plane with the first axis parallel to u
%       and the second perpendicular to u in the plane of u and v. A third axis 
%       is defined as perpendicular to the plane of u and v, forming a right-hand
%       set. Call the orthogonal set created from u and v: p1, p2, p3.
%        The 4D grid is now built up from p1, p2, p3 and energy (called p4 below).
%        The unit lengths along the axes p1, p2 and p3 are determined by the 
%       character codes in the variable 'type' described below.
%           
%   p0(1:3)         Vector defining origin of the grid in momentum space (r.l.u.)
%   p1_bin(1:3)     Binning along p1 axis: [p1_start, p1_step, p1_end]
%   p2_bin(1:3)     Binning perpendicular to u axis within the plot plane:
%                           [p2_start, p2_step, p2_end]
%   p3_bin(1:3)     Binning perpendicular to p1 and p2: 
%                   - if this is to be the 3rd plot axis (i.e. energy will be integrated)
%                           [p3_start, p3_step, p3_end]
%                   - if integration is along this axis, give either
%                           [p3_start, p3_end]
%                     *OR*   p3_thick    - equivalent to  [-thick/2, +thick/2]
%   p4_bin(1:3)     Binning along the energy axis:
%                   - if this is the 3rd plot axis (i.e. p3 will be integrated):
%                           [p4_start, p4_step, p4_end]
%                     *OR* to use bin size from original spe files but change range:
%                           [p4_start, p4_end] 
%                     *OR* to use range and bin size from original spe files
%                        -- omit p4_bin --
%                       (If p4_step is smaller than that in the spe files,
%                         it is set equal to that in the spe files)
%                   - if integration is along this axis:
%                           [p4_start, p4_end] 
%   type            Defines measure of units length for binning.
%        Three-character string, each character indicating if p1, p2, p3 are
%       normalised to Angstrom^-1 or r.l.u., max(abs(h,k,l))=1:
%        - if 'a': unit length is one inverse Angstrom
%        - if 'r': then if (h,k,l) in r.l.u., is normalised so max(abs([h,k,l]))=1
%       e.g. type='rrr' or 'raa'
%
%   p1_lab          Short label for p1 axis (e.g. 'Q_h' or 'Q_{kk}')
%   p2_lab          Short label for p2 axis
%   p3_lab          Short label for p3 axis
%
%
% Output:
% -------
%   wout            3D dataset defined on orthogonal axes above
%
%
% EXAMPLES
%   >> win = readgrid ('RbMnF3.bin');
%   >> wout = slice_3d (win, [1,1,0], [0,0,1], [0.5,0.5,0.5],...
%                            [-1.5,0.05,1.5], [-2,0.05,2], 0.1, 'rrr');

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

wout = slice_3d (get(win), u, v, p0, p1_bin, p2_bin, p3_bin, varargin);

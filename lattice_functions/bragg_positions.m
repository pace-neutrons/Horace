function [rlu0,width,wcut,wpeak]=bragg_positions(w, rlu, cut_length, cut_thickness, bin_width, energy_window)
% Get actual Bragg peak positions given initial estimates of their positions.
%
%   >> rlu0=bragg_positions(w, proj, rlu, cut_length, cut_thickness, bin_width, energy_window)
%
%   >> [rlu0,widths,wcut,wpeak]=bragg_positions(...)   % Return cuts and peak analysis for each Bragg point
%
% Use this function to find the true peak positions of a set of Bragg peaks. You provide the estimate of
% their positions (usually just the indicies of the Bragg peaks) and some parameters that describe the
% length, bin size and thickness of cuts through the nominal positions. The output can then be passed
% to functions that refine the crystal orientation e.g. refine_crystal (type >> help refine_crystal
% for more details of this function.
%
% The algorithm performs thre orthogonal cuts through the nominal Bragg peak position, and finds the
% mid-point between the half-height positions either side of the peak for each of the three cuts. The
% process is repeated for each Bragg peak in the input list. Various diagnostic information is returned,
% including the cuts and peak analysis. Make sure that the length and thickness of the cut fully cover
% the peaks, and that the bin width is appropriate.
%
% In practice, when refining the crystal orientation it is a good idea to get an approximate correction
% from two key Bragg peaks (e.g. in the horizontal plane, about 90 degrees apart), and then perform a
% refinement with a large list of reflections. The first correction should ensure that the nominal
% Bragg peak positions are all close to the true positions, so there is little concern that the
% length, bin and thickness parameters are inappropriate.
%
% Summary of this and related functions:
%
%   bragg_positions         % get true Bragg peak positions 
%   refine_crystal          % get a matrix that relates the nominal crystal orientation to the true one
%   change_crystal_horace   % apply the correction matrix to an sqw or dnd file
%   change_crystal          % apply the correction matrix to an sqw or dnd object
%
%
%
% Input:
% ------
%   w               Data source (sqw file name or sqw object)
%   rlu             Set of nominal Bragg peak indicies in r.l.u. as a (n x 3) matrix:
%                       h1, k1, l1
%                       h2, k2, l2
%                       :   :   :
%                   These are the indicies of the Bragg peaks e.g. 1,0,0; 0,1,0
%   cut_length      Length of cut (Ang^-1)
%   cut_thickness   Thickness of cut (Ang^-1)
%   bin_width       Bin width (Ang^-1)
%   energy_window   Energy window around elastic line (meV)
%                     e.g. for -1meV to +1 meV, set  energy_window=2
%
% Output:
% -------
%   rlu0            The actual peak positions as (n x 3) matrix of h,k,l as indexed with
%                  the current lattice parameters
%   widths          Array (size (n x 3)) containing the FWHH in Ang^-1 of the peaks along each of the three projection axes
%   wcut            Array of cuts, size (n x 3),  along three orthogonal directions
%                  through each Bragg point from which the peak positions were determined
%                  The cuts are IX_dataset_1d objects and can be plotted using the plot
%                  functions for these methods.
%   wpeak           Array of spectra, size (n x 3), that summarise the peak analysis.
%                  Can be overplotted on the corresponding cuts in output argument wcut.
%                  The peak summaries are IX_dataset_1d objects and can be plotted using the plot
%                  functions for these methods.

% Check input arguments
if ischar(w)    % assume a file name
    if ~is_sqw_type_file(sqw,w)
        error('File must be sqw type')
    end
    h=head_sqw(w);  % get header information
elseif isa(w,'sqw') && is_sqw_type(w)
    if iscell(w.header)     % *** Really ought to have header_ave as a method. Use same algorithm here.
        h=w.header{1};
    else
        h=header;
    end
else
    error('Object must be sqw type')
end

npeaks=size(rlu,1);
if size(rlu,2)~=3 || npeaks==0
    error('The input Bragg point must form an (n x 3) array, one row per Bragg peak')
end

% Initialise output arguments
width=zeros(size(rlu));
wcut=repmat(IX_dataset_1d,npeaks,3);
wpeak=repmat(IX_dataset_1d,npeaks,3);

% Get peak positions in input projection axes
u2rlu=h.u_to_rlu(1:3,1:3);
ulen=h.ulen;

% Get cut binning and integration for each projection axes
bin1=bin_width; len1=cut_length; wid1=cut_thickness;
bin2=bin_width; len2=cut_length; wid2=cut_thickness;
bin3=bin_width; len3=cut_length; wid3=cut_thickness;
eint=[-energy_window/2,energy_window/2];

upos0=zeros(size(rlu'));    % 3 x n matrix of peak positions w.r.t. nominal Bragg peak positions
for i=1:size(rlu,1)
    proj.uoffset=rlu(i,:);  % centre of cut is the nominal Bragg peak position
    proj.u=u2rlu(:,1)';     % retain direction of input projection axes
    proj.v=u2rlu(:,2)';
    proj.type='aaa';        % force length of projection axes to be 1 Ang^-1
    
    % Make three orthogonal cuts through nominal Bragg peak positions
    w1a_1=cut_sqw(w, proj, [-len1/2,bin1,+len1/2] ,[-wid2/2,+wid2/2]      ,[-wid3/2,+wid3/2],      eint, '-nopix');
    w1a_2=cut_sqw(w, proj, [-wid1/2,+wid1/2]      ,[-len2/2,bin2,+len2/2] ,[-wid3/2,+wid3/2],      eint, '-nopix');
    w1a_3=cut_sqw(w, proj, [-wid1/2,+wid1/2]      ,[-wid2/2,+wid2/2]      ,[-len3/2,bin3,+len3/2], eint, '-nopix');
    
    % Get peak positions
    [upos0(1,i),dum1,width(i,1),dum2,dum3,dum4,w1a_1_pk]=peak_cwhh(IX_dataset_1d(w1a_1));
    [upos0(2,i),dum1,width(i,2),dum2,dum3,dum4,w1a_2_pk]=peak_cwhh(IX_dataset_1d(w1a_2));
    [upos0(3,i),dum1,width(i,3),dum2,dum3,dum4,w1a_3_pk]=peak_cwhh(IX_dataset_1d(w1a_3));
    upos0(1,i)=upos0(1,i)/ulen(1);    % Convert peak positions back to multiples of input projection axes
    upos0(2,i)=upos0(2,i)/ulen(2);
    upos0(3,i)=upos0(3,i)/ulen(3);
    
    % Fill output spectra with cuts and peak analysis
    wcut(i,1)=IX_dataset_1d(w1a_1);
    wcut(i,2)=IX_dataset_1d(w1a_2);
    wcut(i,3)=IX_dataset_1d(w1a_3);
    wpeak(i,1)=w1a_1_pk;
    wpeak(i,2)=w1a_2_pk;
    wpeak(i,3)=w1a_3_pk;
end

% Convert peak position into r.l.u.
rlu0=(u2rlu*upos0 + rlu')';

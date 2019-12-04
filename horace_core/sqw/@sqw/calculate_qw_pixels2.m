function qw=calculate_qw_pixels2(win)
% Calculate qh,qk,ql,en for the pixels in an sqw dataset from the headers
%
%   >> qw=calculate_qw_pixels(win)
%
% This method differs from calculate_qw_pixels because it recomputes the values
% of momentum and energy from efix, emode and the detector information. This is
% necessary if the sqw object contains symmetrised data, for example.
%
% Input:
% ------
%   win     Input sqw object
%
% Output:
% -------
%   qw      Components of momentum (in rlu) and energy for each pixel in the dataset
%           Arrays are packaged as cell array of column vectors for convenience
%           with fitting routines etc.
%               i.e. qw{1}=qh, qw{2}=qk, qw{3}=ql, qw{4}=en

% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)


% Get some 'average' quantities for use in calculating transformations and bin boundaries
% *** assumes that all the contributing spe files had the same lattice parameters and projection axes
% This could be generalised later - but with repercussions in many routines

if numel(win)~=1
    error('Only a single sqw object is valid - cannot take an array of sqw objects')
end

c=neutron_constants;
k_to_e = c.c_k_to_emev;

irun = win.data.pix(5,:)';   % column vector
idet = win.data.pix(6,:)';   % column vector
ien  = win.data.pix(7,:)';   % column vector

if ~iscell(win.header)
    header={win.header};
    emode = header.emode;
    efix = header.efix;
    eps_lo=0.5*(header.en(1)+header.en(2));
    eps_hi=0.5*(header.en(end-1)+header.en(end));
    ne=numel(header.en)-1;
    [~, ~, spec_to_rlu] = calc_proj_matrix (header.alatt, header.angdeg,...
        header.cu, header.cv, header.psi, header.omega,...
        header.dpsi, header.gl, header.gs);
else
    header = win.header;
    emode = cellfun(@(x)(x.emode),header);
    if ~all(emode==emode(1))
        error('Contributing runs to an sqw object must be all be direct geometry or all indirect geometry')
    end
    emode = emode(1);
    efix = cellfun(@(x)(x.efix),header);
    eps_lo = cellfun(@(x)(0.5*(x.en(1)+x.en(2))),header);
    eps_hi = cellfun(@(x)(0.5*(x.en(end-1)+x.en(end))),header);
    ne = cellfun(@(x)(numel(x.en)-1),header);
    spec_to_rlu = zeros(3,3,numel(header));
    for i=1:numel(header)
        h = header{i};  % for clarity in next line
        [~, ~, spec_to_rlu(:,:,i)] = calc_proj_matrix (h.alatt, h.angdeg,...
            h.cu, h.cv, h.psi, h.omega, h.dpsi, h.gl, h.gs);
    end
end

eps=(eps_lo(irun).*(ne(irun)-ien)+eps_hi(irun).*(ien-1))./(ne(irun)-1);
[~, detdcn] = spec_coords_to_det (win.detpar);
kfix = sqrt(efix/k_to_e);

if emode==1
    ki = kfix(irun);
    kf = sqrt((efix(irun)-eps)/k_to_e);
elseif emode==2
    ki = sqrt((efix(irun)+eps)/k_to_e);
    kf = kfix(irun);
else
    ki = kfix(irun);
    kf = ki;
end
qw = cell(1,4);
qw(1:3) = calculate_q (ki, kf, detdcn(:,idet), spec_to_rlu(:,:,irun));
qw{4} = eps;



%----------------------------------------------------------------------------------------
function [d_mat, detdcn] = spec_coords_to_det (detpar)
% Matrix to convert coordinates in spectrometer (or laboratory) frame into detector frame
%
%   >> d_mat = spec_coords_to_det (detpar)
%
% Input:
% ------
%   detpar      Detector parameter structure with fields as read by get_par
%
% Output:
% -------
%   d_mat       Matrix size [3,3,ndet] to take coordinates in spectrometer
%              frame and convert in detector frame.
%
%   detdcn      Direction of detector in spectrometer coordinates ([3 x ndet] array)
%               [cos(phi); sin(phi).*cos(azim); sin(phi).sin(azim)]
%
% The detector frame is one with x axis along kf, y radially outwards. This is the
% original Tobyfit detector frame.

ndet=numel(detpar.x2);
cp=reshape(cosd(detpar.phi),[1,1,ndet]);
sp=reshape(sind(detpar.phi),[1,1,ndet]);
cb=reshape(cosd(detpar.azim),[1,1,ndet]);
sb=reshape(sind(detpar.azim),[1,1,ndet]);

d_mat=[             cp, cb.*sp, sb.*sp;...
    -sp, cb.*cp, sb.*cp;...
    zeros(1,1,ndet),    -sb,     cb];

detdcn=[cp; cb.*sp; sb.*sp];


%----------------------------------------------------------------------------------------
function q = calculate_q (ki, kf, detdcn, spec_to_rlu)
% Calculate qh,qk,ql for direct geometry instrument
%
%   >> q = calculate_q (ki, kf, detdcn, spec_to_rlu)
%
% Input:
% ------
%   ki          Incident wavevectors for each point [Column vector]
%   kf          Final wavevectors for each point    [Column vector]
%   detdcn      Array of unit vectors in the direction of the detectors
%               Size is [3,npnt]
%   spec_to_rlu Matrix to convert momentum in spectrometer coordinates to
%               components in r.l.u.:
%                   v_rlu = spec_to_rlu * v_spec
%               Size is [3,3,npnt]
%
% Output:
% -------
%   q           Components of momentum (in rlu) for each point
%               [Cell array of column vectors]
%               i.e. q{1}=qh, q{2}=qk, q{3}=ql

% Use in-place working to save memory (note: bsxfun not needed from 2016b an onwards)
qtmp = bsxfun(@times,-kf',detdcn);      % -kf in spectrometer axes
qtmp(1,:) = ki' + qtmp(1,:);            % qspec proper now
qtmp = mtimesx_horace (spec_to_rlu,reshape(qtmp,[3,1,numel(ki)]));
qtmp = squeeze(qtmp);

% Package output
q = cell(1,3);
q{1} = qtmp(1,:)';
q{2} = qtmp(2,:)';
q{3} = qtmp(3,:)';

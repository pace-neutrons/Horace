function varargout = resolution_plot (en, instrument, sample, detpar, efix, emode,...
    alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, varargin)
% Plot the instrumental resolution function
%
% New resolution plot:
%   >> resolution_plot (en, instrument, sample, detpar, efix, emode,...
%                           alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
%   >> resolution_plot (..., proj)
%   >> resolution_plot (..., iax)
%   >> resolution_plot (..., proj, iax)
%
% On current existing resolution plot:
%   >> resolution_plot (..., 'over')
%
% On current plot, or named or numbered existing plot
%   >> resolution_plot (..., 'curr')
%   >> resolution_plot (..., 'name', name)
%
%
% Input:
% ------
%   en              Energy bin boundaries for a single energy bin
%   instrument      Structure containing instrument description
%   sample          IX_sample object
%   detpar          Structure with detector parameters for a single detector
%                   Fields must include:
%                       x2      sample-detector distance (m)
%                       phi     scattering angle (deg)
%                       axim    azimuthal scattering angle (deg)
%                               (West bank=0 deg, North bank=90 deg etc.)
%                       width   detector width (m)
%                       height  detector height (m)
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2    [scalar]
%   alatt           Lattice parameters (Ang^-1)        [row or column vector]
%   angdeg          Lattice angles (deg)               [row or column vector]
%   u               First vector (1x3) defining scattering plane (r.l.u.)
%   v               Second vector (1x3) defining scattering plane (r.l.u.)
%   psi             Angle of u w.r.t. ki (deg)         [scalar or vector length nfile]
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   dpsi            Correction to psi (deg)            [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% {optional]
%   proj            Projection structure or object. Type help projaxes for details.
%                   Default: if not given or empty: assume to be spectrometer axes
%                  i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   iax             Indicies of axes into the projection for purposes of plotting
%                       [iax1, iax2]        plotting axes
%                       [iax1, iax2, iax3]  plotting axes and intersection axis
%
%                   Default: if not given or empty, assume first two projection axes
%                  and draw intersection with non-zero positive energy transfer deviation
%                  i.e. default is [1,2,4]
%
% Plot options:
%   'over'          If present, then overplot on an existing resolution function plot
%                   If one doesn't already exist, create a new resolution function plot
%
%   'curr'          Overplot on the currently active plot
%
%   'name', name    Overplot on the named figure or figure number of an existing plot


% *** Really should be using fake_sqw to create an sqw object, but as of 10 Nov 2018
%     it requires a par file, and will not accept a detpar structure. A fully 
%     object oriented sqw object construction would deal with this, but fot the
%     mean time, create an sqw object here.


% Check parameters
% ----------------
% Energies and sample orientation
nfiles_in = 1;
[ok,mess,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs]=gen_sqw_check_params...
    (nfiles_in,efix,emode,alatt,angdeg,u,v,psi,omega,dpsi,gl,gs);
if ~ok, error(mess), end
if ~(isnumeric(en) && numel(en)==2 && en(2)>=en(1))
    error('Energy bin argument must give lower and upper limits of a single energy bin')
end
hbarw = 0.5*(en(2)+en(1));
if emode==1 || emode==2
    if emode==1 && hbarw>=efix
        error('Energy loss cannot be larger than the incident energy')
    elseif emode==2 && hbarw<=-efix
        error('Energy gain cannot be larger than the final energy')
    end
else
    error('Must have emode=1 (direct geometry) or =2 (indirect geometry)')
end

% Optional arguments
key = struct ('over',false,'current',false,'name',[]);
flags = {'over','current'};
opts.flags_noneg = true;
opts.flags_noval = true;
[par,key,present] = parse_arguments (varargin, key, flags, opts);
if sum(cell2mat(struct2cell(present(2:end))))>1
    error('Only one of the plot options ''over'', ''current'' and ''name'' can be present')
end

% - Projection and/or iax:
proj = [];
iax = [1,2,4];
if numel(par)==1
    if ~isnumeric(par{1})   % can only be a projection
        if ~isempty(par{1}), proj = par{1}; end
    else
        if ~isempty(par{1}), iax = par{1}; end
    end
elseif numel(par)==2
    if ~isempty(par{1}), proj = par{1}; end
    if ~isempty(par{2}), iax = par{2}; end
elseif numel(par)~=0
    error('Check the number and type of optional arguments')
end

if ~(isempty(proj) || isa(proj,'projaxes'))
    proj = projaxes(proj);
end

if ~(isnumeric(iax) && (numel(iax)==2 || numel(iax)==3) &&...
        numel(unique(iax))==numel(iax) && all(iax>=1) && all(iax)<=4)
    error('Check axes indicies')
end

% - Plot target
if present.current && isempty(findobj(0,'Type','figure'))
    error('No current figure exists - cannot overplot')
end

if present.over
    plot_args = {'over'};
elseif present.current
    plot_args = {'current'};
elseif present.name
    plot_args = {'name',key.name};
else
    plot_args = {};
end



% Construct sqw object
% --------------------
% Create a two-dimensional sqw object with one pixel

% Make main_header
main_header.filename = '';
main_header.filepath = '';
main_header.title = '';
main_header.nfiles = nfiles_in;

wres.main_header = main_header;


% Make header
header.filename = '';
header.filepath = '';
header.efix = efix;
header.emode = emode;
header.alatt = alatt;
header.angdeg = angdeg;
header.cu = u;
header.cv = v;
header.psi = psi;
header.omega = omega;
header.dpsi = dpsi;
header.gl = gl;
header.gs = gs;
header.en = en;
header.uoffset = [0,0,0,0]';
header.u_to_rlu = zeros(4,4);
[~, header.u_to_rlu(1:3,1:3),spec_to_rlu] = calc_proj_matrix (alatt, angdeg,...
    u, v, psi, omega, dpsi, gl, gs);
header.u_to_rlu(4,4) = 1;
header.ulen = [1,1,1,1];
header.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
header.instrument = instrument;
header.sample = sample;

if isstruct(instrument) && isscalar(instrument)
    header.instrument = instrument;
else
    error('Instrument must be a scale structure')
end

if isa(sample,'IX_sample')
    header.sample = sample;
else
    error('Sample must be a scalar IX_sample object')
end

wres.header = header;


% Check detector
if ~isstruct(detpar)
    error('Detector parameters must form a structure')
end
if numel(detpar.x2)~=1
    error('Detector parameters can be for a single detector only')
end
if ~isfield(detpar,'filename'), detpar.filename = ''; end
if ~isfield(detpar,'filepath'), detpar.filepath = ''; end
if ~isfield(detpar,'group'), detpar.group = 1; end
wres.detpar = detpar;


% Make data structure
data.filename = '';
data.filepath = '';
data.title = '';
data.alatt = alatt;
data.angdeg = angdeg;
if ~isempty(proj)
    data.uoffset = proj.uoffset;
    data.u_to_rlu = zeros(4,4);
    data.ulen = zeros(1,4);
    [~, data.u_to_rlu(1:3,1:3), data.ulen(1:3), mess] = projaxes_to_rlu (proj, alatt, angdeg);
    if ~isempty(mess), error(mess); end
    data.u_to_rlu(4,4) = 1;
    data.ulen(4) = 1;
else
    data.uoffset = [0,0,0,0]';
    data.u_to_rlu = zeros(4,4);
    data.u_to_rlu(1:3,1:3) = spec_to_rlu;
    data.u_to_rlu(4,4) = 1;
    data.ulen = [1,1,1,1];
end
data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
ok=true(1,4); ok(iax(1:2))=false;
data.iax = find(ok);
data.iint = [-Inf,-Inf; Inf,Inf];
data.pax = iax(1:2);
data.p = {1e-10*(-3:2:3)'/3, 1e-10*(-3:2:3)'/3};    % something tiny
data.dax = [1,2];
data.s = zeros(3,3);
data.e = zeros(3,3);
data.npix = zeros(3,3);
data.urange = [data.uoffset;data.uoffset];
data.pix = [zeros(4,1);1;1;1;0;0];  % wrong (Q,w) - but will be filled in a later function

wres.data = data;

% Make the sqw object
wres = sqw(wres);


% Now plot the resolution function
% --------------------------------
if numel(iax)==2
    covariance_matrix = resolution_plot (wres, 'axis', 'none', plot_args{:});
else
    covariance_matrix = resolution_plot (wres, 'axis', iax(3), plot_args{:});
end


% Return covariance matrix, if requested
% --------------------------------------
if nargout==1
    varargout{1} = covariance_matrix;
end

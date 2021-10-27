function varargout = resolution_plot (en, instrument, sample, detpar, efix, emode,...
    alatt, angdeg, u, v, psi_deg, omega_deg, dpsi_deg, gl_deg, gs_deg, varargin)
% Plot the instrumental resolution function at a single detector.
%
% New resolution plot:
%   >> resolution_plot (en, instrument, sample, detpar, efix, emode,...
%                           alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%                                       % Plot in spectrometer frame (i.e. x || ki
%                                       % z vertically upwards, y perp to z and x
%                                       % Plots on x-y axes, with intersection on
%                                       % energy axis
%
%   >> resolution_plot (..., proj)      % Plot in specified projection axes
%   >> resolution_plot (..., iax)       % Plot for a specified set of axes
%   >> resolution_plot (..., proj, iax) % Both the above
%
% On current plot, or named or numbered existing plot:
%   >> resolution_plot (..., 'curr')        % on currently active plot
%   >> resolution_plot (..., 'name', name)  % on named plot
%
% Return the covariance matrix in various coordinate frames:
%   >> [cov_proj, cov_spec, cov_hkle] = resolution_plot (...)
%
% Without creating a plot (useful if just want the covariance matrix):
%   >> [cov_proj, cov_spec, cov_hkle] = resolution_plot (..., 'noplot')
%
%
% Input:
% ------
%   en              Energy bin boundaries for a single energy bin
%   instrument      Instrument description. Must be an objet whose class is
%                   derived from IX_inst e.g. IX_inst_DGfermi or IX_inst_DGdisk
%   sample          IX_sample object
%   detpar          Structure with detector parameters for a single detector
%                   Fields must include:
%                       x2      sample-detector distance (m)
%                       phi     scattering angle (deg)
%                       azim    azimuthal scattering angle (deg)
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
%   proj            Projection structure or object. Defines the coordinate frame in which
%                  to plot the resolution ellipsoid. Type help projaxes for details or <a href="matlab:help('projaxes');">Click here</a>.
%
%                   Default: if not given or empty: assume to be spectrometer axes
%                  i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   iax             Indicies of axes into the projection axes for purposes of plotting:
%                       [iax1, iax2]        plotting axes
%                       [iax1, iax2, iax3]  plotting axes and intersection axis
%                  where iax1 etc. are distinct axes indicies in the range 1 to 4.
%
%                   Default: if not given or empty, assume first two projection axes
%                  and draw intersection with non-zero positive energy transfer deviation
%                  i.e. default is [1,2,4]
%
% Plot options:
%   'curr'          Overplot on the currently active plot
%
%   'name', name    Overplot on the existing figure with the given name,
%                   figure number or figure handle
%
%
% Output:
% -------
%   cov_proj    Covariance matrix for wavevector-energy in projection axes (4x4 array)
%              [Note that if the default projection axes were used i.e.
%               input argument 'proj' was not given, then cov_proj and
%               cov_spec (below) are identical.]
%
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes (4x4 array)
%              i.e. x || ki, z vertically upwards, y perpendicular to z and x.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy (4x4 array)


% *** Really should be using fake_sqw to create an sqw object, but as of 10 Nov 2018
%     it requires a par file, and will not accept a detpar structure. A fully
%     object oriented sqw object construction would deal with this, but for the
%     mean time, create an sqw object here.


% Check parameters
% ----------------
% Energies and sample orientation
nfiles_in = 1;
[ok,mess,efix,emode,alatt,angdeg,u,v,psi_deg,omega_deg,dpsi_deg,gl_deg,gs_deg]=gen_sqw_check_params...
    (nfiles_in,efix,emode,alatt,angdeg,u,v,psi_deg,omega_deg,dpsi_deg,gl_deg,gs_deg);
if ~ok, error(mess), end
if ~(isnumeric(en) && numel(en)==2 && en(2)>=en(1))
    error('HORACE:resolution_plot:invalid_argument',...
        'Energy bin argument must give lower and upper limits of a single energy bin')
end
hbarw = 0.5*(en(2)+en(1));
if emode==1 || emode==2
    if emode==1 && hbarw>=efix
        error('HORACE:resolution_plot:invalid_argument',...
            'Energy loss cannot be larger than the incident energy')
    elseif emode==2 && hbarw<=-efix
        error('HORACE:resolution_plot:invalid_argument',...
            'Energy gain cannot be larger than the final energy')
    end
else
    error('HORACE:resolution_plot:invalid_argument',...
        'Must have emode=1 (direct geometry) or =2 (indirect geometry)')
end

% Optional arguments
key = struct ('noplot',false,'current',false,'name',[]);
flags = {'noplot','current'};
opts.flags_noneg = true;
opts.flags_noval = true;
[par,key,present] = parse_arguments (varargin, key, flags, opts);
present_logical = cell2mat(struct2cell(present));
if sum(present_logical)>1
    error('HORACE:resolution_plot:invalid_argument',...
        'Only one of the plot options ''noplot'', ''current'' and ''name'' can be present')
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
    error('HORACE:resolution_plot:invalid_argument',...
        'Check the number and type of optional arguments')
end

if ~isempty(proj) && ~isa(proj,'projaxes')
    proj = projaxes(proj);
end

if ~(isnumeric(iax) && (numel(iax)==2 || numel(iax)==3) &&...
        numel(unique(iax))==numel(iax) && all(iax>=1) && all(iax<=4))
    error('HORACE:resolution_plot:invalid_argument',...
        'Check axes indicies')
end

% - Plot target
% if present.current && isempty(findobj(0,'Type','figure'))
%     error('No current figure exists - cannot overplot')
% end

newplot = false;
if present.noplot
    plot_args = {'noplot'};
elseif present.current
    plot_args = {'current'};
elseif present.name
    plot_args = {'name',key.name};
else
    plot_args = {};
    newplot = true;
end


% Construct sqw object
% --------------------
% Create a two-dimensional sqw object with one pixel
psi = psi_deg * (pi/180);
omega = omega_deg * (pi/180);
dpsi = dpsi_deg * (pi/180);
gl = gl_deg * (pi/180);
gs = gs_deg * (pi/180);

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

if isa(instrument,'IX_inst') && isscalar(instrument)
    header.instrument = instrument;
else
    error('HORACE:resolution_plot:invalid_argument',...
        'Instrument must be a scalar instrument object')
end

if isa(sample,'IX_sample')
    header.sample = sample;
else
    error('HORACE:resolution_plot:invalid_argument',...
        'Sample must be a scalar IX_sample object')
end

wres.experiment_info = header;


% Check detector
if ~isstruct(detpar)
    error('HORACE:resolution_plot:invalid_argument',...
        'Detector parameters must form a structure')
end
if numel(detpar.x2)~=1
    error('HORACE:resolution_plot:invalid_argument',...
        'Detector parameters can be for a single detector only')
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
    % Projection axes were specified
    data.uoffset = proj.uoffset;
    data.u_to_rlu = zeros(4,4);
    data.ulen = zeros(1,4);
    [~, data.u_to_rlu(1:3,1:3), data.ulen(1:3), mess] = projaxes_to_rlu (proj, alatt, angdeg);
    if ~isempty(mess), error(mess); end
    data.u_to_rlu(4,4) = 1;
    data.ulen(4) = 1;
else
    % Make the projection axes correspond to the spectrometer axes
    data.uoffset = [0,0,0,0]';
    data.u_to_rlu = zeros(4,4);
    data.u_to_rlu(1:3,1:3) = spec_to_rlu;
    data.u_to_rlu(4,4) = 1;
    data.ulen = [1,1,1,1];
end
data.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
ok=true(1,4); ok(iax(1:2))=false;
data.iax = find(ok);
%data.iint = [-Inf,-Inf; Inf,Inf];
data.iint = 1e-10*[-1,-1; 1,1];
data.pax = iax(1:2);
data.p = {1e-10*(-3:2:3)'/3, 1e-10*(-3:2:3)'/3};    % something tiny
data.dax = [1,2];
data.s = [0,0,0; 0,NaN,0; 0,0,0];
data.e = [0,0,0; 0,NaN,0; 0,0,0];
data.npix = [0,0,0; 0,1,0; 0,0,0];
data.img_db_range = [data.uoffset;data.uoffset];
data.pix = PixelData([zeros(4,1);1;1;1;0;0]);  % wrong (Q,w) - but this is OK

wres.data = data;

% Make the sqw object. The defining qualities of this sqw object that mean it can be
% picked out as special are that it is:
% - single contributing spe file
% - single detector
% - 2D
% - signal array has size [3,3]
% - one pixel only, signal == variance both naN
% - (Q,w) is [0,0,0,0]
% This is not going to happen any other way than being constructed as a special here.

wres = sqw(wres);


% Now plot the resolution function
% --------------------------------
if numel(iax)==2
    [cov_proj, cov_spec, cov_hkle] = resolution_plot (wres, 'axis', 'none', plot_args{:});
else
    [cov_proj, cov_spec, cov_hkle] = resolution_plot (wres, 'axis', iax(3), plot_args{:});
end

% If newplot, then tidy up the plot
if newplot
    % Delete the meaningless colorslider and unwanted title
    colorslider('delete')
    delete(get(gca,'title'))
    
    % If spectrometer coordinates, then give meaningful axes titles
    Angstrom=char(197);     % Angstrom symbol
    title_ax = cell(4,1);
    title_ax{1} = ['Q || k_i  (',Angstrom,'^{-1})'];
    title_ax{2} = ['Q perp k_i (in-plane) (',Angstrom,'^{-1})'];
    title_ax{3} = ['Q vertically up  (',Angstrom,'^{-1})'];
    title_ax{4} = 'Energy transfer  (meV)';
    
    xlabel(title_ax(iax(1)))
    ylabel(title_ax(iax(2)))
    
    % Round up limits
    lx('round')
    ly('round')
end


% Return covariance matrix, if requested
% --------------------------------------
if nargout>=1
    varargout{1} = cov_proj;
end
if nargout>=2
    varargout{2} = cov_spec;
end
if nargout>=3
    varargout{3} = cov_hkle;
end

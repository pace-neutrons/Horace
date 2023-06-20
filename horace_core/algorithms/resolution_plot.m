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
%   >> resolution_plot (..., pax)       % Plot for a specified set of axes
%   >> resolution_plot (..., proj, pax) % Both the above
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
%   proj           Projection structure or object. Defines the coordinate frame in which
%                  to plot the resolution ellipsoid. Type help ortho_proj for details or <a href="matlab:help('ortho_proj');">Click here</a>.
%
%                   Default: if not given or empty: assume to be spectrometer axes
%                  i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   pax            Indicies of axes into the projection axes for purposes of plotting:
%                       [pax1, pax2]        plotting axes
%                       [pax1, pax2, pax3]  plotting axes and intersection axis
%                  where pax1 etc. are distinct axes indicies in the range 1 to 4.
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
%   cov_proj   Covariance matrix for wavevector-energy in projection axes (4x4 array)
%              [Note that if the default projection axes were used i.e.
%               input argument 'proj' was not given, then cov_proj and
%               cov_spec (below) are identical.]
%
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes (4x4 array)
%              i.e. x || ki, z vertically upwards, y perpendicular to z and x.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy (4x4 array)


% *** Really should be using dummy_sqw to create an sqw object, but as of 10 Nov 2018
%     it requires a par file, and will not accept a detpar structure. A fully
%     object oriented sqw object construction would deal with this, but for the
%     mean time, create an sqw object here.

% NOTE:
% if you have alatt and angdeg defined in sample, these are ignored
% and overided by input alall and angdeg

% Check parameters
% ----------------
% Energies and sample orientation
nfiles_in = 1;
[ok,mess,efix,emode,lat]=gen_sqw_check_params...
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

% - Projection and/or pax:
proj = [];
pax = [1,2,4];
if numel(par)==1
    if ~isnumeric(par{1})   % can only be a projection
        if ~isempty(par{1}), proj = par{1}; end
    else
        if ~isempty(par{1}), pax = par{1}; end
    end
elseif numel(par)==2
    if ~isempty(par{1}), proj = par{1}; end
    if ~isempty(par{2}), pax = par{2}; end
elseif numel(par)~=0
    error('HORACE:resolution_plot:invalid_argument',...
        'Check the number and type of optional arguments')
end

% create standard projection and assign lattice to it
if ~isempty(proj)
    if isa(proj,'ortho_proj')
        if ~proj.alatt_defined
            proj.alatt = alatt;
        end
        if ~proj.angdeg_defined
            proj.angdeg = angdeg;
        end
    elseif isstruct(proj)
        if ~isfield(proj,'alatt')
            proj.alatt = alatt;
        end
        if ~isfield(proj,'angdeg')
            proj.angdeg = angdeg;
        end
        proj = ortho_proj(proj);
    else
        error('HORACE:resolution_plot:invalid_argument',...
            'projection, if provided, must be an instance of ortho_proj class or structure convertable into it');
    end
end

if ~(isnumeric(pax) && (numel(pax)==2 || numel(pax)==3) &&...
        numel(unique(pax))==numel(pax) && all(pax>=1) && all(pax<=4))
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
% Make main_header
main_header.filename = '';
main_header.filepath = '';
main_header.title = '';
main_header.nfiles = nfiles_in;

wres.main_header = main_header;


% Make header

header.filename = '';
header.filepath = '';
header.efix =  efix;
header.emode = emode;
header.alatt = lat.alatt;
header.angdeg = lat.angdeg;
header.cu = lat.u;
header.cv = lat.v;
lat.angular_units = 'rad';
header.psi = lat.psi;
header.omega = lat.omega;
header.dpsi = lat.dpsi;
header.gl = lat.gl;
header.gs = lat.gs;
header.en = en;
header.uoffset = [0,0,0,0]';
header.u_to_rlu = zeros(4,4);
[~, header.u_to_rlu(1:3,1:3),spec_to_rlu] = lat.calc_proj_matrix();
%[~, header.u_to_rlu(1:3,1:3)] = lat.calc_proj_matrix();
header.u_to_rlu(4,4) = 1;
header.ulen = [1,1,1,1];
header.ulabel = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};
expdata = IX_experiment(header);

if ~(isa(instrument,'IX_inst') && isscalar(instrument))
    error('HORACE:resolution_plot:invalid_argument',...
        'Instrument must be a scalar instrument object')
end

if ~isa(sample,'IX_sample')
    error('HORACE:resolution_plot:invalid_argument',...
        'Sample must be a scalar IX_sample object')
else
    sample.alatt = lat.alatt;
    sample.angdeg = lat.angdeg;
end
exper = Experiment([],instrument,sample,expdata);

wres.experiment_info = exper;


% Check detector
if ~(isstruct(detpar) || (isnumerc(detpar) && all(size(detpar)==[6,1])))
    error('HORACE:resolution_plot:invalid_argument',...
        'Detector parameters must form a structure, or be 6x1 array with special meaning for elements')
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
if ~isempty(proj)
    proj.do_check_combo_arg = false;
    proj.alatt = lat.alatt;
    proj.angdeg = lat.angdeg;
    proj.u = lat.u;
    proj.v = lat.v;
    proj.do_check_combo_arg = true;
    proj = proj.check_combo_arg();
else
    proj = fudge_proj('alatt',lat.alatt,'angdeg',lat.angdeg); % deal with fuge_projection Ticket #840
    proj.spec_to_rlu = spec_to_rlu;
end
%
ax = ortho_axes('nbins_all_dims',[3,3,1,1],'img_range',range_add_border(zeros(2,4)));
ax.label = {'Q_\zeta'  'Q_\xi'  'Q_\eta'  'E'};

wres.data = DnDBase.dnd(ax,proj, ...
    [0,0,0; 0,NaN,0; 0,0,0],[0,0,0; 0,NaN,0; 0,0,0],[0,0,0; 0,1,0; 0,0,0]);
wres.pix = PixelDataBase.create([zeros(4,1);1;1;1;0;0]);  % wrong (Q,w) - but this is OK

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
if numel(pax)==2
    [cov_proj, cov_spec, cov_hkle] = resolution_plot (wres, 'axis', 'none', plot_args{:});
else
    [cov_proj, cov_spec, cov_hkle] = resolution_plot (wres, 'axis', pax(3), plot_args{:});
end

% If newplot, then tidy up the plot
if newplot
    % Delete the meaningless colour-slider and unwanted title
    colorslider('delete')
    delete(get(gca,'title'))

    % If spectrometer coordinates, then give meaningful axes titles
    Angstrom=char(197);     % Angstrom symbol
    title_ax = cell(4,1);
    title_ax{1} = ['Q || k_i  (',Angstrom,'^{-1})'];
    title_ax{2} = ['Q perp k_i (in-plane) (',Angstrom,'^{-1})'];
    title_ax{3} = ['Q vertically up  (',Angstrom,'^{-1})'];
    title_ax{4} = 'Energy transfer  (meV)';

    xlabel(title_ax(pax(1)))
    ylabel(title_ax(pax(2)))

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

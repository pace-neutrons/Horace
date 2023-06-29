function [rlu0,width,wcut,wpeak]=bragg_positions(w, rlu,...
    radial_cut_length, radial_bin_width, radial_thickness,...
    trans_cut_length, trans_bin_width, trans_thickness, varargin)
% Get actual Bragg peak positions, given initial estimates of their positions
%
%   >> [rlu0, widths, wcut, wpeak] = bragg_positions (w, rlu, ...
%               radial_cut_length, radial_bin_width, radial_thickness,...
%               trans_cut_length, trans_bin_width, trans_thickness, energy_window)
%
%   >> [rlu0, widths, wcut, wpeak] = bragg_positions (..., keyword1, keyword2)
%
% Input:
% ------
%   w                   Data source (sqw file name or sqw object)
%   rlu                 Set of Bragg peak indices in (n x 3) matrix:
%                           h1, k1, l1
%                           h2, k2, l2
%                           :   :   :
%                       These are the indices of the Bragg peaks whose
%                       actual positions will be found by this function
%                       e.g. [1,0,0; 0,1,0; 1,1,0]
%
%   radial_cut_length-| Length of cuts along Q of Bragg peak,, bin size along
%   radial_bin_width  | the cut, and the thickness in the two perpendicular
%   radial_thickness -| directions.
%                       - If option 'bin_absolute' [Default] they are in
%                         inverse Angstroms. Start with, say: 1.5, 0.05, 0.5
%                         respectively
%                       - If option 'bin_relative' these are given as fractions
%                         of |Q|. Good values might be 0.2, 0.002, 0.05 respectively
%                         Only useful if |Q| is similar for all Bragg peaks
%
%   trans_cut_length-|  Length of cuts transverse to Q, bin size along
%   trans_bin_width  |  the cut, and the thickness in the two perpendicular
%   trans_thickness -|  directions.
%                       - If option 'bin_absolute' [Default] they are in
%                         inverse Angstroms. Start with, say: 1.5, 0.05, 0.5
%                         respectively
%                       - If option 'bin_relative' these are given in degrees
%                         Good values might be 15, 0.5, 5 respectively
%                         Only useful if |Q| is similar for all Bragg peaks
%
%   energy_window       Energy integration window around elastic line (meV)
%                       Choose according to the instrument resolution. A good
%                       value is 2 x full-width half-height.
%                       Note that this is the full energy window
%                           e.g. for -1meV to +1 meV, set  energy_window=2
%
% Keyword options:
% ----------------
% Binning:
%   'bin_absolute'  Radial and transverse cut length, bin size, and thickness
%                  are in inverse Angstroms [Default]
%   'bin_relative'  Cut length, bin size and thickness are fractions of |Q|
%                  (radial cuts) and degrees (transverse cuts)
%
% Fitting:
%   'outer'         Determine peak position from centre of peak half-height; find
%                  peak width moving inwards from limits of data - useful if
%                  there is known to be a single peak in the data as it is
%                  more robust to too finely binned data.  [Default]
%   'inner'         Determine peak position from centre of peak half height; find
%                  peak width moving outwards from peak maximum
%   'gaussian'      Fit Gaussian on a linear background.
%
%
% Output:
% -------
%   rlu0            The actual peak positions as (n x 3) matrix of h,k,l as
%                  indexed with the current lattice parameters
%   widths          Array (size (n x 3)) containing the FWHH in Ang^-1 of the
%                  peaks along each of the three projection axes
%   wcut            Array of cuts, size (n x 3),  along three orthogonal
%                  directions through each Bragg point from which the peak
%                  positions were determined. Pass to bragg_positions_view
%                  together with wpeak (below) to view the output. [Note: the
%                  cuts are IX_dataset_1d objects and can be plotted using
%                  the plot functions for these methods.]
%   wpeak           Array of spectra, size (n x 3), that summarise the peak
%                  analysis. Pass to bragg_positions_view together with wcut
%                  (above) to view the output. [Note: for asfficionados: the
%                  cuts are IX_dataset_1d objects and can also be plotted using
%                  the plot functions for these objects.]
%
%
% See also: bragg_positions_view
%
% NOTE: The default cut parameters were changed to 'bin_absolute' from
%       'bin_relative' in February 2015. If you have funny behaviour, please
%       check that you are using the option you expect.


% Original author: T.G.Perring
%


% Check input arguments
if istext(w)    % assume a file name
    file_type_ok=is_sqw_type_file(w);
    if ~isscalar(file_type_ok) || ~file_type_ok
        error('HORACE:lattice_functions:invalid_argument', ...
            'File %s must be a sqw/dnd type',w);
    end
    img=read_dnd(w);    % get header information as extracted from the 'data' field
elseif isa(w,'sqw') && has_pixels(w(1))
    if numel(w)~=1
        error('Data must be a single sqw object, not an array (or empty)')
    end
    img=w.data;
else
    error('Object must be sqw type')
end

[opt,eint,absolute_binning,gau] = check_and_parse_inputs( rlu,...
    radial_cut_length, radial_bin_width, radial_thickness,...
    trans_cut_length, trans_bin_width, trans_thickness, varargin{:});


% Fit Peaks
% ---------
% Initialise output arguments
szrlu  = size(rlu);
rlu0   = zeros(szrlu );
width  = zeros(szrlu);
npeaks = szrlu(1);
wcut=repmat(IX_dataset_1d,npeaks,3);
wpeak=repmat(IX_dataset_1d,npeaks,3);

% Get matrix to convert rlu to projection axes
proj = img.proj;
u1_rlu = proj.u;
u2_rlu = proj.v;
% Get the matrix to convert rlu to crystal Cartesian coordinates
B = bmatrix (img.alatt, img.angdeg);

peak_problem=false(size(rlu));

for i=1:size(rlu,1)
    % Extract Q point through which to get three orthogonal cuts
    Qrlu = rlu(i,:);
    modQ=norm(B*Qrlu(:));   % length of Q vector in Ang^-1

    % Create proj for taking three orthogonal cuts
    %   - proj.u along Q, to get maximum resolution in d-spacing
    %   - proj.v defined by whichever of u1, u2 projection axes is closer
    %     to perpendicular to Q (to avoid collinearity)
    offset=Qrlu;  % centre of cut is the nominal Bragg peak position
    u=Qrlu;
    c1 = cosangle(B,u1_rlu,Qrlu);
    c2 = cosangle(B,u2_rlu,Qrlu);
    if abs(c1)<=abs(c2)
        v=u1_rlu;
    else
        v=u2_rlu;
    end
    type='aaa';        % force unit length of projection axes to be 1 Ang^-1
    proj = ortho_proj('u',u,'v',v,'type',type,'offset',offset, ...
        'alatt',img.alatt,'angdeg',img.angdeg);

    % if old file has been already aligned, ignore this alignment
    proj.ignore_legacy_alignment = true;

    % radial_cut_length, radial_bin_width, radial_thickness,...
    % trans_cut_length, trans_bin_width, trans_thickness, energy_window)
    if absolute_binning
        len_r=radial_cut_length;
        bin_r=radial_bin_width;
        thick_r=radial_thickness;
        len_t=trans_cut_length;
        bin_t=trans_bin_width;
        thick_t=trans_thickness;
    else
        len_r=radial_cut_length*modQ;
        bin_r=radial_bin_width*modQ;
        thick_r=radial_thickness*modQ;
        len_t=(pi/180)*trans_cut_length*modQ;
        bin_t=(pi/180)*trans_bin_width*modQ;
        thick_t=(pi/180)*trans_thickness*modQ;
    end

    % Make three orthogonal cuts through nominal Bragg peak positions
    disp('--------------------------------------------------------------------------------')
    disp(['Peak ',num2str(i),':  [',num2str(Qrlu),']','    scan: 1 (radial scan)'])
    w1a_1=cut_sqw(w, proj, [-len_r/2,bin_r,+len_r/2] ,[-thick_t/2,+thick_t/2]   ,[-thick_t/2,+thick_t/2],   eint, '-nopix');

    disp(['Peak ',num2str(i),':  [',num2str(Qrlu),']','    scan: 2 (transverse scan)'])
    w1a_2=cut_sqw(w, proj, [-thick_r/2,+thick_r/2]   ,[-len_t/2,bin_t,+len_t/2] ,[-thick_t/2,+thick_t/2],   eint, '-nopix');

    disp(['Peak ',num2str(i),':  [',num2str(Qrlu),']','    scan: 3 (transverse scan)'])
    w1a_3=cut_sqw(w, proj, [-thick_r/2,+thick_r/2]   ,[-thick_t/2,+thick_t/2]   ,[-len_t/2,bin_t,+len_t/2], eint, '-nopix');

    % Get peak positions
    upos0=zeros(3,1);
    if ~gau
        [upos0(1),~,width(i,1),~,~,~,w1a_1_pk]=peak_cwhh(IX_dataset_1d(w1a_1),opt);
        [upos0(2),~,width(i,2),~,~,~,w1a_2_pk]=peak_cwhh(IX_dataset_1d(w1a_2),opt);
        [upos0(3),~,width(i,3),~,~,~,w1a_3_pk]=peak_cwhh(IX_dataset_1d(w1a_3),opt);
    else
        [upos0(1),width(i,1),w1a_1_pk]=peak_gaussian(IX_dataset_1d(w1a_1));
        [upos0(2),width(i,2),w1a_2_pk]=peak_gaussian(IX_dataset_1d(w1a_2));
        [upos0(3),width(i,3),w1a_3_pk]=peak_gaussian(IX_dataset_1d(w1a_3));
    end

    % Fill output spectra with cuts and peak analysis
    wcut(i,1)=IX_dataset_1d(w1a_1);
    wcut(i,2)=IX_dataset_1d(w1a_2);
    wcut(i,3)=IX_dataset_1d(w1a_3);
    wpeak(i,1)=w1a_1_pk;
    wpeak(i,2)=w1a_2_pk;
    wpeak(i,3)=w1a_3_pk;

    % Get matrix to convert upos0 to rlu
    proj = w1a_1.proj;

    % Convert peak position into r.l.u.
    if all(isfinite(upos0))
        rlu0(i,:)= proj.transform_img_to_hkl(upos0(:))';
    else
        peak_problem(i,:)=~isfinite(upos0);
        rlu0(i,:)=NaN;
    end
end

disp('--------------------------------------------------------------------------------')
if any(peak_problem(:))
    disp('Problems determining peak position for:')
    for i=1:size(rlu,1)
        if any(peak_problem(i,:))
            disp(['Peak ',num2str(i),':  [',num2str(Qrlu),']','    scan(s): ',num2str(find(peak_problem(i,:)))])
        end
    end
    disp(' ')
    disp(['Total number of peaks = ',num2str(size(rlu,1))])
    disp('--------------------------------------------------------------------------------')
end


%-----------------------------------------------------------------------------------------------------------
function [xcent,width,wfit]=peak_gaussian(w)
% Fit Gaussian to Bragg peak, trying to be robust

% Common case is too many bins if azimuthal scan from a single Laue diffraction shot. Assume only a single peak in the cut
[xcent,~,width,~,~,ypeak]=peak_cwhh(w,'outer');
if ~isfinite(xcent) % unable to find a peak
    xcent=NaN;
    width=NaN;
    wfit=w; wfit.signal=NaN(size(wfit.signal)); wfit.error=zeros(size(wfit.error));
    return
end

% Now fit Gaussian
[~,fitdata]=fit(w,@gauss_bkgd,[ypeak,xcent,width/2.3548,0,0]);
if all(isfinite(fitdata.sig)) && all(fitdata.sig>0)
    xcent=fitdata.p(2);
    width=2.3548*fitdata.p(3);
    wfit=func_eval(linspace(w,1000),@gauss_bkgd,fitdata.p);
else
    xcent=NaN;
    width=NaN;
    wfit=w; wfit.signal=NaN(size(wfit.signal)); wfit.error=zeros(size(wfit.error));
end


%--------------------------------------------------------------------------
function c = cosangle (B, u, v)
% Cosine of the angle between two reciprocal lattice vectors
uxtal = B*u(:);
vxtal = B*v(:);
c = dot(uxtal,vxtal)/(norm(uxtal)*norm(vxtal));

%--------------------------------------------------------------------------
function [opt,eint,absolute_binning,gau] = check_and_parse_inputs(rlu,...
    radial_cut_length, radial_bin_width, radial_thickness,...
    trans_cut_length, trans_bin_width, trans_thickness, varargin)

npeaks=size(rlu,1);
if size(rlu,2)~=3 || npeaks==0
    error('HORACE:lattice_functions:invalid_argument',...
        'The input Bragg point must form an (n x 3) array, one row per Bragg peak')
end

% Get cut binning and integration for each projection axes
is_positive_scalar = @(x) isscalar(x) && isnumeric(x) && x > 0;
if ~is_positive_scalar(radial_cut_length)
    error('HORACE:lattice_functions:invalid_argument',...
        'Radial cut length must be a positive number greater than zero. It is: %s', ...
        disp2str(radial_cut_length))
end
if ~is_positive_scalar(radial_bin_width)
    error('HORACE:lattice_functions:invalid_argument',...
        'Radial bin width must be a positive number greater than zero. It is: %s', ...
        disp2str(radial_bin_width))
end
if ~is_positive_scalar(radial_thickness)
    error('HORACE:lattice_functions:invalid_argument',...
        'Radial thickness must be a positive number greater than zero. It is: %s', ...
        disp2str(radial_thickness))
end
if ~is_positive_scalar(trans_cut_length)
    error('HORACE:lattice_functions:invalid_argument',...
        'Transverse cut length is a positive number greater than zero. It is: %s', ...
        disp2str(trans_cut_length))
end
if ~is_positive_scalar(trans_bin_width)
    error('HORACE:lattice_functions:invalid_argument',...
        'Transverse bin width bust be a positive number greater than zero. It is: %s', ...
        disp2str(trans_bin_width))
end
if ~is_positive_scalar(trans_thickness)
    error('HORACE:lattice_functions:invalid_argument',...
        'Transverse thickness must be a positive number greater than zero. It is: %s', ...
        disp2str(trans_thickness))
end

% Parse parameters:
arglist = struct('bin_relative',0,'bin_absolute',0,'inner',0,'outer',0,'gaussian',0);
flags = fieldnames(arglist);
[args,opt] = parse_arguments(varargin,arglist,flags);
if numel(args)>1
    error('HORACE:lattice_functions:invalid_argument',...
        'Check number and type of optional parameters')
end

% Get energy window
if numel(args)==1
    energy_window=args{1};
    if ~isscalar(energy_window) || ~isnumeric(energy_window) || energy_window<=0
        error('HORACE:lattice_functions:invalid_argument',...
            'Energy window must be a positive number greater than zero. It is: %s', ...
            disp2str(energy_window))
    end
else
    energy_window=Inf;
    disp(' ')
    disp('*** Using default energy window as -Inf to Inf ***')
    disp(' ')
end
eint=[-energy_window/2,energy_window/2];

% Get binning option
optsum=opt.bin_relative+opt.bin_absolute;
if optsum==0
    absolute_binning=true;
elseif optsum==1
    absolute_binning=logical(opt.bin_absolute);
else
    error('HORACE:lattice_functions:invalid_argument',...
        'Incorrect binning options: %s', ...
        disp2str(optsum))
end

% Get peak option
optsum=(opt.inner+opt.outer+opt.gaussian);
if optsum==0
    opt.outer=true;
elseif optsum~=1
    error('HORACE:lattice_functions:invalid_argument', ...
        'Incorrect peak options: %s', ...
        disp2str(optsum))
end

if opt.inner
    opt='inner';
    gau=false;
elseif opt.outer
    opt='outer';
    gau=false;
elseif opt.gaussian
    gau=true;
else
    error('HORACE:lattice_functions:runtime_error', ...
        'Logic problem - see T.G.Perring')
end


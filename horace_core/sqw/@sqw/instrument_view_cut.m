function dnd2d = instrument_view_cut(win,varargin)
%INSTRUMENT_VIEW_CUT cuts input sqw object using special projection which
% provides 2-dimensional views of input sqw object, used for diagnostics of
% validity of this sqw object.
%
% The cut is performed over the whole sqw dataset so usually is slow.
%
% Two resulting images may be produces using this algorithm:
% 1) First (normal) view is Theta-dE vuew where Theta is the
%    angle between beam direction and a detector position in spherical
%    coordinate system with centre at sample and dE is the energy transfer.
%    This image presents background scattering not related with the sample
% 2) Second, validation view is kf-dE view, where x-axis contains energy
%    transfer values and y-axis -- module of energy transfer values. These
%    values are connected by the relation
%    kf = sqrt(dE/dEToKf_transformation_constant),
%    so the correct image should be a line reflecting this relation.
%    If plot contains full picture in kf-dE coordinates, the relation
%    between pixel indices and information, contained in the Experiment
%    class is violated. Such sqw object and cuts from such sqw object are
%    broken and can not be used for Tobyfitting.
%
% The indication that second type plot may be necessary is the large fraction
% of the pixels have been discarded while making the first type of plot in
% full image range.
%
% Inputs:
% win        -- initialized instance of the source sqw object.
% theta_bin  -- binning arguments as for cut to use to bin data in theta-direction.
%               normally this shoule start at 0, step close to angular resolution
%               and ends at instrument's angular coverage range.
% en_bin     -- binning range to use along energy transfer direction
%
% Optional:
% '-check_correspondence'
%            -- if provided, indicates that second type of the plot,
%               reresenting kf-dE dependence is requested.
%
% Returns:
% dnd2d     -- d2d object, containing 2-dimensional instrument view of
%              input sqw object

[ok,mess,kf_de_plot,argi] = parse_char_options(varargin,'-check_correspondence');
if ~ok
    error('HORACE:algorithms:invalid_argument',mess);
end

n_bins_arguments = numel(argi);
% set up default theta binning if not provided
if n_bins_arguments <2 || (n_bins_arguments >=2 && isempty(argi{1}))
    theta_bin = [0,1,140]; % do we have inelastic instrument with coverage larger then 140%?
else
    theta_bin = argi{1};
    if isscalar(theta_bin)
        theta_bin = [0,theta_bin,140];
    end
end

img = win.data;
en_range = img.img_range(:,4);

% set up default energy binning if not provided
if n_bins_arguments <3 || (n_bins_arguments>=3 && isempty(argi{2}))
    n_en_bins= img.axes.nbins_all_dims(4);
    if n_en_bins == 1
        n_en_bins = 100;
        step = (en_range(2)-en_range(1))/(n_en_bins-1);
        en_bin = [en_range(1)+0.5*step,step,en_range(2)-0.5*step];
    else
        bin_range = img.axes.get_cut_range('-full');
        en_bin  = bin_range{4};
    end
else
    en_bin = argi{2};
    if isscalar(en_bin)
        en_bin = [en_range(1)+0.5*en_bin,en_bin,en_range(2)-0.5*en_bin];
    end
end
% identify kf range
efix = win.experiment_info.get_efix();
efix = max(efix);
if en_range(1)<0
    efix = (efix - en_range(1))*(1+4*eps('single'));
else
    efix = efix*(1+4*eps('single'));
end
kf_max = sqrt(efix/neutron_constants('c_k_to_emev'));

sproj = kf_sphere_proj();
sproj.disable_pix_preselection = true;
if kf_de_plot
    step = kf_max/100;
    dnd2d = cut_sqw(win,sproj,[0,step,1.1*kf_max],[theta_bin(1),theta_bin(end)],[-180,180],en_bin,'-nopix');
else
    dnd2d = cut_sqw(win,sproj,[0,1.1*kf_max],theta_bin,[-180,180],en_bin,'-nopix');
end

function dnd2d = instrument_view_cut(win,theta_bin,en_bin)
%INSTRUMENT_VIEW_CUT cuts input sqw object using special projection which
% provides 2-dimensional Theta-dE view of input sqw object where Theta is
% the angle between beam direction and a detector position in the spherical
% coordinate system with centre at sample and dE is the energy transfer
% binning
%
% Inputs:
% win        -- instance the sqw object.
% theta_bin  -- binning arguments as for cut to use to bin data in theta-direction.
%               normally this shoule start at 0, step close to angular resolution
%               and ends at instrument's angular coverage range.
% en_bin     -- binning range to use along energy transfer direction
%
% Returns:
% win       -- d2d object, containing 2-dimensional instrument view of
%              input sqw object

% set up default theta binning if not provided
if nargin<2 || (nargin>=2 && isempty(theta_bin))
    theta_bin = [0,1,140]; % do we have inelastic instrument with coverage larger then 140%?
end

img = win.data;
en_range = img.img_range(:,4);

% set up default energy binning if not provided
if nargin <3 || (nargin>=3 && isempty(en_bin))
    n_en_bins= img.axes.nbins_all_dims(4);
    if n_en_bins == 1
        n_en_bins = 100;
        step = (en_range(2)-en_range(1))/(n_en_bins-1);
        en_bin = [en_range(1)-0.5*step,step,en_range(2)+0.5*step];
    else
        bin_range = img.axes.get_cut_range('-full');
        en_bin  = bin_range{4};
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
dnd2d = cut_sqw(win,sproj,[0,kf_max],theta_bin,[-180,180],en_bin,'-nopix');

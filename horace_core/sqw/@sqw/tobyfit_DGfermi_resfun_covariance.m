function [cov_proj, cov_spec, cov_hkle] = tobyfit_DGfermi_resfun_covariance(win, indx)
% Return 4D momentum-energy covariance matrix for the resolution function
%
% For all pixels:
%   >> [cov_spec, cov_proj, cov_hkle] = tobyfit_DGfermi_resfun_covariance (w)
%
% For selected pixels:
%   >> [cov_spec, cov_proj, cov_hkle] = tobyfit_DGfermi_resfun_covariance (w, indx)
%
%
% Input:
% ------
%   win         Array of sqw objects, or cell array of scalar sqw objects
%
%  [Optional]
%   indx        Pixel indicies:
%               Single sqw object:
%                 - ipix            Array of pixels indicies
%            *OR* - {irun,idet,ien} Arrays of run, detector and energy bin index
%                                   Dimension expansion is performed on scalar
%                                  quantities i.e. each must be a scalar or array
%                                  with arrays having the same length
%               Multiple sqw object:
%                 - As above, assumed to apply to all sqw objects,
%            *OR* - Cell array of the above, one cell array per sqw object
%                  e.g. if two sqw objects:
%                       {ipix1, ipix2}
%                       {{irun1,idet1,ien1}, {irun2,idet2,ien2}}
%
% Output:
% -------
% [The format of the following three arguments depends on the format of win:
%   - win is a scalar sqw object:       Array size [4,4,npix]
%   - win is an array of sqw objects:   Cell array of arrays size [4,4,npix(i)]
%   - win is a cell array:               "     "    "    "     "       "         ]
%
%   cov_proj    Covariance matrix for wavevector-energy in projection axes
%
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes
%              i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy


% Get lookup arrays
% -----------------
if exist('indx','var')
    all_pixels = false;
    [ok,mess,lookup,npix_arr] = tobyfit_DGfermi_resconv_init (win, indx);
else
    all_pixels = true;
    [ok,mess,lookup,npix_arr] = tobyfit_DGfermi_resconv_init (win);
end
if ~ok, error(mess), end


% Get variances
% -------------
% This block of code effectively does the equivalent of tobyfit_DGfermi_resconv

cov_proj = cell(size(win));
cov_spec = cell(size(win));
cov_hkle = cell(size(win));


% Create pointers to parts of lookup structure
% --------------------------------------------
moderator_table = lookup.moderator_table;
aperture_table = lookup.aperture_table;
fermi_table = lookup.fermi_table;
sample_table = lookup.sample_table;
detector_table = lookup.detector_table;


% Get covariance matricies
% ------------------------
for iw = 1:numel(win)
    if iscell(win), wtmp = win{iw}; else, wtmp = win(iw); end
    if all_pixels
        [~,~,irun,idet] = parse_pixel_indicies (wtmp);
    else
        [~,~,irun,idet] = parse_pixel_indicies (wtmp,indx,iw);
    end
    npix = npix_arr(iw);
    
    % Simple pointers to items in lookup
    kf = lookup.kf{iw};
    dt = lookup.dt{iw};
    
    % Compute variances
    var_mod = (10^-6 * moderator_table.func_eval(iw, irun, @pulse_width)).^2;
    cov_aperture = aperture_table.func_eval(iw, irun, @covariance);
    cov_sample = sample_table.func_eval(iw, @covariance);
    var_chop = (10^-6 * fermi_table.func_eval(iw, irun, @pulse_width)).^2;
    cov_detector = detector_table.func_eval(iw, @covariance, idet, kf);
    var_tbin = dt.^2 / 12;
    
    % Fill covariance matrix
    cov_x = zeros(11,11,npix);
    cov_x(1,1,:) = var_mod;
    cov_x(2:3,2:3,:) = cov_aperture;
    cov_x(4,4,:) = var_chop;
    cov_x(5:7,5:7,:) = repmat(cov_sample,[1,1,npix]);
    cov_x(8:10,8:10,:) = cov_detector;
    cov_x(11,11,:) = var_tbin;
    
    % Compute wavevector-energy covariance matrix in different dimensions
    dq_mat = lookup.dq_mat{iw};
    spec_to_rlu = lookup.spec_to_rlu{iw};
    
    cov_hkle{iw} = transform_matrix (cov_x, dq_mat);
    cov_proj{iw} = transform_matrix (cov_hkle{iw}, inv(wtmp.data.u_to_rlu));
    
    rlu_to_spec = invert_matrix (spec_to_rlu);
    rlu_to_spec4(1:3,1:3,:) = rlu_to_spec(:,:,irun);
    rlu_to_spec4(4,4,:) = 1;
    cov_spec{iw} = transform_matrix (cov_hkle{iw}, rlu_to_spec4);
end

if ~iscell(win) && isscalar(win)
    cov_hkle = cov_hkle{1};
    cov_proj = cov_proj{1};
    cov_spec = cov_spec{1};
end

%test_covariance(cov_x,dq_mat)


%=============================================================================
function Cout = transform_matrix (C,B)
% Compute the matrix product Cout = B * C * B' for nD matricies
% B can be a 2D matrix and dimension expansion is performed

szC = size(C);
szB = size(B);
if numel(szC)==2 && numel(szB)==2
    % Just do straighforward matlab matric multiplication
    Cout = B * C * B';
else
    if numel(szB)==2
        tmp = mtimesx_horace (C, B');
    else
        tmp = mtimesx_horace (C, permute(B,[2,1,3:numel(szB)]));
    end
    Cout = mtimesx_horace (B, tmp);
end


%=============================================================================
function Cinv = invert_matrix (C)
% Compute the inverse of an array of square matricies, taking additional
% dimensions as the matrix array dimensions

szC = size(C);
if numel(szC)==2
    % Just do straighforward matlab inversion
    Cinv = inv(C);
else
    Cinv = zeros(size(C));
    for i=1:prod(szC(3:end))
        Cinv(:,:,i) = inv(C(:,:,i));
    end
end


%===================================================
function test_covariance (cov, dq_mat)
% Contributions to energy width
% Ignores correlations

contr = zeros(11,1);
for i=1:11
    contr(i) = log(256)*cov(i,i)*dq_mat(4,i)^2;
end
total = sum(contr);
disp('-------------------------------')
disp('FWHH (assumeing Gaussian)')
disp(sqrt(total))
disp(sqrt(contr))
disp('-------------------------------')

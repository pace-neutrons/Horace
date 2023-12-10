function [cov_proj, cov_spec, cov_hkle] = tobyfit_DGdisk_resfun_covariance(win, ipix)
% Return 4D momentum-energy covariance matrix for the resolution function
%
% For all pixels:
%   >> [cov_spec, cov_proj, cov_hkle] = tobyfit_DGdisk_resfun_covariance (w)
%
% For selected pixels:
%   >> [cov_spec, cov_proj, cov_hkle] = tobyfit_DGdisk_resfun_covariance (w, ipix)
%
%
% Input:
% ------
%   win         Array of sqw objects
%
% [Optional]
%   ipix        Pixel indices for which the output is to be extracted from the
%               sqw object(s)
%
%               - Array of pixel indices. If there are multiple sqw objects,
%                 it is then applied to every sqw object
%
%               - Cell array of pixel indices arrays
%                   - only one array: applied to every sqw object, or
%                   - several pixel indices arrays: one per sqw object
%
% Output:
% -------
% [The format of the following three arguments depends on the format of win:
%   - win is a scalar sqw object:       Array size [4,4,npix]
%   - win is an array of sqw objects:   Cell array of arrays size [4,4,npix(i)]
%
%   cov_proj    Covariance matrix for wavevector-energy in projection axes
%
%   cov_spec    Covariance matrix for wavevector-energy in spectrometer axes
%              i.e. x || ki, z vertical upwards, y perpendicular to z and y.
%
%   cov_hkle    Covariance matrix for wavevector-energy in h-k-l-energy


% Get lookup arrays
% -----------------
if exist('ipix','var')
    all_pixels = false;
    [ok,mess,lookup,npix_arr] = tobyfit_DGdisk_resconv_init (win, ipix);
else
    all_pixels = true;
    [ok,mess,lookup,npix_arr] = tobyfit_DGdisk_resconv_init (win);
end
if ~ok, error(mess), end


% Create pointers to parts of lookup structure
% --------------------------------------------
mod_shape_mono_table = lookup.mod_shape_mono_table;
horiz_div_table = lookup.horiz_div_table;
vert_div_table = lookup.vert_div_table;
sample_table = lookup.sample_table;
detector_table = lookup.detector_table;

% Constants
k_to_v = lookup.k_to_v;
k_to_e = lookup.k_to_e;


% Get covariance matricies
% ------------------------
cov_proj = cell(size(win));
cov_spec = cell(size(win));
cov_hkle = cell(size(win));

for iw = 1:numel(win)
    % Get the indices to the runs in the experiment information block, the 
    % detector indicies and the energy bin indices
    if all_pixels
        % For all pixels in the sqw object
        [irun,idet] = parse_pixel_indices (win(iw));
    else
        % For the selected pixels only
        if iscell(ipix) && numel(ipix)>1    
            % Different ipix arrays for each sqw object
            [irun, idet] = parse_pixel_indices(win(iw), ipix{iw});
        else
            % Single ipix array for all sqw objects
            [irun, idet] = parse_pixel_indices(win(iw), ipix);
        end
    end
    npix = npix_arr(iw);

    % Simple pointers to items in lookup
    xa = lookup.xa{iw};
    x1 = lookup.x1{iw};
    ki = lookup.ki{iw};
    kf = lookup.kf{iw};
    s_mat = lookup.s_mat{iw};
    spec_to_rlu = lookup.spec_to_rlu{iw};
    dt = lookup.dt{iw};

    [x2, ~, d_mat, f_mat] = detector_table.func_eval_ind (iw, irun, idet, @detector_info);
    dq_mat = dq_matrix_DGdisk (ki(irun), kf,...
        xa(irun), x1(irun), x2,...
        s_mat(:,:,irun), f_mat, d_mat,...
        spec_to_rlu(:,:,irun), k_to_v, k_to_e);
    
    % Compute variances
    cov_sh_ch = 1e-12 * mod_shape_mono_table.func_eval_ind(iw, irun, @covariance);
    var_horiz_div = (horiz_div_table.func_eval_ind(iw, irun, @profile_width)).^2;
    var_vert_div = (vert_div_table.func_eval_ind(iw, irun, @profile_width)).^2;
    cov_sample = sample_table.func_eval_ind(iw, irun, @covariance);
    cov_detector = detector_table.func_eval_ind (iw, irun, idet, 'split', @covariance, kf);
    var_tbin = dt.^2 / 12;

    % Fill covariance matrix
    cov_x = zeros(11,11,npix);
    cov_x([1,4],[1,4],:) = cov_sh_ch;
    cov_x(2,2,:) = var_horiz_div;
    cov_x(3,3,:) = var_vert_div;
    cov_x(5:7,5:7,:) = cov_sample;
    cov_x(8:10,8:10,:) = cov_detector;
    cov_x(11,11,:) = var_tbin;

    % Compute wavevector-energy covariance matrix in different dimensions
    %TODO: Re #1040 this code is not consistent with generic projections
    if ~isa(win(iw).data.proj,'line_proj')
        error('HORACE:sqw:not_implemented', ...
            'resolution cannot currently be calculated for any projection except linear projection')
    end
    
    cov_hkle{iw} = transform_matrix (cov_x, dq_mat);
    cov_proj{iw} = transform_matrix (cov_hkle{iw}, inv(win(iw).data.u_to_rlu));
    rlu_to_spec = invert_matrix (spec_to_rlu);
    rlu_to_spec4(1:3,1:3,:) = rlu_to_spec(:,:,irun);
    rlu_to_spec4(4,4,:) = 1;
    cov_spec{iw} = transform_matrix (cov_hkle{iw}, rlu_to_spec4);
end

if isscalar(win)
    % Numeric array output if just one sqw object
    cov_hkle = cov_hkle{1};
    cov_proj = cov_proj{1};
    cov_spec = cov_spec{1};
end

% test_covariance(cov_spec,cov_x,dq_mat)


%=============================================================================
function Cout = transform_matrix (C,B)
% Compute the matrix product Cout = B * C * B' for nD matrices
% B can be a 2D matrix and dimension expansion is performed

szC = size(C);
szB = size(B);
if numel(szC)==2 && numel(szB)==2
    % Just do straightforward Matlab matrix multiplication
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
function test_covariance (cov_spec, cov, dq_mat)
% Contributions to energy width
% Ignores correlations

contr = zeros(11,1);
for i=1:11
    contr(i) = log(256)*cov(i,i)*dq_mat(4,i)^2;
end
total = sum(contr);
disp('-------------------------------')
disp(sqrt(log(256)*cov_spec(4,4)))
disp('FWHH (assumeing Gaussian)')
disp(sqrt(total))
disp(sqrt(contr))
disp('-------------------------------')

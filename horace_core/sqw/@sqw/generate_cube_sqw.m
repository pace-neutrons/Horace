function out = generate_cube_sqw(shape,varargin)
% Generate an instance of SQW data with given shape.
%
% Usage:
%>> test_sqw = sqw.generate_cube_sqw(shape)
% or:
%>> test_sqw = sqw.generate_cube_sqw(axes_block_instance)
% Optional:
%>> test_sqw = sqw.generate_cube_sqw(___,proj_instance)
%>> test_sqw = sqw.generate_cube_sqw(___,func_handle)
%
% Where:
% shape -- the number, defining the size of the cube of the generated
%    sqw object.
%    For even counts sizes are:
%       [-X/2 + 0.5 : 1 : X/2 - 0.5] i.e. for 2 -> [-0.5 0.5]
%    For odd counts these are:
%      [-floor(X/2):floor(X/2)] i.e. for 3 -> [-1 0 1]
% axes_block_instance
% --    initialized instance of AxesBlockBase which defines the shape of
%       the resulting sqw object
% proj_instance
% --   intialized instance of aProjectionBase class, which defines the
%      image transformation, used by sqw object.
% func_hanlde
% --  the handle to the function which calculates signal on sqw object.
%     The function must obey the requests for the function used by sqw_eval
%     and accept no external parameters. (all parameters are inside the
%     function)
%
% NOTE:
% numeric shape used for TESTING CUT/SYMMETRISE
% The data will be invalid in most circumstances and may
% result in errors or invalid results if used outside of
% cut/symmetrise
%

%
out = sqw();

alatt = [2*pi 2*pi 2*pi];
angdeg = [90 90 90];
if isscalar(shape) && isnumeric(shape)
    if mod(shape, 2) == 0
        minloc = -shape/2;
        maxloc = shape/2;
    else
        minloc = -(shape-1)/2;
        maxloc = (shape-1)/2;
    end
    img_range = [ones(1,4)*minloc;ones(1,4)*maxloc];
    sqw_axes = ortho_axes('img_range',img_range,'nbins_all_dims',ones(1,4)*shape);
elseif isa(shape,'AxesBlockBase')
    sqw_axes = shape;
    img_range = sqw_axes.img_range;
else
    error('HORACE:sqw:not_implemented', ...
        'Currently unsupported input type: %s',class(shape))
end
coord = sqw_axes.get_bin_nodes('-bin_centre');
npix = size(coord,2);

[proj,alatt,angdeg,argi] = get_projection(alatt,angdeg,varargin{:});

coord = proj.transform_img_to_pix(coord);
pix_data = [...
    coord;...
    ones(1,npix);...        % Set run_idxs to 1 (needs to be ones to avoid conflicts with expdata)
    repmat(1:npix, 4, 1)];  % set detector_idx, energy_idx, to 1:npix
% (fake, physically invalid data, detectors are missing) and signal,
% variance to 1:npix (model data)
pix = PixelDataMemory(pix_data);
out.pix = pix;

samp = IX_sample(alatt,angdeg);
expdata = struct( ...
    "filename", 'fake', ...
    "filepath", '/fake', ...
    "efix", 1, ...
    "emode", 1, ...
    "cu", [1,0,0], ...
    "cv", [0,1,0], ...
    "psi", 1, ...
    "omega", 1, ...
    "dpsi", 1, ...
    "gl", 1, ...
    "gs", 1, ...
    "en", 10, ...
    "uoffset", [0 0 0], ...
    "u_to_rlu", inv(bmatrix(alatt,angdeg)), ...
    "ulen", 1.0, ...
    "ulabel", 'rrr', ...
    "run_id", 1);
out.detpar = struct( ...
    'filename', 'fake', ...
    'filepath', '/fake', ...
    'group', [], ...
    'x2', [], ...
    'phi', [], ...
    'azim', [], ...
    'width', [], ...
    'height', []);



out.experiment_info.samples = out.experiment_info.samples.add(samp);
out.experiment_info.instruments = out.experiment_info.instruments.add(IX_null_inst());
out.experiment_info.detector_arrays = IX_detector_array();
out.experiment_info.expdata = IX_experiment(expdata);


ax0  = ortho_axes('img_range',img_range,'nbins_all_dims',ones(1,4));
out.data = DnDBase.dnd(ax0,proj,npix,npix,npix);

% Shape data to the requested form
cut_range = sqw_axes.get_cut_range('-full_range');
out = cut(out, proj, cut_range{:});

% evaluate signal on the sqw object if this is requested
if numel(argi) > 0  && isa(argi{1},'function_handle')
    out = sqw_eval(out,argi{1},[]);
    out_err = sqw_eval(out,@(h,k,l,e,p)ones(numel(h),1),[]);
    out.pix.variance = out_err.pix.signal;
    out.data.e = out_err.data.e;
end


function [proj,alatt,angdeg,argi] = get_projection(alatt,angdeg,varargin)
% define projection from input parameters. If it is missing within the
% input parameters, use default projection.

if nargin> 2 && isa(varargin{1},'aProjectionBase')
    proj = varargin{1};
    argi = varargin(2:end);
    if proj.alatt_defined
        alatt = proj.alatt;
    else
        proj.alatt = alatt;
    end
    if proj.angdeg_defined
        angdeg = proj.angdeg;
    else
        proj.angdeg = angdeg;
    end
else
    argi = varargin;
    proj = ortho_proj([1 0 0], [0 1 0],'alatt',alatt,'angdeg',angdeg,'type','ppr');
end

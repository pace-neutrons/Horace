function  [new_obj,targ_img_range] = build_from_input_binning(obj,...
    targ_proj,source_proj,source_img_range,pbin)
% build new axes_block object from the binning parameters, provided
% as input. If some input binning parameters are missing, the
% defauls are taken from existing axes_block object.
%
% if the target range defined by binning exceeds the existing image range
% (in target coordinate system), the existing image range is selected
%
% Inputs:
% targ_proj       -- the projection, defining the target coordinate system
% source_proj     -- the projection, defining the coordinate system where
%                    current image is expressed
%source_img_range -- the ranges of source image, where cut is taken from
% pbin            -- cellarray of input binning parameters, which define
%                    target image binning
% where each cell can contains the following parameters:
%               - [] or ''          Use default bins (bin size and limits)
%               - [pstep]           Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]        Integration axis: range of integration
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
%               - [plo, pstep, phi, width] Integration axis: one output cut for each integration
%                                  range centred on plo, plo+step, plo+2*step... and with width
%                                  given by 'width'
%                                   If width=0, it is taken to be equal to pstep.
% Outputs:
% obj            - initialized instance of axes_block class
% targ_img_range - the ranges of the target image to rebin within

% calculate target image ranges from the binning requested:
% set up NaN=s for values, which have to be redefined from source
targ_img_range = cellfun(@(x)parce_pbin(obj,x),pbin,'UniformOutput',false);



function range = parce_pbin(obj,pbin)
% get defined binning range from the 
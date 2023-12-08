function [dnd_data,exper_combined,mhc] = combine_exper_and_img_( ...
    experiments,img_metadata,inputs,allow_equal_headers,keep_runid, ...
    job_dp,hor_log_level)
%COMBINE_EXPER_AND_IMG_  checks consistency of DnD image and combines input
%image data and experiment data together
%
% Inputs:
% experiments   -- cellarray of experiment data to combine
% img_metadata  -- cellarray of images metadata to check consistency and
%                  combine together
% inputs        -- cellarray of sqw objects or objects with sqw interface
%                  to extract images and combine them together.
% allow_equal_headers
%               -- if true, equal experiment data are allowed. If false,
%                  all experiment data should belong to different runs. If
%                  the runs found to be the same, throws invalid_argument
%                  exception
% keep_runid    -- if true, keep run_id-s already defined in input
%                  experiment data. If false recalculate all experments
%                  from 1 to number of contributing runs
% job_dp        -- instance of job dispatcher, containing references to
%                  running cluster to combine images in parallel. If empty,
%                  no parallel combining.
% hor_log_level -- the variable from hor_config.log_level, defining the
%                  verbocity of the operations.


% check the consistency of image headers as this is the grid where pixels
% are binned on and they have to be binned on the same grid
% We must have same data information for transforming pixels coordinates to image coordinates
filenames = cellfun(@(x)x.full_filename,inputs,'UniformOutput',false);
img_range = check_img_consistency_(img_metadata,filenames);

% Check consistency:
% At present, we insist that the contributing spe data for:
%   - filename, efix, psi, omega, dpsi, gl, gs cannot all be equal for two
%     spe data inputs
%   - emode, lattice parameters, u, v, sample must be the same for all spe
%     data inputs.
[exper_combined,nspe] = Experiment.combine_experiments(experiments,allow_equal_headers,keep_runid);


%  Build combined header
nfiles_tot=sum(nspe);
mhc = main_header_cl('nfiles',nfiles_tot);

ab = img_metadata{1}.axes;
proj = img_metadata{1}.proj;

% combine all images stored in all input files or data sources together.
dnd_data = build_combined_img_(ab,proj,inputs,job_dp,hor_log_level);
dnd_data.axes.img_range = img_range;

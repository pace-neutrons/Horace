function img_range = check_img_consistency_(img_metadata,sources)
% CHECK_IMG_CONSISTENCY check the consistency of image metadata as the metadata
% define the grid where pixels are binned on and they have to be binned on
% the same grid
%
% We must also have same information for transforming pixels coordinates
% to image coordinates.
%
% Inputs:
% img_metadata  -- cellarray of DnD image metadata classes each class
%                  containing information about image metadata
% sources       -- cellarray of data sources of the image metadata,
%                  containing information about sources of the metadata
%                  Used for errors reporting only.
%
n_inputs = numel(img_metadata);
img_range=img_metadata{1}.img_range;
proj = img_metadata{1}.proj;
for i=2:n_inputs
    loc_range = img_metadata{i}.img_range;
    if ~equal_to_tol(proj,img_metadata{i}.proj,'tol',4*eps('single'))
        error('HORACE:algorithms:invalid_arguments',[...
            'The image projection for contributing sqw/tmp objects have to be the same.\n ' ...
            'the projection for object N%d, file-name: %s different from the projection for the first contributing obj, filename: %s\n'],...
            i,sources{i}.full_filename,sources{1}.full_filename);
    end
    if any(abs(img_range(:)-loc_range(:))) > 4*eps('single')
        error('HORACE:algorithms:invalid_arguments',[...
            'The binning ranges for all contributing sqw/tmp objects have to be the same.\n ' ...
            'Range for obj N%d, file-name: %s different from the range of the first contributing object: %s\n' ...
            ' *** min1: %s min%d: %s\,' ...
            ' *** max1: %s max%d: %s\n'], ...
            i,sources{i}.full_filename,sources{1}.full_filename, ...
            mat2str(img_range(1,:)),i,mat2str(loc_range(1,:)), ...
            mat2str(img_range(2,:)),i,mat2str(loc_range(2,:)))
    end

    % define total img range as minmax of contributing ranges to
    % avoid round-off errors
    img_range=minmax_ranges(img_range,loc_range);
end
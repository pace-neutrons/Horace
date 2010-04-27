function  npix = read_npix_attribute(this)
% function reads the attribute, which describes the number of pixels in the
% signal dataset;

% open attribute;
attr = H5A.open_name (this.signal_DSID,'n_pixels_in_file');

% Get dataspace
space = H5A.get_space (attr);
%
% Read the data.
npix=H5A.read (attr, 'H5T_NATIVE_DOUBLE');
% clearn up
%H5D.close (dset);
H5S.close (space);
H5A.close(attr);



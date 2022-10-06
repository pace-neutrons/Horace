function wout = cut_single_(w, tag_proj, targ_axes,return_cut, outfile,log_level)
%%CUT_SINGLE Perform a cut on a single sqw object
%
% Input:
% ------
% w           The dnd object to take a cut from.
% tag_proj    A `projection` object, defining the projection of the cut.
% targ_axes   `axes_block` object defining the ranges, binning and geometry
%             of the target cut
% return_cut  if false, save output cut into the file  (name provided)
% outfile     The output file to write the cut to, empty if cut is not to be
%             written to file (char).
% log_level   verbosity of the cut progress report. Taken from
%             hor_config.log_level and propagated through the parameters to
%             avoid subsequent calls to hor_config.
%
% Output:
% -------
% wout       The output cut. If keep_pix is true this will be an SQW object,
%            else it will be DnD object.
%            This output argument can be omitted if `outfile` is specified.
%


% Interpolate image and accumulate interpolated data for cut
[s, e, npix] = cut_interpolate_data_( ...
    w, tag_proj,targ_axes);


% Compile the accumulated cut and projection data into a dnd object
wout = DnDBase.dnd(targ_axes,proj,s,e,npix);


% Write result to file if necessary
if exist('outfile', 'var') && ~isempty(outfile)
    if log_level >= 0
        disp(['*** Writing cut to output file ', outfile, '...']);
    end
    try
        save(wout, outfile);
    catch ME
        warning('HORACE:cut_dnd:io_error', ...
            'Error writing to file ''%s''.\n%s: %s', ...
            outfile, ME.identifier, ME.message);
    end
end

function [s, e, npix] =  cut_interpolate_data_(obj, targ_proj, targ_axes)
%%CUT_INTERPOLATE_DATA Interpolate and accumulate image data for a cut
%
% Input:
% ------
% targ_proj  A 'projection' object, defining the projection of the cut.
% targ_axes  A 'axes_block' object defining the ranges, binning and geometry
%            of the target cut
%
% Output:
% -------
% s          The image signal data.
% e          The variance in the image signal data.
% npix       Array defining how many pixels are contained in each image
%            bin. size(npix) == size(s). As the data are interpolated, 
%            the number of pixels may become fractional  

obj.proj.targ_proj = targ_proj;
targ_proj.targ_proj = obj.proj;

s = obj.s.*obj.npix;
e = obj.e.*(obj.npix.^2);
targ_intep = obj.axes.get_density({s,e,obj.npix});
%
% convert the source grid into target coordinate system
targ_intep(1:4,:) = tag_proj.from_this_to_targ_coord(targ_intep(1:4,:));
[~,si,ei,npixi] = targ_axes.bin_pixels(targ_intep);
% obtain the cell volume of the target coordinate system to convert from 
% density to signal/err etc.
targ_cell_volume = targ_axes.get_grid_volume();

s = si.*targ_cell_volume;
e = ei.*tart_cell_volume;
npix = npixi.*targ_cell_volume;

[s, e] = normalize_signal(s, e, npix);

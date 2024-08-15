function varargout = cut_single_(w, tag_proj, targ_axes,return_cut, ...
                                 opt,log_level)
%%CUT_SINGLE Perform a cut on a single sqw object
%
% Input:
% ------
% w           The dnd object to take a cut from.
% tag_proj    A `projection` object, defining the projection of the cut.
% targ_axes   `line_axes` object defining the ranges, binning and geometry
%             of the target cut
% return_cut  if false, save output cut into the file  (name provided)
% opt         Structure containing the following args:
%     outfile     The output file to write the cut to, empty if cut is not to be
%                 written to file (char).
%     proj_given  if true, user provided projection and cut_interpolate algorithm
%                 should be used, if false, rebinning/integration algorithm
%                 should be invoked
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
outfile = opt.outfile;
proj_given = opt.proj_given;

if ~return_cut
    if ~ischar(outfile) || isempty(outfile)
        error('HORACE:cut_dnd:invalid_argument',...
            'saving to output file requested but no output file name is provided')
    end
end


%proj_given = true;
if proj_given
    % Interpolate image on non-commensurate grid and accumulate interpolated
    % data for cut
    warning('HORACE:developers_option', ...
        'This type of cut is incomplete and not fully verified. The results may be incorrect. Use it on your own risk')
    [s, e, npix] = cut_interpolate_data_( ...
        w, tag_proj,targ_axes);
else
    % ingegrate signal and error withing commensurate grids
    [s, e, npix,targ_axes] = cut_integrate_data_( ...
        w, targ_axes);
end


% Compile the accumulated cut and projection data into a dnd object
wout = DnDBase.dnd(targ_axes,tag_proj,s,e,npix);


% Write result to file if necessary
if return_cut
    varargout{1} = wout;
else
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
%
function [s, e, npix,realigned_axes] =  cut_integrate_data_(obj, target_axes)
%CUT_INTEGRATE_DATA returns cut data integrated over aligned bin ranges
%
% check bin ranges and ensure they are realigned
realigned_axes = obj.axes.realign_bin_edges(target_axes);
% convert datasets in the form, suitable for summation
npix = obj.npix;
s = obj.s.*npix;
e = obj.e.*npix.^2;
% rebin data over realigned regions
data_out = obj.axes.rebin_data({s,e,npix},realigned_axes);

npix = data_out{3};
[s, e] = normalize_signal(data_out{1}, data_out{2}, npix);


function [s, e, npix] =  cut_interpolate_data_(obj, targ_proj, targ_axes)
%%CUT_INTERPOLATE_DATA Interpolate and accumulate image data for a cut
%
% Input:
% ------
% targ_proj  A 'projection' object, defining the projection of the cut.
% targ_axes  A 'AxesBlockBase' object defining the ranges, binning and geometry
%            of the target cut
%
% Output:
% -------
% s          The image signal data.
% e          The variance in the image signal data.
% npix       Array defining how many pixels are contained in each image
%            bin. size(npix) == size(s). As the data are interpolated,
%            the number of pixels may become fractional

s = obj.s;

[s,e,npix] = targ_axes.interpolate_data(obj.axes,obj.proj,{s},targ_proj);
npix(:)= 1;
%[s, e] = normalize_signal(s, e, npix);

function wout = cut(obj, varargin)
%%CUT Take a cut from an sqw object by transforming data into new coordinate
% system and then rebinning data or integrating them over one or more axes.
%
% Cut using existing projection axes:
%   >> wout = cut (data_source, p1_bin, p2_bin...)  % (as many binning arguments
%                                                % as there are plot axes)
%
% Cut with new projection axes:
%   >> wout = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%
%   >> wout = cut (..., '-nopix')   % output cut is dnd class (i.e. only
%                                   % image information is retained)
%
%   >> wout = cut (...,  filename)     % save cut to named file
%
% Write directly to file without creating an output object (useful if the
% output is a large dataset in order to avoid out-of-memory errors)
%
%   >> cut (..., filename)  % note no return argument
%
% Input:
% ------
%   data_source    Data source: sqw-type object (sqw or sqw data accessor)
%
%   proj           instance of aProjection class (ortho_proj) as defailts
%                  or Data structure containing the projection class fields,
%                  (names and its values)
%                  (type >> help ortho_proj   for details)
%
%   p1_bin          Binning along first Q axis
%   p2_bin          Binning along second Q axis
%   p3_bin          Binning along third Q axis
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                               taken from the extent of the data. If pstep
%                               is 0, step is also taken from input data
%                               (equivalent to [])
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centers
%                              and step size
%                              For example, [106, 4, 116] will define a plot
%                              axis with bin edges 104-108, 108-112, 112-116.
%                              if step is 0,
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range center,
%                                distance between range centers, maximum range
%                                center, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                outputted. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%                                For example, [106, 4, 113, 2] defines the
%                                integration range for three cuts, the first
%                                cut integrates the axis over 105-107, the
%                                second over 109-111 and the third 113-115.
%
%   p4_bin          Binning along the energy axis:
%           - [] or ''          Plot axis: use bin boundaries of input data
%           - [pstep]           Plot axis: sets step size; plot limits
%                              taken from the extent of the data.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronize the output bin
%                              boundaries with those boundaries. The overall
%                              range is chosen to ensure that the energy
%                              range of the input data is contained within
%                              the bin boundaries.
%           - [plo, phi]        Integration axis: range of integration
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centers
%                              and step size.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronize the output bin
%                              boundaries with the reference boundaries.
%                              The overall range is chosen to ensure that
%                              the energy range plo to phi is contained
%                              within the bin boundaries.
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range center,
%                                distance between range centers, maximum range
%                                center, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                outputted. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%
%
% Output:
% -------
%   wout            Output data object:
%                     - sqw-type object with full pixel information
%                     - dnd-type object if option '-nopix' given
%

if numel(obj) > 1
    wout = cut(num2cell(obj),varargin{:});
    return;
end
hc= hor_config;
log_level = hc.log_level;

dnd_type = obj.pix.num_pixels == 0;
if dnd_type
    % Input has no pixels, delegate to cut_dnd as the result is dnd
    wout = cut(obj.data,varargin{:});
    return
end

return_cut = nargout > 0;
%
[targ_proj, pbin, opt] = SQWDnDBase.process_and_validate_cut_inputs(...
    obj.data,return_cut, varargin{:});
% Set up new projection properties, related to lattice. This together with
% projection inputs defines pixels-to-image transformation.
header_av = header_average(obj);
targ_proj.alatt  = header_av.alatt;
targ_proj.angdeg = header_av.angdeg;
% TODO: this is compartibility function. It will change when alginment matrix
% is attached to pixels. In fact, it redefines b-matrix (and partially U-matix
% used for alignment), which is the function of lattice. See ticket #885
targ_proj = targ_proj.set_ub_inv_compat(header_av.u_to_rlu(1:3,1:3));

%
sz = size(pbin);
% This loop enables multicuts
if return_cut
    wout = cell(sz);
end
for cut_num = 1:prod(sz)
    pbin_tmp = pbin{cut_num};
    [targ_ax_block,targ_proj] = define_target_axes_block(obj, targ_proj, pbin_tmp,header_av );

    args = {obj, targ_proj, targ_ax_block, opt.keep_pix, opt.outfile,log_level};
    if return_cut
        wout{cut_num} = cut_single_(args{:});
    else
        cut_single_(args{:});
    end
end
if return_cut
    wout = [wout{:}]';
end
% End function

function [targ_ax_block,targ_proj] = define_target_axes_block(w, targ_proj, pbin,header_av)
% define target axes from existing axes, inputs and the projections
%
img_block = w.data;
source_proj = img_block.proj;
%--------------------------------------------------------------------------
% Get the source binning ranges, transformed into target coordinate system.
% It is actually axes_block method, so source projection is provided as
% input of this method.
source_binning = img_block.axes.get_binning_range(...
    source_proj,targ_proj);
%
targ_ax_block  = targ_proj.get_proj_axes_block(source_binning,pbin);
targ_ax_block.filename = img_block.filename;
targ_ax_block.filepath = img_block.filepath;

function log_progress(data_source,hor_log_level,npix_total)
if hor_log_level>=1
    if ischar(data_source)
        disp(['Number of points in input file: ',num2str(npixtot)])
        disp(['         Fraction of file read: ',num2str(100*npix_read/double(npixtot),'%8.4f'),' %   (=',num2str(npix_read),' points)'])
        disp(['     Fraction of file retained: ',num2str(100*npix_retain/double(npixtot),'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
    else
        disp(['    Number of points in object: ',num2str(npixtot)])
        disp(['  Fraction of object processed: ',num2str(100*npix_read/double(npixtot),'%8.4f'),' %   (=',num2str(npix_read),' points)'])
        disp(['   Fraction of object retained: ',num2str(100*npix_retain/double(npixtot),'%8.4f'),' %   (=',num2str(npix_retain),' points)'])
    end
    disp(' ')
    bigtoc('Total time in cut_sqw:',hor_log_level)
    disp('--------------------------------------------------------------------------------')
end


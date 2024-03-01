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
%   >> wout = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin, sym)
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
%   proj           instance of aProjectionBase class (line_proj by default)
%                  which describes the target coordinate system of the cut
%                  or Data structure containing the projection class fields,
%                  (names and its values)
%                  (type >> help line_proj   for details)
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
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size
%                              For example, [106, 4, 116] will define a plot
%                              axis with bin edges 104-108, 108-112, 112-116.
%                              if step is 0,
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range centre,
%                                distance between range centres, maximum range
%                                centre, range size for each cut.
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
%           - [plo, pstep, phi] Plot axis: minimum and maximum bin centres
%                              and step size.
%                               If pstep=0 then use bin size of the first
%                              spe file and synchronize the output bin
%                              boundaries with the reference boundaries.
%                              The overall range is chosen to ensure that
%                              the energy range plo to phi is contained
%                              within the bin boundaries.
%           - [plo, rdiff, phi, rwidth]
%                                Integration axis: minimum range centre,
%                                distance between range centres, maximum range
%                                center, range size for each cut.
%                                When using this syntax, an array of cuts is
%                                outputted. The number of cuts produced will
%                                be the number of rdiff sized steps between plo
%                                and phi; phi will be automatically increased
%                                such that rdiff divides phi - plo.
%
%   sym             Symmetry operator (or an array of symmetry operators
%                  to be applied in the order sym(1), sym(2),...)
%                  by which a symmetry related cut is to be accumulated.
%                   Must have class symop.
%
%                   For several symmetry related cuts, provide a cell array
%                  of symmetry operators and/or arrays of symmetry operators
%           EXAMPLES
%                   s1 = symop ([1,0,0],[0,1,0],[1,1,1]);
%                   s2 = symop ([1,0,0],[0,0,1],[1,1,1]);
%                   % For all four symmetry related cuts:
%                   sym = {s1,s2,[s1,s2]};
%
% NOTE:
% All binning parameters are expressed in the coordinate system described by proj.
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
hc = hor_config;
log_level = hc.log_level;

dnd_type = obj.pix.num_pixels == 0;
if dnd_type
    % Input has no pixels, delegate to cut_dnd as the result is dnd
    wout = cut(obj.data,varargin{:});
    return
end

return_cut = nargout > 0;

%
% Set up new projection properties, related to lattice. This together with
% projection inputs defines pixels-to-image transformation.
[targ_proj, pbin, sym, opt] = SQWDnDBase.process_and_validate_cut_inputs(...
    obj.data,return_cut, varargin{:});


% verify if source projection is line_projection as
% it may contain legacy alignment, we do not want transfer to other
% projections. (TODO: need to be converted into recent alignment)
source_is_line_proj = isa(obj.data.proj,'line_proj');
% nasty legacy alignment business. TODO: deal with it
target_is_line_proj = isa(targ_proj,'line_proj');
% if we are realigning old format file, legacy alignment matrix should be
% ignored
if source_is_line_proj && target_is_line_proj && targ_proj.ignore_legacy_alignment
    obj.data.proj.ub_inv_legacy = [];
end

% old file format alignment. Only line_proj is supported
if  source_is_line_proj && ~isempty(obj.data.proj.ub_inv_legacy)
    if target_is_line_proj % transfer legacy alignment matrix to
        % new projection to keep legacy alignment
        targ_proj = targ_proj.set_ub_inv_compat(obj.data.proj.ub_inv_legacy);
    else
        pn = class(targ_proj); 
        warning('HORACE:old_file_format', ...
            ['\n %s are fully supported by version 4.0 and higher Horace sqw objects only.\n', ...
            ' If you use aligned sqw object produced by old Horace version,\n', ...
            ' the resulting cut with %s will be performed on misaligned data\n', ...
            ' Convert old misaligned data into new file-format and realign these data again to use cuts with %s.'], ...
            pn,pn,pn);
    end
end
%
sz = size(pbin);

% This loop enables multi-cuts
if return_cut
    wout = cell(sz);
end

for cut_num = 1:prod(sz)
    pbin_tmp = pbin{cut_num};
    [targ_ax_block, targ_proj] = obj.define_target_axes_block(targ_proj, pbin_tmp, sym);

    if return_cut
        wout{cut_num} = cut_single_(obj, targ_proj, targ_ax_block, opt, log_level);
    else
        cut_single_(obj, targ_proj, targ_ax_block, opt, log_level);
    end
end

if return_cut
    wout = [wout{:}]';
end
end

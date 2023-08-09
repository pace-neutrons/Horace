function wout = cut(obj, varargin)
%%CUT Take a cut from a dnd object by integrating over one or more axes.
% or by interpolating density data if projection is provided.
%
% Cut using existing projection axes:
%  >> wout = cut (obj, p1_bin, p2_bin...)  % (as many binning arguments
%                                             % as there are plot axes)
% Or
% Cut with new projection axes:
%  >> wout = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)
% NOTE:
% This options causes dnd data running average with half-bin window
%
%
%  >> wout = cut (...,  filename)   % save cut to named file
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
%   proj           instance of aProjectionBase class (ortho_proj by default)
%                  which describes the target coordinate system of the cut
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
hc= hor_config;
log_level = hc.log_level;

return_cut = nargout > 0;
[targ_proj, pbin, sym, opt] = SQWDnDBase.process_and_validate_cut_inputs(...
    obj, return_cut, varargin{:});

sz = size(pbin);
% This loop enables multicuts
if return_cut
    wout = cell(sz);
end

for cut_num = 1:prod(sz)
    pbin_tmp = pbin{cut_num};
    [targ_ax_block,targ_proj] = obj.define_target_axes_block(targ_proj, pbin_tmp, sym);

    if return_cut
        wout{cut_num} = cut_single(obj, targ_proj, targ_ax_block, opt,log_level);
    else
        cut_single(obj, targ_proj, targ_ax_block, opt,log_level);
    end
end

if return_cut
    wout = [wout{:}]';
end
% End function

function wout = cut(obj, varargin)
%%CUT Take a cut from an sqw object by integrating over one or more axes.
%
% Cut using existing projection axes:
%   >> wout = cut (data_source, p1_bin, p2_bin...)  % (as many binning arguments
%                                                % as there are plot axes)
%
% Cut with new projection axes:
%   >> wout = cut (data_source, proj, p1_bin, p2_bin, p3_bin, p4_bin)
%
%   >> wout = cut (..., '-nopix')      % output cut is dnd structure (i.e. no
%                                   % pixel information is retained)
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
%   data_source     Data source: sqw file name or sqw-type object
%                  Can also be a cell array of file names or an array of
%                  sqw objects.
%
%   proj           Data structure containing details of projection axes,
%                  with fields described below. Alternatively, a projaxes
%                  object created from those fields (type >> help projaxes
%                  for details).
%     ---------------------------------------------------------------------
%     Required fields:
%       u           [1x3] Vector of first axis (r.l.u.) defining projection axes
%       v           [1x3] Vector of second axis (r.l.u.) defining projection axes
%
%     Optional fields:
%       w           [1x3] Vector of third axis (r.l.u.) - only needed if the third
%                   character of argument 'type' is 'p'. Will otherwise be ignored.
%
%       nonorthogonal Indicate if non-orthogonal axes are permitted
%                   If false (default): construct orthogonal axes u1,u2,u3 from u,v
%                   by defining: u1 || u; u2 in plane of u and v but perpendicular
%                   to u with positive component along v; u3 || u x v
%
%                   If true: use u,v (and w, if given) as non-orthogonal projection
%                   axes: u1 || u, u2 || v, u3 || w if given, or u3 || u x v if not.
%
%       type        [1x3] Character string defining normalization. Each character
%                   indicates how u1, u2, u3 are normalized, as follows:
%                   - if 'a': projection axis unit length is one inverse Angstrom
%                   - if 'r': then if ui=(h,k,l) in r.l.u., is normalized so
%                             max(abs(h,k,l))=1
%                   - if 'p': if orthogonal projection axes:
%                                   |u1|=|u|, (u x u2)=(u x v), (u x u3)=(u x w)
%                               i.e. the projections of u,v,w along u1,u2,u3 match
%                               the lengths of u1,u2,u3
%
%                             if non-orthogonal axes:
%                                   u1=u;  u2=v;  u3=w
%                   Default:
%                         'ppr'  if w not given
%                         'ppp'  if w is given
%
%         uoffset   Row or column vector of offset of origin of projection axes (rlu)
%
%       lab         Short labels for u1,u2,u3,u4 as cell array
%                   e.g. {'Q_h', 'Q_k', 'Q_l', 'En'})
%                       *OR*
%       lab1        Short label for u1 axis (e.g. 'Q_h' or 'Q_{kk}')
%       lab2        Short label for u2 axis
%       lab3        Short label for u3 axis
%       lab4        Short label for u4 axis (e.g. 'E' or 'En')
%     ---------------------------------------------------------------------
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
DND_CONSTRUCTORS = {@d0d, @d1d, @d2d, @d3d, @d4d};

if numel(obj) > 1
    error('SQW:cut', ...
        ['You cannot take a cut from an array, or cell array, of sqw or ' ...
        'dnd objects.\nConsider cutting the objects in a loop.']);
end

dnd_type = obj.data.pix.num_pixels == 0;
if dnd_type
    % Input has no pixels, delegate to cut_dnd
    % TODO: refactor so cut_dnd_main sits on DnDBase class
    ndims_source = numel(obj.data.pax);
    wout = cut_dnd_main(obj, ndims_source, varargin{:});
    return
end

return_cut = nargout > 0;
[targ_proj, pbin, opt] = obj.process_and_validate_cut_inputs(...
    return_cut, varargin{:});
% Set up new projection properties, related to lattice. This together with
% projection inputs defines pixels-to-image transformation.
header_av = header_average(obj);
targ_proj.alatt  = header_av.alatt;
targ_proj.angdeg = header_av.angdeg;
%
sz = cellfun(@(x) max(size(x, 1), 1), pbin);
if return_cut
    wout = allocate_output(sz, pbin, opt.keep_pix, DND_CONSTRUCTORS);
end

% This loop enables multicuts
for cut_num = 1:prod(sz)
    pbin_tmp = get_pbin_for_cut(sz, cut_num, pbin);
    targ_ax_block = define_target_axes_block(obj, targ_proj, pbin_tmp );
    
    args = {obj, targ_proj, targ_ax_block, opt.keep_pix, opt.outfile};
    if return_cut
        wout(cut_num) = cut_single(args{:});
    else
        cut_single(args{:});
    end
end
% End function

function targ_ax_block = define_target_axes_block(w, targ_proj, pbin)
% define target axes from existing axes, inputs and the projections
%
img_block = w.data;
source_proj = img_block.get_projection();
% it is actually axes_block method, so source projection is provided as
% input of this method. Left in this form for refactoring
source_binning = img_block.get_default_binning_range(img_block.img_db_range,...
    source_proj,targ_proj);
targ_ax_block = axes_block.build_from_input_binning(source_binning,pbin);




function num_dims = get_num_output_dims(pbin)
% Get the number of dimensions in the output cut from the projection axis
% binning.

% pbin axes being integrated over will be an array with two elements - the
% integration range - else the pbin element will have 1 or 3 elements
% if pbin{x} has more than 3 elements then we are doing a multicut and that
% axis is being integrated over.
% The ~isempty catches any dummy axes that are 0x0 doubles.
is_non_int_axis = @(x) numel(x) ~= 2 && numel(x) < 4 && ~isempty(x);
non_integrated_axis = cellfun(is_non_int_axis, pbin);
num_dims = sum(non_integrated_axis);



function out = allocate_output(sz, pbin, keep_pix, dnd_constructors)
% Allocate an array of cut outputs using the projection binning
sz_squeeze = [sz(sz > 1), ones(1, max(2 - sum(sz > 1), 0))];
if keep_pix
    out = repmat(sqw, sz_squeeze);
else
    out_dims = get_num_output_dims(pbin);
    out = repmat(dnd_constructors{out_dims + 1}(), sz_squeeze);
end



function pbin_out = get_pbin_for_cut(sz, cut_num, pbin_in)
% Get pbin for each cut (allow for a bin descriptor being empty)
ind_subs = cell(1, 4);
[ind_subs{:}] = ind2sub(sz, cut_num);
pbin_out = cell(1,4);
for i = 1:numel(pbin_out)
    if ~isempty(pbin_in{i})
        pbin_out{i} = pbin_in{i}(ind_subs{i}, :);
    else
        pbin_out{i} = pbin_in{i};
    end
end

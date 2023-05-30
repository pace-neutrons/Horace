function range = targ_range(obj,targ_proj,varargin)
%TARG_RANGE calculate the full range of the image to be produced by target
% projection from the current image,
%
% Optional:
% '-binning' if present, the method returns range as cellarray of binning
%            parameters, i.e. the parameters which you would provide to cut
%            to get the target cut in the ranges produced
%
%
[ok,mess,do_binning_range] = parse_char_options(varargin,'-binning');
if ~ok
    error('HORACE:DnDBase:invalid_argument',mess);
end
if ~exist('targ_proj','var') || isempty(targ_proj)
    % getting binning range which produced existing DnD object
    range = obj.img_range;
else
    source_proj = obj.proj;
    if isstruct(targ_proj) % allow input to be a structure
        if serializable.is_serial_struct(targ_proj)
            targ_proj = serializable.from_struct(targ_proj);
        else
            op = ortho_proj();
            targ_proj = op.from_bare_struct(targ_proj);
        end
    end
    if ~targ_proj.alatt_defined
        targ_proj.alatt = source_proj.alatt;
    end
    if ~targ_proj.angdeg_defined
        targ_proj.angdeg = source_proj.angdeg;
    end
    if ~isa(targ_proj,'ortho_proj') && (isa(source_proj,'ortho_proj') && ~isempty(source_proj.ub_inv_legacy))
        warning('HORACE:old_file_format', ...
            ['\n Non-linear projections are fully supported by version 4.0 and higher Horace sqw objects only.\n', ...
            ' If you use alignled sqw object produced by old Horace version,\n', ...
            ' the resulting cut with non-triclinic projection will be performed on misaligned data\n', ...
            ' Convert old misaligned data into new file-format and realign these data again to use cuts with not-triclinic projections.']);
    end
    %
    % cross-assign appropriate projections to enable possible optimizations
    source_proj.targ_proj = targ_proj;
    targ_proj.targ_proj   = source_proj;

    if isa(source_proj,class(targ_proj))
        % if both projections relate to the same coordinate system, the min/max
        % evaluation will be sufficient
        cur_range = obj.img_range;
        full_range = expand_box(cur_range(1,:),cur_range(2,:));
        full_targ_range = source_proj.from_this_to_targ_coord(full_range);
        range = [min(full_targ_range,[],2),max(full_targ_range,[],2)]';
    else
        % if not, analyse cut hull to understand what ranges can be
        % specified
        range = search_for_range(obj,source_proj);
    end
end
if do_binning_range
    nsteps = obj.axes.nbins_all_dims;
    range  = arrayfun(@build_binning,range(1,:),range(2,:),nsteps,'UniformOutput',false);
end

function bin_range = build_binning(min_range,max_range,nsteps)
% simple procedure which convert range into binning parameters
if nsteps == 1% integration range
    bin_range = [min_range,max_range];
    return
end
step = (max_range-min_range)/(nsteps);
% axis binning parameters
bin_range = [min_range+step/2,step,max_range-step/2];

function range = search_for_range(obj,source_proj)
% find the maximal range, the current grid occupies in target coordinate
% system
%
% The most primitive and pretty memory expensive search algorithm possible.
%
[range0,dE_range] = transf_range(obj,source_proj,1);
difr = 1;
node_mult = 2;
while difr>1.e-3 && node_mult<33 % node multiplier doubles number of points
    % on each iteration step and goes 2,4,8,16,32. As the number of points increases on the hull,
    % it is still not too big number so memory requests are acceptable.
    range = transf_range(obj,source_proj,node_mult);
    difr = calc_difr(range0,range);
    range0 = range;
    node_mult = node_mult*2;
end
if node_mult > 32
    warning('HORACE:targ_range', ...
        ['target range search algorithm have not converged after 5 iterations.\n', ...
        ' The default range identified for the cut may be inaccurate'])
end
%
if source_proj.do_3D_transformation
    range  = [range,dE_range];
end

function [loc_range,dE_range] = transf_range(obj,source_proj,multiplier)
% transfer axes hull into target coordinate system.
if source_proj.do_3D_transformation
    shell = obj.axes.get_bin_nodes('-3D','-hull',multiplier);
    dE_range = obj.axes.img_range(:,4);
else
    shell = obj.axes.get_bin_nodes('-hull',multiplier);
    dE_range = [];
end
shell_transf = source_proj.from_this_to_targ_coord(shell);
loc_range = [min(shell_transf,[],2),max(shell_transf,[],2)]';

function difr = calc_difr(range0,range)
% calculate maximal difference between two ranges
min_difr = max(-(range(1,:)-range0(1,:)));
max_difr = max((range(2,:)-range0(2,:)));
difr     = max(min_difr,max_difr);
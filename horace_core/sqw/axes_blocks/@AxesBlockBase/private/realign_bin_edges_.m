function ax_block_al = realign_bin_edges_(obj,ax_block)
% align input axes block to have the same or commensurate
% bin sizes as this axes block and the integration ranges equal
% or smaller than the ranges of this axes block but
% commensurate with this lattice
%
hc = hor_config;
log_level = hc.log_level;
want_pax = false(1,4);
want_pax(ax_block.pax) = true;
this_is_pax = false(1,4);
this_is_pax(obj.pax) = true;

this_range = obj.img_range;
ax_range   = ax_block.img_range;
ax_nbins   = ax_block.nbins_all_dims;
this_nbins = obj.nbins_all_dims;
for i=1:4
    if want_pax(i) % pax requested
        if this_is_pax(i)
            [ax_nbins(i),ax_range(:,i)] = ...
                realign_pax(i,this_range(:,i),this_nbins(i),ax_range(:,i),ax_nbins(i),log_level);
        else % but was iax in this direction, so only iax possible
            ax_nbins(i) = 1;
            ax_range(:,i) = this_range(:,i);
            if log_level>0
                warning('HORACE:realign_bin_edges:invalid_argument', ...
                    ['projection axis is requested in direction N%d, ',...
                    'but original axis there is integration. ',...
                    'Can not rebin integration axis on dnd object.', ...
                    ' Doing integration axis in this direction'],...
                    i)
            end
        end
    else  %iax requested
        ax_nbins(i) = 1;
        ax_range(:,i) = find_proper_iax_range(this_range(:,i),this_nbins(i),ax_range(:,i));
    end
end
ax_block_al = feval(class(obj));
ax_block_al = ax_block_al.init(obj);
ax_block_al.img_range=ax_range;
ax_block_al.nbins_all_dims = ax_nbins;

function iax_requested = find_proper_iax_range(in_range,nbins,iax_requested)
% find integration range, which covers minimal axes range

%iax_requested(1) = max(in_range(1),iax_requested(1));
%iax_requested(2) = min(in_range(2),iax_requested(2));
if iax_requested(1)<in_range(1); iax_requested(1) = in_range(1);
end
if iax_requested(2)>in_range(2); iax_requested(2) = in_range(2);
end
bin_edges = linspace(in_range(1),in_range(2),nbins+1);
min_ind = find(bin_edges <= iax_requested(1),1,'last');
max_ind = find(bin_edges >= iax_requested(2),1,'first');
iax_requested(1) = bin_edges(min_ind);
iax_requested(2) = bin_edges(max_ind);

function [nbins,req_range] = realign_pax(i,origin_range,origin_nbins,req_range,req_nbins,log_level)
% build commensurate range and binning parameters for two overlapping axes
% ranges
% Input:
% origin_range -- range of existing data
% origin_bins  -- number of bins this range is divided into
% req_range    -- the suggested range one wants to obtain. The resulting
%                 range to be made commensurate with the existing range
% req_nbins    -- requested number of bins the range needs to be divided
%                 into.
if req_range(1) >=origin_range(2) % maximum provided is smaller then minimum requested
    % can not proceed
    error('HORACE:realign_bin_edges:invalid_argument', ...
        [' Existing maximal range: %g in direction %d is smaller then requested minimal range: %g.\n ',...
        ' Existing and requested cuts do not overlap'],...
        origin_range(2),i,req_range(1));
end
base_step = (origin_range(2)-origin_range(1))/(origin_nbins);
if req_range(2)-req_range(1) < base_step
    % requested interval is too narrow.  Expand it
    req_range(2)=req_range(1)+ base_step;
    if log_level > 0
        warning('HORACE:realign_bin_edges:invalid_argument', ...
            'New integration interval in direction %i has been expanded to [%g,%g] to cover at least one existing bin.',...
            i,req_range(1),req_range(2))
    end
end
% new step should be either equal to the old step or to be whole multiple
% of the old step
req_step0 = (req_range(2)-req_range(1))/(req_nbins);
if req_range(2)>origin_range(2)
    req_range(2) = origin_range(2);
end


% make requested step to be close to the base step or be multiples of it
step_scaling_factor = round(req_step0/base_step);
if step_scaling_factor<1
    req_step = base_step;
else
    req_step = base_step*step_scaling_factor;
end
if log_level > 0
    if abs(step_scaling_factor*base_step-req_step) > 1.e-4
        warning('HORACE:realign_bin_edges:invalid_argument', ...
            'The requested step in direction %d (%g) is not commensurate with the existing axis step %g. Changing it to: %g',...
            i,req_step0,base_step,req_step)
    end
end
% existing p-axis
bin_edges = linspace(origin_range(1),origin_range(2),origin_nbins+1);
first_edge = origin_range(1);

% realign bin centres
new_edge_1 = req_range(1);
if new_edge_1<first_edge
    % requested range
    new_edge_1 = first_edge;
end
ind = find(bin_edges <= new_edge_1,1,'last');
new_edge_1 = bin_edges(ind);
req_range(1) = new_edge_1;
nbins = floor((req_range(2)-req_range(1))/req_step);
test_range = req_range(1)+nbins*req_step;
if  test_range-req_range(2) < -2.e-8 % single precision round-off?
    nbins = nbins+1;
    req_range(2) = req_range(1)+nbins*req_step;
else
    req_range(2) = test_range; % assign to avoid round-off errors even if they are (almost) equal
end



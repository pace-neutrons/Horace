function  new_axes_block = build_from_input_binning(...
    axes_class_name,cur_img_range_and_steps,pbin)
% Build new AxesBlockBase object from the binning parameters, provided
% as input. If some input binning parameters are missing, the
% defaults are taken from the existing AxesBlockBase object.
%
% if the target range defined by binning exceeds the existing image range
% (in target coordinate system), the existing image range is selected
%
% Note: the binning parameters is the cellarray of 1,2 or 3 element vectors
%       with meaning described by cut_sqw or cut_dnd inputs. See below for more details.
%
% Inputs:
% axes_class_name -- name of the axes block class to build
% cur_img_range_and_steps
%          --   4-elements cellarray of the ranges and steps of source
%               image, expressed in the target coordinates and
%               used as source of default ranges.
%               if these ranges are not specified by pbin
% pbin     --   4-elements cellarray of input binning parameters, which define
%               target image binning.
% where each cell may contain the following parameters:
%               - [] or ''      Use default (default) bins (bin size and limits)
%               - [pstep]       Plot axis: sets step size; plot limits taken from extent of the data
%               - [plo, phi]    Integration axis: range of integration
%               - [plo, 0, phi] Plot axis: minimum and maximum bin centres
%                               and step size taken from existing binning
%               - [plo, pstep, phi] Plot axis: minimum and maximum bin centres and step size
% Outputs:
% new_axis_block    -- initialized instance of AxesBlockBase class

if numel(pbin) ~=4
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Have not provided binning descriptor for all three momentum axes and the energy axis');
end
if numel(cur_img_range_and_steps) ~=4
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Have not provided default binning for all three momentum axes and the energy axis');
else
    if size(cur_img_range_and_steps,1) > 1
        cur_img_range_and_steps = cur_img_range_and_steps';
    end
end


% calculate target image ranges from the binning requested:
% set up NaN=s for values, which have to be redefined from source
idim = 1:4;
ind = num2cell(idim);
% Check values are acceptable, and make ranges (3+2)x1 (for plot) or (2+2)x1 for integration axes
% ---------------------------------------------------------------------------------------
targ_img_range = cellfun(@(i,bin_rec,bin_def)parse_pbin(i,bin_rec,bin_def),...
    ind,pbin,cur_img_range_and_steps,'UniformOutput',false);

new_axes_block = feval(axes_class_name);
new_axes_block = new_axes_block.init(targ_img_range{:});

end

function range = parse_pbin(ind,bin_req,bin_default)
% get defined binning range from the various input parameters
%
% This function defines the logic behind the binning parameters
% interpretation
%
% Returns:
% range  vector containing the defined bin ranges i.e. the ranges
%        either copied from requested or from default values
%
switch numel(bin_req)
  case 0 % Default
    range = bin_default;

  case 1 % Rebin
    if bin_req == 0
        if numel(bin_default) == 2 % this may fail if bin_default is integration axis
            error('HORACE:build_from_input_binning:invalid_argument', ...
                  'User has requested auto-rebin (pbin = [0]) across integration axis (%d).', ind);
        end
        bin_req = bin_default(2);
    end
    range = [bin_default(1),bin_req,bin_default(end)];

  case 2 % Integration

    range = bin_req;
    if isinf(range(1))
        range(1) = bin_default(1);
    end
    if isinf(range(end))
        range(end) = bin_default(end);
    end

    border = abs(SQWDnDBase.border_size);
    % we need correct integration range for cut to work but some old file
    if abs(range(2)-range(1))<2*border  % formats do not store proper
                                        % img_range and store [centerpoint, centerpoint] for
                                        % integration ranges. Here we try to mitigate this.
        av_pt = 0.5*(range(1)+range(2));
        if abs(av_pt) < border
            range(1) = -border;
            range(2) =  border;
        else
            range(1) = av_pt*(1 - border);
            range(2) = av_pt*(1 + border);
        end
    end

  case 3 % Projection
    range = bin_req;
    if isinf(range(1))
        range(1) = bin_default(1);
    end
    if isinf(range(end))
        range(end) = bin_default(end);
    end

    if range(2) == 0
        if numel(bin_default) == 3
            range(2) = bin_default(2);
        else % integrate in ranges, defined by default bin boundaries if step is 0
             % and the default bin boundaries are integration boundaries
            range = [range(1),range(3)];
        end
    end
end

% check if number of expected bins < 1, so it is actually integration range
if numel(range) == 3 && range(3) - range(1) < range(2)
    range = [range(1),range(3)];
end

% check validity of data ranges
if range(end) < range(1) && ~(numel(range) == 3 && range(2) < 0)
    error('HORACE:AxesBlockBase:invalid_argument',...
          'Upper limit (%f) smaller then the lower limit (%f) for positive step - check axis N: %d', ...
          range(end), range(1), ind);
end

end

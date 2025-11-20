function  new_axes_block = build_from_input_binning(...
    axes_class_or_name,cur_img_range_and_steps,pbin)
% Build new AxesBlockBase object from the binning parameters, provided
% as input. If some input binning parameters are missing, the
% defaults are taken from the existing AxesBlockBase object.
%
% if the target range defined by binning exceeds the existing image range
% (in the target coordinate system), the existing image range is selected
%
% NOTE: the binning parameters is the cellarray of 1,2 or 3 element vectors
%       with meaning described by cut_sqw or cut_dnd inputs. See below for 
%       more details.
%
% Inputs:
% axes_class_or_name -- name of the axes block class to build or empty
%                       instance of this class
% cur_img_range_and_steps
%          --   1x4-elements cellarray of the ranges and steps of source
%               image, expressed in the target coordinate system (the system
%               the new axes block is build for) and used as source of
%               default ranges. May be empty (cell(1,4)). In this case,
%               all ranges provided as the next argument have to be defined
%               explicitly.
%               if these ranges are not specified by pbin
% pbin     --   1x4-elements cellarray of input binning parameters, which define
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

if isa(axes_class_or_name,'AxesBlockBase')
    new_axes_block = axes_class_or_name;
else
    new_axes_block = feval(axes_class_or_name);
end
data_range = new_axes_block.get_img_range_from_cut_range(cur_img_range_and_steps{:});        
% Check values are acceptable, and make ranges (3+2)x1 (for plot) or (2+2)x1 for integration axes
% ---------------------------------------------------------------------------------------
targ_img_range = cellfun(@(i,bin_rec,bin_def)parse_pbin(i,bin_rec,data_range,bin_def),...
    ind,pbin,cur_img_range_and_steps,'UniformOutput',false);

new_axes_block = new_axes_block.init(targ_img_range{:});

end

function bin_range = parse_pbin(ind,bin_req,data_range,bin_default)
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
        bin_range = bin_default;
    case 1 % Rebin
        if bin_req == 0
            if numel(bin_default) == 2 % this may fail if bin_default is integration axis
                error('HORACE:build_from_input_binning:invalid_argument', ...
                    'User has requested auto-rebin (pbin = [0]) across integration axis (%d).', ind);
            end
            bin_req = bin_default(2);
        end
        bin_range = [bin_default(1),bin_req,bin_default(end)];

    case 2 % Integration
        bin_range = bin_req;
        if isinf(bin_range(1))        
           bin_range(1) = data_range(1,ind);
        end
        if isinf(bin_range(end))
           bin_range(2) = data_range(2,ind);            
        end

        border = abs(SQWDnDBase.border_size);
        % we need correct integration range for cut to work but some old file
        if abs(bin_range(2)-bin_range(1))<2*border  % formats do not store proper
            % img_range and store [centerpoint, centerpoint] for
            % integration ranges. Here we try to mitigate this.
            av_pt = 0.5*(bin_range(1)+bin_range(2));
            if abs(av_pt) < border
                bin_range(1) = -border;
                bin_range(2) =  border;
            else
                bin_range(1) = av_pt*(1 - border);
                bin_range(2) = av_pt*(1 + border);
            end
        end
    case 3 % viewing axis
        bin_range = bin_req;
        step = bin_req(2);
        if step == 0
            if numel(bin_default)==2  % integrate in ranges, defined by default bin boundaries if step is 0
                % and the default bin boundaries are integration boundaries
                bin_range = [bin_range(1),bin_range(3)];                
            else %3
                bin_range(2) = bin_default(2);
                step = bin_range(2);
            end
        end
        if isinf(bin_range(1))
            bin_range(1) = data_range(1,ind)+0.5*step;
        end
        if isinf(bin_range(end))
            bin_range(end) = data_range(2,ind)-0.5*step;            
        end
    otherwise
        error('HORACE:AxesBlockBase:invalid_argument',[ ...
            '*** Binning arguments can be provided in four possible forms:\n' ...
            '    []            -- use existing binning or integration ranges;\n' ...
            '    step          -- provide specific binning step;\n' ...
            '    [min,max]     -- integrate between min and max values;\n' ...
            '    [min,step,max]-- do binning withing min-max ranges with step provided\n' ...
            '*** Input does not belong to any of these, contains %d elements and is: %s'], ...
            numel(bin_req),disp2str(bin_req));
end

% check if number of expected bins < 1, so it is actually integration range
if numel(bin_range) == 3 && bin_range(3) - bin_range(1) < bin_range(2)
    bin_range = [bin_range(1),bin_range(3)];
end

% check validity of data ranges
if bin_range(end) < bin_range(1) && ~(numel(bin_range) == 3 && bin_range(2) < 0)
    error('HORACE:AxesBlockBase:invalid_argument',...
        'Upper limit (%f) smaller then the lower limit (%f) for positive step - check axis N: %d', ...
        bin_range(end), bin_range(1), ind);
end

end

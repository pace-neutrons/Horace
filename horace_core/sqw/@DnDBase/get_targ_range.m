function the_range = get_targ_range(obj,targ_proj,varargin)
%GET_TARG_RANGE calculate the full range of the image to be produced by target
% projection from the current image,
%
% Inputs:
% obj        -- dnd object - source of image ranges to process
% targ_proj  -- aProjectionBase class which defines target coordinate
%               system where the range should be identified.
% Optional:
%  ranges_requested
%            -- four element logical array, where true states the requested
%               range to identify. This is used for identifying the ranges
%               of orthogonal dimensions (i.e. dE so that if only
%
% '-binning' if present, the method returns range as cellarray of binning
%            parameters, i.e. the parameters which you would provide to cut
%            to get the target cut in the ranges produced
% Output:
% range     -- 2x4 element array of min-max ranges, the ranges of the input
%              object will occupy in the target coordinate system.
%              if "-binning" is requested, this range is transformed into 4
%              element cellarray, where each cell contains binning
%              parameters in the form which provides initial binning range
%
%             when range_requested for an element of binning range is
%             false, the range for this element is [-inf;inf] or corresponding
%             cell in "-binning" mode is empty.
%
%
[ok,mess,do_binning_range,argi] = parse_char_options(varargin,'-binning');
if ~ok
    error('HORACE:DnDBase:invalid_argument',mess);
end
if isempty(argi)
    ranges_requested = true(1,4);
else
    ranges_requested = logical(argi{1});
    if numel(ranges_requested) ~= 4
        error('HORACE:DnDBase:invalid_argument',...
            'Requested range array needs to 4 elements. Actually, its size is :%s',...
            disp2str(size(range_requested)));
    end
end
source_proj = obj.proj;
the_range   = obj.axes.get_targ_range(source_proj,targ_proj,ranges_requested);
if do_binning_range
    nsteps = obj.axes.nbins_all_dims;
    the_range  = arrayfun(@build_binning,the_range(1,:),the_range(2,:),nsteps,'UniformOutput',false);
end


function bin_range = build_binning(min_range,max_range,nsteps)
% simple procedure to convert img_range into binning parameters
if isinf(min_range)
    bin_range = [];
    return;
end

if nsteps == 1% integration range
    bin_range = [min_range,max_range];
    return
end
step = (max_range-min_range)/(nsteps);
% axis binning parameters
bin_range = [min_range+step/2,step,max_range-step/2];


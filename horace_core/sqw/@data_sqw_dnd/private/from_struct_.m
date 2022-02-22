function  obj = from_struct_(obj,input)
% set up sqw_dnd_data object from the input structure,
%
% maintaining changes in structure according to version.
%

if ~isfield(input,'version')
    if isfield(input,'urange')
        % urange contents in new file types is unreliable
        if isfield(input,'pix') && isa(input.pix,'PixelData')
            input.pix_range = input.pix.pix_range;
        else
            % no info, keep pix range undefined
            input.pix_range = PixelData.EMPTY_RANGE_;
        end
        input = rmfield(input,'urange');
        input.img_db_range = dnd_binfile_common.calc_img_db_range(input);
    end
elseif input.version == 1
    input = rmfield(input,'version');
end
if isfield(input,'pix_range')
    obj.pix.set_range(input.pix_range)
    input = rmfield(input,'pix_range');
end
if isfield(input,'img_range')
    input.img_db_range = input.img_range;
    input = rmfield(input,'img_range');
end


%
flds = fieldnames(input);
for i=1:numel(flds )
    % if this struct has its origin in a dnd (particularly d2d)
    % then it will have acquired additional fields NUM_DIMS and data_
    % which do not translate into a data_sqw_dnd and are hence ignored
    % here. There may be a better method but this gets test_rebin_dnd_steps
    % working.
    if ~strcmp(flds(i), 'NUM_DIMS') && ~strcmp(flds(i), 'data_')
        obj.(flds{i}) = input.(flds{i});
    end
end

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
            % no info, need to use existing urange in hope its pix_range
            input.pix_range = input.urange;
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

%
flds = fieldnames(input);
for i=1:numel(flds )
    obj.(flds{i}) = input.(flds{i});
end

function [img_range,ldrs] = check_img_consistency(sqw_obj_input)
% CHECK_IMG_CONSISTENCY: Validates sqw images (dnd objects) consistency
% for the purpose of combining them together without rebinning.
%
% Input:
% sqw_obi_input -- array or cellarray of the sqw objects or cellarray of
%                  filenames containing such objects.
%
% Returns:
% ok           -- true if images are consistent and can be combined together
% mess         -- empty if ok, or message with details on inconsistency if
%                 ok is false
% img_range    -- img_range -- if images are consistent, common range of
%                 the images calculated to avoid round-off errors.
% ldrs         -- if inputs are filenames, list of loaders which load data
%                 from these files
%                 Empty, if inputs are sqw objects.
%
if isa(sqw_obj_input,'sqw') || isa(sqw_obj_input,'dnd')
    inputs = num2cell(sqw_obj_input);
else
    inputs = sqw_obj_input;
end
[img_metadata,filenames,ldrs] = cellfun(@extract_meta,inputs,'UniformOutput',false);

try
    img_range = check_img_consistency_(img_metadata,filenames);
catch ME
    close_lrds(ldrs);
    rethrow(ME)
end
if nargout < 2
    ldrs = close_lrds(ldrs);
end

function ldrs = close_lrds(ldrs)
% close loader handles in case of error
for i=1:numel(ldrs)
    if ~isempty(ldrs{i})
        ldrs{i} = ldrs{i}.delete();
        ldrs{i} = [];
    end
end

function [meta,fname,ldr] = extract_meta(in_obj)
% Extract metadata necessary for validating images consistency
% for combining.
ldr = [];
if isa(in_obj,'sqw')
    meta  = in_obj.data.metadata;
    fname = in_obj.full_filename;
elseif isa(in_obj,'DnDBase')
    meta = in_obj.metadata;
    fname = in_obj.full_filename;
elseif istext(in_obj)
    fname = in_obj;
    ldr = sqw_formats_factory.instance().get_loader(fname);
    meta = ldr.get_dnd_metadata();
else
    error('HORACE:algorithms:invalid_argument', ...
        'class: %s of object %s does not supported', ...
        class(in_obj),disp2str(in_obj));
end
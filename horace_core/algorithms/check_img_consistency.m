function [ok,mess,img_range] = check_img_consistency(sqw_obj_input,throw_on_inconsistent)
% CHECK_IMG_CONSISTENCY: Validates sqw images consistencey for the puropose
% of combining them together.
%
% Input:
% sqw_obi_input -- array or cellarray of the sqw objects or cellarray of
%                  filenames containing such objects.
% Optional:
% throw_on_inconsistent
%               -- if true, throw HORACE:algorithms:invalid_argument
%                  instead of returing error message
%
% Returns:
% ok           -- true if images are consistent and can be combined together
% mess         -- empty if ok, or message with details on inconsistency if
%                 ok is false
% img_range    -- img_range -- if images are consistent, common range of
%                 the images calculated to avoid round-off errors.
%
if nargin<2
    throw_on_inconsistent = false;
end
if isa(sqw_obj_input,'sqw') || isa(sqw_obj_input,'dnd')
    inputs = num2cell(sqw_obj_input);
else
    inputs = sqw_obj_input;
end
[img_metadata,filenames] = cellfun(@extract_meta,inputs,'UniformOutput',false);

ok = true;
mess = false;
img_range = [];
if throw_on_inconsistent
    img_range = check_img_consistency_(img_metadata,filenames);
else
    try
        img_range = check_img_consistency_(img_metadata,filenames);
    catch ME
        if strcmp(ME.identifier,'HORACE:algorithms:invalid_arguments')
            ok = false;
            mess = ME.message;
        else
            rethrow(ME)
        end
    end
end


function [meta,fname] = extract_meta(in_obj)
% Extract metadata necessary for validating images consistency
% for combining.
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
    ldr.delete();
else
    error('HORACE:algorithms:invalid_argument', ...
        'class: %s of object %s does not supported', ...
        class(in_obj),disp2str(in_obj));
end
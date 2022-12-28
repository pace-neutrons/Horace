function obj = put_dnd_metadata(obj,varargin)
%PUT_DND_METADATA store information, describing dnd image
% Inputs:
% obj      -- the instance of the faccessor object, initialized for writing
%             dnd metadata.
%
% Optional::- the information, necessary for initializing or re-initializing 
%             faccessor for writing dnd metadata, namely:
% sqw/dnd object or dnd_metadata subobject
%          -- the object to extract subobject for writing or the subobject
%             itself
% filename -- full name of the file to write dnd metadata into.

if ~isempty(varargin)
    is_sqw_dnd = cellfun(@(x)(isa(x,'SQWDnDBase')||is_sqw_struct(x)),varargin);
    if any(is_sqw_dnd)
         sqw_ind = find(is_sqw_dnd);
         if isa(varargin{sqw_ind},'sqw')
             varargin{sqw_ind} = varargin{sqw_ind}.data;
         end
         varargin{sqw_ind} = check_and_set_date(varargin{sqw_ind});
    end
else
     sqh = obj.sqw_holder;
     obj.sqw_holder_ = check_and_set_date(sqh);
end

% store appropriate data block
obj = put_dnd_block_(obj, ...
     faccess_dnd_v4.dnd_blocks_list_{1},varargin{:});


function dnd_obj = check_and_set_date(dnd_obj)
if ~dnd_obj.creation_date_defined
    dnd_obj.creation_date = datetime('now');
end


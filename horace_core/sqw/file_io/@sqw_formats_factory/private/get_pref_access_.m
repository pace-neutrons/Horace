function loader = get_pref_access_(obj,varargin)
% Returns the version of the accessor recommended to use for writing sqw files
% by default or accessor necessary for writing the particular class provided as
% input.
%
%Usage:
%>>loader = sqw_formats_factory.instance().get_pref_access();
%           -- returns default accessor suitable for most files.
%>>loader = sqw_formats_factory.instance().get_pref_access('dnd')
% or
%>>loader = sqw_formats_factory.instance().get_pref_access('sqw')
%         -- returns preferred accessor for dnd or sqw object
%            correspondingly
%
%>>loader = sqw_formats_factory.instance().get_pref_access(object)
%         -- returns preferred accessor for the object of type
%             provided, where allowed types are sqw,dnd,d0d,d1d,d2d,d3d,d4d.
%
%            Throws 'SQW_FILE_IO:invalid_argument' if the type
%            is not among the types specified above.
%
if nargin <2
    % When it is completed, return most functional accessor.
    loader = obj.supported_accessors_{obj.preferred_accessor_num_};
    return
end
if ischar(varargin{1})
    the_type = varargin{1};
else
    [the_type,orig_type] = sqw_formats_factory.get_sqw_type(varargin{1});
    if strcmp(the_type,'none') % assume sqw
        the_type = orig_type;
    end
end
if obj.types_map_.isKey(the_type)
    ld_num = obj.types_map_(the_type);
    loader = obj.supported_accessors_{ld_num};
else
    error('HORACE:file_io:invalid_argument',...
        'get_pref_access: input class %s does not have registered accessor',...
        the_type)
end

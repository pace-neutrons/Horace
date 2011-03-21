function arglist_out = parse_arguments_arglist_defaults(arglist,flags,arglist_def)
% Update the fields of a structure with those fields that also appear in a default structure
%
%   >> arglist_out = parse_arguments_arglist_update(arglist,flags,arglist_def)
%
%   arglist       Structure containing keyword arguments and values
%                 If field is empty, then this is deemed to be replaceable
%                by the value in arglist_def, if present.
%
%   flags         Cell array of those fields of arglist which are logical flags
%                This will be used to set any empty flag fields to false.
%
%   arglist_def   Structure with default values for arglist. Any fields that
%                are not in arglist are ignored.
%
%   arglist_out   Output arglist
% 
%
% Notes:
%  - if a field of arglist is empty and the field also appears in arglist_def, then
%    the copying of the value in arglist_def takes place even if the field is empty
%    in arglist_def. This means that the type can change from e.g. [] to '' or {}.
%
%  - Without the flags argument, we could not allow a flag field to be
%    replaced with the value from the default arglist and still
%    guarantee a logical value at the end of this routine)

arglist_out=arglist;

nam=fields(arglist_out);
nam_def=fields(arglist_def);
nam_cmn=str_common(nam,nam_def);

% Copy values from arglist_def where necessary
if ~isempty(nam_cmn)
    for i=1:numel(nam_cmn)
        if isempty(arglist_out.(nam_cmn{i}))
            arglist_out.(nam_cmn{i})=arglist_def.(nam_cmn{i});
        end
    end
end

% Set empty fields that are flags to false
if ~isempty(flags)
    for i=1:numel(flags)
        if isempty(arglist_out.(flags{i}))
            arglist_out.(flags{i})=false;
        elseif ~isscalar(arglist_out.(flags{i})) || ~(islogical(arglist_out.(flags{i})) || isnumeric(arglist_out.(flags{i})))
            error(['Default value for field ''',flags{i},''' is not, or cannot be converted to, a scalar logical'])
        end    
    end
end

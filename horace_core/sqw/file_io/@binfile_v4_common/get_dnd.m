function [dnd_obj,obj] = get_dnd(obj,varargin)
%GET_DND retrieve any sqw/dnd object as dnd object
%
% Read the data block from an sqw or dnd file and return the result as the
% data structure with fields, described below.
%
% The file pointer is left at the end of the data block.
%
%   >> data = obj.get_data()
%   >> data = obj.get_data(options)
%
% Optional: (different keys provided as input):
% ------
% '-hverbatim'   The file name as stored in the main_header and
%                data sections are returned as stored, not set
%                to be from the current file name.
% '-head'        Return only dnd_methadata, no data blocks retrieved
%                equivalent to get_dnd_metadata;
% '-verbatim'    do not modify filepath to the current file path, but
%                return it as it has been stored on hdd
% '-noclass'     Do not return dnd object but return the structure of the
%                correspondent object
%
% Output:
% -------
% dnd_obj  --   dnd object of appropriate dimensions
%       or  -   the structure of dnd object
%       or  -   dnd object metadata class
%       or  -   dnd object metadata structure
%

%
% Initialise output arguments
[ok,mess,header_only,verbatim,hverbatim,noclass,argi]=...
    parse_char_options(varargin, ...
    {'-head','-verbatim','-hverbatim','-noclass'});
if ~ok
    error('HORACE:binfile_v2_common:invalid_argument',...
        'get_data::Error: %s',mess);
end
header_only = header_only||hverbatim;
verbatim    = verbatim||hverbatim;

if ~isempty(argi)
    obj = obj.init(argi{:});
end

% --------------------------------------------------------------------------
% Read data
% --------------------------------------------------------------------------
% This first set of fields are required for all output options
% ------------------------------------------------------------
if ischar(obj.num_dim)|| isempty(obj.num_dim)
    error('HORACE:faccess_dnd_v4:runtime_error',...
        'get_data method called on un-initialized loader')
end

% get dnd object itself

[dnd_obj_meta,obj] = obj.get_dnd_metadata();
if header_only
    dnd_obj = dnd_obj_meta;
else
    [dnd_obj_data,obj] = obj.get_dnd_data();
    dnd_obj = DnDBase.dnd(dnd_obj_meta,dnd_obj_data);
end
%
if ~verbatim
    dnd_obj.filename = obj.filename;
    dnd_obj.filepath = obj.filepath;
end

if noclass
    dnd_struc = dnd_obj.to_bare_struct();
    dnd_struc.title = dnd_obj.title;
    dnd_struc.filename = dnd_obj.filename;
    dnd_struc.filepath = dnd_obj.filepath;
    dnd_obj = dnd_struc;
end
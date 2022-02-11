function varargout = cut(source, varargin)
%%CUT Take a cut from the given data source.
%
% Inputs:
% -------
% source     An `sqw` or `dnd` object or a path to a valid .sqw or .dnd file.
%
% For more help see sqw/cut.
%

if is_string(source)
    % Get a loader instance that can tell us what kind of file this is
    % We expect either a .sqw or .dnd file, throw an error otherwise.
    ldr = sqw_formats_factory.instance().get_loader(source);
    sqw_dnd_obj=obj_from_faccessor(ldr);
elseif isa(source,'dnd_file_interface')
    sqw_dnd_obj=obj_from_faccessor(source);
elseif isa(source, 'SQWDnDBase')
    sqw_dnd_obj = source;
else
    error('HORACE:cut:invalid_argument', ...
        ['Cannot take cut of object of class ''%s''.\n' ...
        'Argument ''source'' must be sqw, dnd or a valid file path.'], ...
        class(source));
end
if nargout > 0
    varargout{1} = cut(sqw_dnd_obj, varargin{:});
else
    cut(sqw_dnd_obj, varargin{:});
end

function sqw_dnd_obj=obj_from_faccessor(ldr)
% Get sqw/dnd object from appropriatly initialized file accessor
%
if ldr.sqw_type
    % harmonize pixel_page_size and mem_chunk_size
    [mem_chunk,page_size] = config_store.instance().get_config_field('hor_config',...
        'mem_chunk_size','pixel_page_size');
    pixel_page_size = mem_chunk*ldr.pixel_size;
    if page_size<pixel_page_size     % TODO:  this normally should happen in testing only
        pixel_page_size = page_size; % only one variable (mem_chunk or  page_size should
        % remain in a future)
    end
    % Load the .sqw file using the sqw constructor so that we can pass the
    % pixel_page_size argument to get an sqw with file-backed pixels.
    sqw_dnd_obj = sqw(ldr, 'pixel_page_size', pixel_page_size);
else
    % In contrast to the above case, we can use the loader to get the dnd
    % as no extra constructor arguments are required.
    sqw_dnd_obj = ldr.get_dnd();
    ldr.delete();
end


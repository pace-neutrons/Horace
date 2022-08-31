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
% Get sqw/dnd object from appropriately initialized file accessor
%
if ldr.sqw_type
    hc = hor_config;
    mem          = sys_memory();
    page_size    = hc.pixel_page_size;
    crit = min(0.3*mem,3*page_size); % TODO: is this rule well justified?
    % here we check and load data -- if they are small enough, they are
    % loaded in memory, but if large according to criteria, filebased
    % algorithm invoked
    if ldr.npixels*sqw_binfile_common.FILE_PIX_SIZE > crit
        % Load the .sqw file using the sqw constructor so that we can pass the
        % pixel_page_size argument to get an sqw with file-backed pixels.
        sqw_dnd_obj = sqw(ldr, 'pixel_page_size', mem_pix_page_size);
    else
        % load everything in memory
        sqw_dnd_obj = sqw(ldr);
    end
else
    % In contrast to the above case, we can use the loader to get the dnd
    % as no extra constructor arguments are required.
    sqw_dnd_obj = ldr.get_dnd();
    ldr.delete();
end


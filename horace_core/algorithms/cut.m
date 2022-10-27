function varargout = cut(source, varargin)
%%CUT Take a cut from arbitrary data source or cellarray of data sources
%
% Inputs:
% -------
% source     An `sqw` or `dnd` object or a path to a valid .sqw or .dnd file.
%            or array or cellarray of sqw/dnd objects
% Optional:
% '-sqw_only' -- if key is provided, throw if input is dnd object
% '-dnd_only' -- if key is present, throw if input contains sqw object
%
% For more help see sqw/cut.
%
opt = {'-dnd_only','-sqw_only','-cell_output'};
[ok,mess,dnd_only,sqw_only,cell_output,argi] = parse_char_options(varargin,opt);
if ~ok
    error('HORACE:cut:invalid_argument',mess);
end
if dnd_only && sqw_only
    error('HORACE:cut:invalid_argument','can not request only sqw cut and only dnd cut simultaneously');
end
[nout,argi] = parse_inputs(nargout,argi{:});

if iscell(source)
    nin = numel(source);
    if nout>1
        nin = nout;
    end
    out = cell(nin ,1);    
    for i=1:nin
        if nout == 0
            cut_single_obj(source{i},nout,1,dnd_only,sqw_only,argi{:});
        else
            out{i} = cut_single_obj(source{i},nout,1,dnd_only,sqw_only,argi{:});
        end
    end
    if nout ==1
        varargout{1} = pack_output_(out,cell_output);
    else
        for i=1:nout
            varargout{i} = out{i};
        end
    end
else
    if nout > 0
        varargout{1} = cut_single_obj(source,nout,1,dnd_only,sqw_only,argi{:});
    else
        cut_single_obj(source,nout,1,dnd_only,sqw_only,argi{:});
    end
end

function out = cut_single_obj(source,nout,n_object,dnd_only,sqw_only,varargin)
% cut single sqw/dnd object containing in the file or as first input

if is_string(source)
    % Get a loader instance that can tell us what kind of file this is
    % We expect either a .sqw or .dnd file, throw an error otherwise.
    ldr = sqw_formats_factory.instance().get_loader(source);
    sqw_dnd_obj=obj_from_faccessor(ldr,n_object,sqw_only,dnd_only);
elseif isa(source,'dnd_file_interface')
    sqw_dnd_obj=obj_from_faccessor(source,n_object,sqw_only,dnd_only);
elseif isa(source, 'SQWDnDBase')
    sqw_dnd_obj = source;
    if sqw_only || dnd_only
        if sqw_only && isa(sqw_dnd_obj,'DnDBase')
            error('HORACE:cut:invalid_argument', ...
                'Object N:%d cut from only sqw object requested but dnd object provided', ...
                n_object);
        end
        if dnd_only && isa(sqw_dnd_obj,'sqw')
            error('HORACE:cut:invalid_argument', ...
                'Object N:%d cut from only dnd object requested but sqw object provided', ...
                n_object);
        end

    end
else
    error('HORACE:cut:invalid_argument', ...
        ['Cannot take cut of object of class ''%s''.\n' ...
        'Argument ''source'' must be sqw, dnd or a valid file path.'], ...
        class(source));
end
if nout > 0
    out = cut(sqw_dnd_obj, varargin{:});
else
    cut(sqw_dnd_obj, varargin{:});
end


function sqw_dnd_obj=obj_from_faccessor(ldr,n_object,sqw_only,dnd_only)
% Get sqw/dnd object from appropriately initialized file accessor
%
if ldr.sqw_type
    if dnd_only
        ldr.delete();
        error('HORACE:cut:invalid_argument', ...
            'Object N%d file: %s at: %s.\n Cut from only dnd object requested but sqw object provided',...
            n_object,ldr.filename,ldr.filepath);
    end
    hc = hor_config;
    mem          = sys_memory();
    pix_page_size    = hc.pixel_page_size;
    crit = min(0.3*mem,3*pix_page_size); % TODO: is this rule well justified?
    % here we check and load data -- if they are small enough, they are
    % loaded in memory, but if large according to criteria, filebased
    % algorithm invoked
    if ldr.npixels*sqw_binfile_common.FILE_PIX_SIZE > crit
        % Load the .sqw file using the sqw constructor so that we can pass the
        % pixel_page_size argument to get an sqw with file-backed pixels.
        sqw_dnd_obj = sqw(ldr, 'pixel_page_size', pix_page_size);
    else
        % load everything in memory
        sqw_dnd_obj = sqw(ldr);
    end
else
    if sqw_only
        ldr.delete();        
        error('HORACE:cut:invalid_argument', ...
            'Object N%d file: %s at: %s.\n Cut from only sqw object requested but dnd object provided', ...
            n_object,ldr.filename,ldr.filepath);
    end

    % In contrast to the above case, we can use the loader to get the dnd
    % as no extra constructor arguments are required.
    sqw_dnd_obj = ldr.get_dnd();
    ldr.delete();
end


function [nout,argi]= parse_inputs(nout,varargin)

is_nout = cellfun(@(x)(ischar(x)||isstring(x))&&strcmpi(x,'nargout'),varargin);
if any(is_nout)
    nou = find(is_nout);
    nout_pos = nou+1;
    is_nout(nout_pos) = true;
    nout = varargin{nout_pos};
    argi = varargin(~is_nout);
    if ~(isnumeric(nout)&&isscalar(nout))
        error('HORACE:cut:invalid_argument', ...
            'Number of ouptput argument parameter should be numeric scalar. It is %s', ...
            disp2str(nout));
    end
else
    argi = varargin;
end

% persistent ip;
% if isempty(ip)
%     ip = inputParser();
%     ip.KeepUnmatched = true;
%     addParameter(ip,'nargout',nout,@(x)isnumeric(x)&&isscalar(x));
% end
%
% opt = parse(ip,varargin{:});
% nout = opt.nargout;
% argi = opt.Unmatched;

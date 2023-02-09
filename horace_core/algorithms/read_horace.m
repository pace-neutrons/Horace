function varargout = read_horace(files,varargin)
% Read sqw object from named file or an array of sqw objects from a cell array of file names
%
%   >> w=read_horace(file)   % read named file or cell array of file names
%                             into array of sqw objects or cellarray of sqw/dnd ojects
%Main options:
%   >> w=read_horace(file(s),'-get_dnd') --  read dnd parts of all (dnd and sqw) objects
%                                            only.
%   >> w=read_horace(file(s),'-force_sqw')-- fail if the input file
%                                            contains a dnd object.
%   >> w=read_horace(file(s),'-filebacked')-- force pixels data being
%                                             file-backed even if they fit
%                                             the memory

% Additional possible options are transferred to sqw or dnd loader directly
%
% Original author: T.G.Perring
%
% Read sqw/dnd object from a file or array of sqw/dnd objects from a set of files
%
%   >> w=read_horace(file)
%
% Output:
% -------
%   w           sqw/dnd object, or array of sqw/dnd objects if given cell array of
%               file names

% Original author: T.G.Perring
%
%

% Perform operations
% ------------------
% Check number of arguments
n_outputs = nargout;
if n_outputs > nargin
    error('HORACE:read_horace:invalid_argument',...
          'number of output objects requested is bigger then the number of input files provided')
end

[ok,mess,get_dnd,force_sqw,file_backed,filebacked,argi] = parse_char_options(varargin, ...
    {'-get_dnd','-force_sqw','-file_backed','-filebacked'});
if ~ok
    error('HORACE:read_horace:invalid_argument',...
          mess);
end
file_backed = filebacked||file_backed;

if get_dnd && force_sqw
    error('HORACE:read_horace:invalid_argument',...
          'only one option allowed i.e. -get_dnd and -force_sqw cannot be provided simultaneously');
end

if file_backed && ~get_dnd
    argi = [argi, 'file_backed', file_backed];
end

loaders = get_loaders(files);

n_inputs = numel(loaders);
if force_sqw
    is_not_sqw = ~cellfun(@(x) x.sqw_type, loaders);
    if any(is_not_sqw)
        bad_files = cellfun(@(x) fullfile(x.filepath,x.filename), ...
                            loaders(is_not_sqw), 'UniformOutput', false);
        error('HORACE:read_horace:invalid_argument',...
              'Files %s only contain dnd information but sqw file required.',...
              strjoin(bad_files, ', '));
    end
end

if n_outputs == 0 % do nothing but the check if all files present and
    return;       % are all sqw has been done
end

% Now read data
if get_dnd
    trez = cellfun(@(x) x.get_dnd(argi{:}), loaders, 'UniformOutput', false);
else
    trez = cellfun(@(x) x.get_sqw(argi{:}), loaders, 'UniformOutput', false);
end

varargout = pack_io_outputs(trez,n_inputs,n_outputs);

end

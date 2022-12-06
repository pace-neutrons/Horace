function cl=save(w, varargin)
% Save a sqw object or array of sqw objects to file
%
%   >> save (w)              % prompt for file
%   >> save (w, file)        % give file
%   >> save (w, file,loader) % save file using specific data loader
%                             (-update option, is provided, will be
%                             ignored)
%   >> save (w, file,['-parallel'|JobDispatcher])
%                             combine file using parallel algorithm.
%                             Useful and would works only if (when) pix
%                             value of sqw object data is set up to the
%                             instance of pix_combine_info class,
%                             containing information on the partial 
%                             tmp files, written by filebased gen_sqw or
%                             cut algorithm
% 
%   >> save (w, file,'-update') % if the target file exist, update it to
%                               latest format if this is possible. If
%                               update is possible, pixels in file will not be
%                               overwritten.
% Input:
%   w       sqw object
%   file    [optional] File for output. if none given, then prompted for a file
%
%   Note that if w is an array of sqw objects then file must be a cell
%   array of filenames of the same size.
%
% Optional output:
% cl -- running instance of parallel cluster, used to combine multiple tmp
%       files together if pix field of sqw object contains pix_combine_into
%       and -parallel option or parallel cluster itself are provided as
%       inpout. Empty in any other case
%
%      TODO: currently empty. May re-enable when parallel saving is
%      implemented properly

% Original author: T.G.Perring
%

cl = []; % parallel cluster used to combine and save 
[ok,mess,upgrade,argi] = parse_char_options(varargin,{'-update'});
if ~ok
    error('HORACE:SQWDnDBase:invalid_argument',mess);
end

% Use the concrete class name as file extension
file_ext = lower(class(w));

% Get file name - prompting if necessary
ldw = [];
if numel(argi)==0
    file_internal = putfile(['*.' file_ext]);
    if (isempty(file_internal))
        error ('HORACE:SQWDnDBase:invalid_argument',...
            'No file given to save result')
    end
elseif numel(argi)>1 
    if isa(argi{2},'horace_binfile_interface') % specific loader provided
        file_internal = argi{1};
        ldw  = argi{2};
        n_found = 2;
    else
        n_found = 1;
    end
    if numel(argi) > n_found % Matlab 2021b bug?
        argi  = argi{n_found+1:end};    
    else
        argi  = {};
    end
    
else
    [file_internal,mess]=putfile_horace(argi{1});
    if ~isempty(mess)
        error('HORACE:SQWDnDBase:invalid_argument',mess)
    end
    if numel(argi) > 1 % Matlab 2021b bug?
        argi  = argi{2:end};    
    else
        argi  = {};
    end
end
if ~iscellstr(file_internal)
    file_internal=cellstr(file_internal);
end
if numel(file_internal)~=numel(w)
    error('HORACE:SQWDnDBase:invalid_argument',...
        'Number of data objects in array does not match number of file names')
end

hor_log_level = ...
    config_store.instance().get_value('herbert_config','log_level');


for i=1:numel(w)
    if isempty(ldw)
        if isa(w(i), 'DnDBase') %
            sqw_type = false;
            ldw = sqw_formats_factory.instance().get_pref_access('dnd');
        else
            sqw_type = true;
            ldw = sqw_formats_factory.instance().get_pref_access(w(i));
        end
    else
        sqw_type = isa(w(i),'sqw');
    end

    % Write data to file   x
    if hor_log_level>0
        disp(['*** Writing to ',file_internal{i},'...'])
    end
    if ~upgrade && exist(file_internal{i},'file') == 2
        delete(file_internal{i});
    end
    ldw = ldw.init(w(i),file_internal{i});
    if ldw.upgrade_mode % as we delete file, this never happens. The question is where it should?
        if sqw_type
            ldw = ldw.put_sqw('-update','-nopix');
        else  %TODO:  OOP violation -- save dnd should be associated with dnd class
            ldw = ldw.put_dnd('-update','-nopix');
        end
    else
        if sqw_type   %TODO:  OOP violation -- save dnd should be associated with dnd class
            ldw = ldw.put_sqw(argi{:});
        else
            ldw = ldw.put_dnd();
        end
    end
    ldw = ldw.delete();
end

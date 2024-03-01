function obj = create_(varargin)
% Factory to construct a PixelData object from the given data. Default
% construction initialises the underlying data as an empty (9 x 0)
% array.
%
%   >> obj = PixelDataBase.create(ones(9, 200))
%
%   >> obj = PixelDataBase.create(200)  % initialise 200 pixels with underlying data set to zero
%
%   >> obj = PixelDataBase.create(full_filename)  % initialise pixel data from an sqw file
%
%   >> obj = PixelDataBase.create(faccess_reader)  % initialise pixel data from an sqw file reader
%
%
% Input:
% ------
%   init    A 9 x n matrix, where each row corresponds to a pixel and
%          the columns correspond to the following:
%             col 1: u1
%             col 2: u2
%             col 3: u3
%             col 4: dE
%             col 5: run_idx
%             col 6: detector_idx
%             col 7: energy_idx
%             col 8: signal
%             col 9: variance
%
%  init    An integer specifying the desired number of pixels. The underlying
%         data will be filled with zeros.
%
%  init    A path to an SQW file.
%
%  init    An instance of an sqw_binfile_common file reader.
% Options:
%  '-filebacked' -- if present, request filebacked data (does
%                   not work currently work with array of data)
%  '-upgrade'    -- if present, alow write access to filebased
%  '-writable'      data (properties are synonimous)
%  '-norange'    -- if present, do not calculate the range of
%                   pix data if this range is missing. Should
%                   be selected during file-format upgrade, as
%                   the range calculations are performed in
%                   create procedure.

if nargin == 0
    obj = PixelDataMemory();
    return
end

[ok,mess,file_backed_requested,file_backed,upgrade,writable,norange,...
    argi] = parse_char_options(varargin, ...
    {'-filebacked','-file_backed','-upgrade','-writable','-norange'});
if ~ok
    error('HORACE:PixelDataBase:invalid_argument',mess);
end

file_backed_requested = file_backed_requested || file_backed;
upgrade = upgrade || writable;

if numel(argi) > 1 % build from metadata/data properties
    is_md = cellfun(@(x)isa(x,'pix_data'),argi);
    if any(is_md)
        pxd = argi{is_md};
        if ischar(pxd.data) || file_backed_requested
            obj = PixelDataFileBacked(argi{:}, upgrade,norange);
        else
            obj = PixelDataMemory(argi{:}, upgrade);
        end
    else
        error('HORACE:PixelDataBase:invalid_argument', ...
            'Some input parameters (%s)  of the PixelDataBase.create operation are not recognized', ...
            disp2str(argi));
    end
    return;
else
    init = argi{1};
end

if isstruct(init)
    % In memory construction
    obj = PixelDataBase.loadobj(init);

elseif isa(init, 'PixelDataMemory')
    % In memory construction
    if file_backed_requested
        obj = PixelDataFileBacked(init, upgrade,norange);
    else
        obj = PixelDataMemory(init);
    end

elseif isa(init, 'PixelDataFileBacked')
    % if the file exists we can create a file-backed instance
    if file_backed_requested
        obj = PixelDataFileBacked(init, upgrade,norange);
    else
        obj = PixelDataMemory(init);
    end

elseif numel(init) == 1 && isnumeric(init) && floor(init) == init
    % input is an integer
    obj = PixelDataMemory(init);

elseif isnumeric(init)
    % Input is data array
    obj = PixelDataMemory(init);

elseif istext(init) || isa(init, 'sqw_file_interface')
    % File-backed or loader construction
    if istext(init)
        % input is a file path
        init = sqw_formats_factory.instance().get_loader(init);
    end

    if PixelDataBase.do_filebacked(init.npixels) || file_backed_requested
        obj = PixelDataFileBacked(init, upgrade,norange);
    else
        obj = PixelDataMemory(init);
    end
else
    error('HORACE:PixelDataBase:invalid_argument', ...
        'Cannot create a PixelData object from class (%s)', ...
        class(init))
end
end

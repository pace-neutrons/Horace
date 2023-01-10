function obj = loadobj_(S)
% Load a PixelData object from a .mat file
%
%>> obj = PixelDataBase.loadobj(S)
% Input:
% ------
%   S       A data, produeced by saveobj operation and stored
%           in .mat file
% Output:
% -------
%   obj     An instance of PixelData object or array of objects
%
if isstruct(S)

    if isfield(S,'version')
        % load PixelData objects, written when saveobj method was
        % written
        switch S.version
          case 1
            if isfield(S,'array_data') % multidimensional array of pixel data
                S = S.array_data;
                obj = arrayfun(@(x) PixelDataBase.create(), S);
                for i=1:numel(S)
                    obj(i).set_data('all',S(i).data);
                    obj(i).set_range(S(i).pix_range);
                    obj(i).file_path = S(i).file_path;
                end
            elseif isfield(S, 'data') % Single object
                obj = PixelDataBase.create();
                obj.set_data('all',S.data);
                obj.set_range(S.pix_range);
                obj.file_path = S.file_path;
            else
                error('HORACE:PixelData:invalid_argument',...
                      'Unknown PixelData input structure, missing data or array_data');
            end

          otherwise
            error('HORACE:PixelData:invalid_argument',...
                  'Unknown PixelData input structure version (%d)', S.version);
        end

    else % previous version(s), written without version info
        if isfield(S,'data_')
            obj = arrayfun(@(x) PixelDataBase.create(x.data_), S);

        elseif isfield(S,'raw_data_')
            obj = arrayfun(@(x) PixelDataBase.create(x.raw_data_), S);
            for i=1:numel(S)
                if isfield(S(i),'pix_range_')
                    obj(i).set_range(S(i).pix_range_);
                else
                    obj(i).reset_changed_coord_range('coordinates');
                end

                obj(i).file_path = S(i).file_path_;
            end
        else
            error('HORACE:PixelData:invalid_argument',...
                'Unknown PixelData input structire version');
        end
    end
else
    if isempty(S.page_memory_size_)
        % This if statement allows us to load old PixelData objects that
        % were saved in .mat files that do not have the 'page_memory_size_'
        % property
        S.page_memory_size_ = PixelDataBase.DEFAULT_PAGE_SIZE;
    end
    obj = PixelDataBase.create(S);
end

function obj = loadobj_(S)
% Load a PixelData object from a .mat file
%
%>> obj = PixelData.loadobj(S)
% Input:
% ------
%   S       A data, produeced by saveobj operation and stored
%           in .mat file
% Output:
% -------
%   obj     An instance of PixelData object or array of objects
%
if isstruct(S)
    obj = PixelData();
    if isfield(S,'version')
        % load PixelData objects, written when saveobj method was
        % written
        if S.version == 1
            if isfield(S,'array_data') % multidimensional array of pixel data
                S = S.array_data;
                obj = repmat(obj,size(S));                
                for i=1:numel(S)
                    if i>1 % cloning handle object as repmat makes the handles
                        %    identical
                        obj(i) = PixelData();
                    end
                    obj(i).set_data('all',S(i).data);
                    obj(i).set_range(S(i).pix_range);
                    obj(i).file_path_ = S(i).file_path;
                end
            else % Single object
                obj.set_data('all',S.data);
                obj.set_range(S.pix_range);
                obj.file_path_ = S.file_path;
            end
        else
            error('HORACE:PixelData:invalid_argument',...
                'Unknown PixelData input structire version');
        end
    else % previous version(s), written without version info
        if isfield(S,'data_')
            for i=1:numel(S)
                set_data(obj(i),'all',S(i).data_);
                obj(i).reset_changed_coord_range('coordinates')
            end
        elseif isfield(S,'raw_data_')
            for i=1:numel(S)
                obj(i).set_data('all',S(i).raw_data_);
                obj(i).set_range(S(i).pix_range_);
                obj(i).file_path_ = S(i).file_path_;
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
        S.page_memory_size_ = PixelData.DEFAULT_PAGE_SIZE;
    end
    obj = PixelData(S);
end

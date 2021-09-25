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
    if numel(S)> 1
        obj = repmat(obj,size(S));
    end
    if isfield(S,'version')
        % load PixelData objects, written when saveobj method was
        % written
        if S(1).version == 1
            for i=1:numel(S)
                if i>1 % cloning handle object as repmat makes the handles
                    %    identical
                    obj(i) = PixelData();
                end
                obj(i).set_data('all',S(i).data);
                obj(i).set_range(S(i).pix_range);
                obj(i).file_path_ = S(i).file_path;
            end
        else
            error('HORACE:PixelData:invalid_argument',...
                'Unknown PixelData input structire version');
        end
        if isfield(S,'shape')
            obj = reshape(obj,S(1).shape);
        end
    else % previous version(s), written without info
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

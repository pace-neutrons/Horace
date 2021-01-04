function  img_range = get_img_range_(obj,varargin)
% get [2x4] array of min/max ranges of the image contributing
% into an object
%
%
if nargin>1
    ds = varargin{1};
    if isfield(ds,'img_range')
        img_range = ds.img_range;
        return;
    end
end

fseek(obj.file_id_,obj.img_range_pos_,'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_BINILE_COMMON:io_error',...
          'Can not move to the urange start position, Reason: %s',mess);
end
img_range = fread(obj.file_id_,[2,4],'float32');



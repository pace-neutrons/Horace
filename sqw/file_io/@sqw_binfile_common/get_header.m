function  [header,pos]   = get_header(obj,varargin)
% Get header of one of the files, contributed into sqw file
%
% Usage:
%>>header = loader.get_header() % -- returns first sqw headrer
% or
%>>header = loader.get_header(n_header) % returns header number n_header
%
% pos -- service information
%     Equal to the location of the last + 1 byte of the header's data in
%     the bytes array, where the first byte of the header's data has number
%     1.
%
% Throws if the loader was not initialized properly or n_header is not
% correct || non-existing header number
%
%
if ischar(obj.num_contrib_files)
    error('SQW_FILE_INTERFACE:runtime_error',...
        ' get_header called on un-initialized loader')
end

if nargin==1
    n_header = 1;
else
    n_header = varargin{1};
end

if n_header<1 || (n_header>obj.num_contrib_files)
    error('SQW_FILE_INTERFACE:invalid_argument',...
        ' wrong number of header requested : %d, Avalible numbers are 1-%d',...
        n_header,n_header>obj.num_contrib_files);
end


if n_header == obj.num_contrib_files
    sz = obj.detpar_pos_ - obj.header_pos_(n_header);
else
    sz = obj.header_pos_(n_header+1) - obj.header_pos_(n_header);
end
%
fseek(obj.file_id_,obj.header_pos_(n_header),'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'can not move at the start of header N%d, readon: %s',n_header,mess);
end
%
bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~=0
    error('SQW_FILE_INTERFACE:runtime_error',...
        'Can not read header N%d data; error: %s',n_header,mess);
end


header_format = obj.get_header_form();
[header,pos] = obj.sqw_serializer_.deserialize_bytes(bytes,header_format,1);
if obj.convert_to_double
    header = obj.do_convert_to_double(header);
end
%TODO: sucks. Should it be implemented within formatters themselves? 
for i=1:numel(header)
    if size(header(i).en,1)==1
        header(i).en = header(i).en';
    end
end


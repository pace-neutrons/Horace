function  [exp_info,pos]   = get_header(obj,varargin)
% Get header of one of the files, contributed into sqw file
%
% Usage:
%>>header = loader.get_header() % -- returns sqw headers
% or
%>>header = loader.get_header(n_header) % returns header number n_header
%
% pos -- service information
%     Equal to the location of the last + 1 byte of the header's data in
%     the bytes array, where the first byte of the header's data has number
%     1.
%
% runid_map -- the map, connecting run_id with the header number
%
% Throws if the loader was not initialized properly or n_header is not
% correct || non-existing header number
%
%
%
% always verbatim
[ok,mess,get_all,~,argi]= parse_char_options(varargin,{'-all','-verbatim'});
if ~ok
    error('HORACE:sqw_binfile_common:invalid_argument',mess);
end
% remove unnecessary keywords, which may be relevant to other versions of
% the sqw file format
prop_keys =  cellfun(@(x)strncmp('-',x,1),varargin);
if any(prop_keys)
    argi = varargin(~prop_keys);
end


%
if ischar(obj.num_contrib_files)
    error('HORACE:sqw_binfile_common:runtime_error',...
        ' get_header called on un-initialized loader')
end

if isempty(argi)
    n_header = 1;
else
    n_header = argi{1};
    if ~isnumeric(n_header)
        error('HORACE:sqw_binfile_common:invalid_argument',...
            'get_header do not understand input argument: %s',n_header);
    end

end

if n_header<1 || (n_header>obj.num_contrib_files)
    error('HORACE:sqw_binfile_common:invalid_argument',...
        ' wrong number of header requested : %d, Available numbers are 1-%d',...
        n_header,n_header>obj.num_contrib_files);
end

if get_all && obj.num_contrib_files > 1
    header = cell(obj.num_contrib_files,1);
    for i=1:obj.num_contrib_files
        [header{i},pos] = get_single_header(obj,i);
    end
else
    [header,pos] = get_single_header(obj,n_header);
end
%
exp_info = Experiment.build_from_binfile_headers(header);



function [head,pos] = get_single_header(obj,n_header)
% get single sqw v2 header
if n_header == obj.num_contrib_files
    sz = obj.detpar_pos_ - obj.header_pos_(n_header);
else
    sz = obj.header_pos_(n_header+1) - obj.header_pos_(n_header);
end

try
    do_fseek(obj.file_id_,obj.header_pos_(n_header),'bof');
catch ME
    exc = MException('HORACE:sqw_binfile_common:runtime_error',...
                     'get_single_header: can not move at the start of header N%d',n_header);
    throw(exc.addCause(ME))
end

bytes = fread(obj.file_id_,sz,'*uint8');
[mess,res] = ferror(obj.file_id_);
if res ~=0
    error('HORACE:sqw_binfile_common:runtime_error',...
        'get_single_header: Can not read header N%d data; error: %s',n_header,mess);
end


header_format = obj.get_header_form();
[head,pos] = obj.sqw_serializer_.deserialize_bytes(bytes,header_format,1);
if obj.convert_to_double
    head = obj.do_convert_to_double(head);
end

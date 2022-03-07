function  [exp_info,pos,runid_map]   = get_header(obj,varargin)
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

%TODO: en conversion sucks. Should  be implemented within formatters
%themselves!
n_header = numel(header);
runids = zeros(n_header,1);
for i=1:n_header
    if iscell(header)
        header{i}.instruments = IX_null_inst(); %struct(); % this is necessary
        header{i}.samples = IX_null_sample(); %struct();      % to satisfy current interface
        if size(header{i}.en,1)==1
            header{i}.en = header{i}.en';
        end
        runids(i) = rundata.extract_id_from_filename(header{i}.filename);
    else
        if size(header(i).en,1)==1
            header(i).en = header(i).en';
        end
        header(i).instruments = IX_null_inst(); %struct();
        header(i).samples = IX_null_sample(); %struct();
        runids(i) = rundata.extract_id_from_filename(header(i).filename);
    end
    %
end
%
header_numbers = 1:numel(header);
if any(isnan(runids)) % this also had been done in gen_sqw;
    % rundata_write_to_sqw_ procedure in gen_sqw_files job.
    % It have setup update_runlabels to true, which also made
    % duplicated headers unique
    runids = header_numbers;
end

runid_map = containers.Map(runids,header_numbers);
exp_info = Experiment(header);


function [head,pos] = get_single_header(obj,n_header)
% get single sqw v2 header
if n_header == obj.num_contrib_files
    sz = obj.detpar_pos_ - obj.header_pos_(n_header);
else
    sz = obj.header_pos_(n_header+1) - obj.header_pos_(n_header);
end
%
fseek(obj.file_id_,obj.header_pos_(n_header),'bof');
[mess,res] = ferror(obj.file_id_);
if res ~= 0
    error('HORACE:sqw_binfile_common:runtime_error',...
        'get_single_header: can not move at the start of header N%d, reason: %s',n_header,mess);
end
%
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

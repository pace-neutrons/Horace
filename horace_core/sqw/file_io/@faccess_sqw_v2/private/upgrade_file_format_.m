function  new_obj = upgrade_file_format_(obj)
% Upgrade file from format 3 to the preferred file format
%
% currently preferred is format v 3.3
%
%
%
%
%

new_obj = sqw_formats_factory.instance().get_pref_access();
if ischar(obj.num_dim) % source object is not initiated. Just return
    return
end

[new_obj,missing] = new_obj.copy_contents(obj);
if isempty(missing) % source and target are the same class. Invoke copy constructor only
    return;
end
[~,acc] = fopen(obj.file_id_);
if ~ismember(acc,{'wb+','rb+'})
    clear new_obj.file_closer_;  % as file is closed on output of reopen to write
    new_obj = new_obj.fclose();  % in case the previous does not work, and if it does, makes no harm
    new_obj = new_obj.set_file_to_update();
end
%
% file format 3 specific part---------------------------------------------
clear_sqw_holder=false;
if isempty(new_obj.sqw_holder_) % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = make_pseudo_sqw(nf);
    % check pixel page size to deploy file-based operations if necessary
    % TODO: modify this to direct filebased algorithm when refactoring is
    % done.
    hc = hor_config;
    buf_size = hc.mem_page_chunk_size_byte_conversion;
    pix_page = hc.pixel_page_size;
    ll =       hc.log_level;
    if 2*buf_size < pix_page 
        clOb = onCleanup(@()set(hc,'pixel_page_size',pix_page));
        % set up pixel_page size of to be buf_size converted in bytes
        hc.mem_page_chunk_size_byte_conversion = hc.mem_chunk_size;
    end
    if ll>0
        fprintf('*** Upgrading file format to a latest binary version\n')
    end
    new_obj.sqw_holder_.data.pix = PixelData(obj,hc.mem_page_chunk_size_byte_conversion);
    clear_sqw_holder = true; %

end
new_obj = new_obj.init_v3_specific();
%
new_obj = new_obj.put_app_header();
new_obj = new_obj.put_instruments(); % this also upgrades (saves) sqw footer


if clear_sqw_holder
    new_obj.sqw_holder_ = [];
end


function sq = make_pseudo_sqw(nfiles)
% if header is a class, the issue would be much better
sq = sqw();
head = sqw_binfile_common.get_header_form();
head.emode = 1;
head.uoffset = zeros(4,1);
head.u_to_rlu = zeros(4,4);
head.ulen = ones(1,4);
head.ulabel = {'a','b','c','d'};
head.instruments = struct();
head.samples = struct();
head.alatt = [1,1,1];
head.angdeg = [90,90,90];
if nfiles>1
    heads = cell(1,nfiles);
    % matlab bug fixed in 2016b
    heads  = cellfun(@(x)gen_head(head,x),heads,'UniformOutput',false);
else
    heads = head;
end
heads = Experiment(heads);
sq = sq.change_header(heads);

function hd= gen_head(head,x)
hd = head;


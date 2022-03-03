function  new_obj = upgrade_file_format_(obj,pix_range)
% Upgrade file from format 3.2 to the preferred file format
%
% currently preferred is format v 3.21 for indirect instruments
%
if ~exist('pix_range','var')
    pix_range = [];
end


new_obj = sqw_formats_factory.instance().get_pref_access('sqw2');
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
%
if isempty(new_obj.sqw_holder_)
    
end

clear_sqw_holder = false;
if isempty(obj.sqw_holder_)
    clear_sqw_holder = true;
    % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = make_pseudo_sqw(nf);
    if isempty(pix_range)
        data = obj.get_data();
    else
        data = obj.get_data('-nopix');
        data.pix.set_range(pix_range);
    end
    new_obj.sqw_holder_.data = data;
    pix = data.pix;
else
    pix = obj.sqw_holder_.data.pix;
    if any(any(pix.pix_range == PixelData.EMPTY_RANGE_))
        pix.recalc_pix_range();
    end
end

new_obj.pix_range_ = pix.pix_range;
new_obj = new_obj.put_app_header();
new_obj = new_obj.put_sqw_footer();

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
if nfiles>1
    heads = cell(1,nfiles);
    % matlab bug fixed in 2016b
    heads  = cellfun(@(x)gen_head(head,x),heads,'UniformOutput',false);
else
    heads = head;
end
exp = Experiment(heads);
sq = sq.change_header(exp);
runid = zeros(numel(heads),1);
for i=1:numel(heads)
    if iscell(heads)
        runid(i) = rundata.extract_id_from_filename(heads{i}.filename);
    else
        runid(i) = rundata.extract_id_from_filename(heads(i).filename);
    end
end
ids = 1:numel(heads);
if any(isnan(runid))
    runid = ids;
end
sq.runid_map = runid;

function hd= gen_head(head,x)
hd = head;


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
    new_obj.file_closer_.delete();  % as file is closed on output of reopen to write
    new_obj = new_obj.set_file_to_update();
end
%
%

clear_sqw_holder = false;
if isempty(obj.sqw_holder_)
    clear_sqw_holder = true;
    % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with instrument and sample
    new_obj.sqw_holder_ = make_pseudo_sqw(nf);
    data = obj.get_data();
    pix = obj.get_pix();
    if ~isempty(pix_range)
        pix.set_range(pix_range);
    end
    new_obj.sqw_holder_.data = data;
    new_obj.sqw_holder_.pix = pix;

else
    pix = obj.sqw_holder_.pix;
    if any(any(pix.pix_range == PixelDataBase.EMPTY_RANGE_))
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
head.en = 1;
head.instruments = IX_null_inst();
head.samples = IX_samp('',ones(1,3),90*ones(1,3));
head.run_id = 1;
ids = 1:nfiles;
if nfiles>1
    ids = num2cell(ids);
    % matlab bug fixed in 2016b
    heads  = cellfun(@(x)gen_head(head,x),ids,'UniformOutput',false);
else
    heads = head;
end
exp_descr = IX_experiment(heads);

sq.experiment_info = Experiment([],head.instruments,head.samples,exp_descr);


function hd= gen_head(head,x)
hd = head;
hd.run_id = x;


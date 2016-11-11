function  new_obj = upgrade_file_format_(obj)
% Uprade file from format 2 to the preferred file format
%
% currently prefererd is format v 3
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
    new_obj = new_obj.reopen_to_write();
end
%
% file format 3 specific part---------------------------------------------
clear_sample_holder=false;
if isempty(new_obj.sqw_holder_) % all file positions except instrument and sample
    % are already defined so we need just nominal object with instrument and sample
    nf = new_obj.num_contrib_files();
    % make pseudo-sqw  with insturment and sample
    new_obj.sqw_holder_ = make_pseudo_sqw(nf);
    clear_sample_holder = true; %
end
new_obj = new_obj.init_v3_specific();
%
new_obj = new_obj.put_app_header();
new_obj = new_obj.put_instruments();

if clear_sample_holder
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
head.instrument = struct();
head.sample = struct();
if nfiles>1
    heads = cell(1,nfiles);
    heads  = cellfun(@()head,heads,'UniformOutput',false);
else
    heads = head;
end
sq.header = heads;

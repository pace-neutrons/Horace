function sq = make_pseudo_sqw_(nfiles)
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

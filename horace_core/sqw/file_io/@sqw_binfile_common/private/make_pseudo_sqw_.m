function sq = make_pseudo_sqw_(nfiles)
% if header is a class, the issue would be much better
sq = sqw();
head = IX_experiment();
if nfiles>1
    heads = cell(1,nfiles);
    % matlab bug fixed in 2016b
    heads  = cellfun(@(x)gen_head(head,x),heads,'UniformOutput',false);
    heads = [heads{:}];
else
    heads = head;
end

exper = Experiment();
exper.do_check_combo_arg = false; % avoid checking combo arguments for this sqw. 
% such sqw is invalid
exper.expdata = heads;
sq = sq.change_header(exper);


function hd= gen_head(head,x)
hd = head;

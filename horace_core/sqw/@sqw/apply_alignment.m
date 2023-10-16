function obj = apply_alignment(obj, outfile)
% If pixels are misaligned apply pixel alignment to all pixels and store
% result in modified file, if such file is provided.
%
% Optional Input:
% -----
% outfile   File to save the result of operation. If missed or empty, the
%           result will be stored in tmp file derived from the original
%           file
%
if nargin<2
    outfile = '';
end

if ~obj.is_misaligned
    if ~isempty(outfile)
        fp = fileparts(outfile);
        if isempty(fp)
            fp = pwd;
            outfile = fullfile(fp,outfile);
        end
        if ~strcmp(outfile,obj.full_filename)
            ll = config_store.instance().get_value('hor_config','log_level');
            obj = obj.deactivate();
            if obj.is_tmp_obj
                movefile(obj.full_filename,outfile,'f');
            else
                if ll>0
                    tb = tic;
                    fprintf('*** Copying aligned file %s to new file %s\n', ...
                        obj.full_filename,outfile);
                end
                copyfile(obj.full_filename,outfile);
                if ll>0
                    te  = toc(tb);
                    fprintf('*** Copying completed in %d sec', ...
                        te);
                end

            end
            obj = obj.activate(outfile);
        end
    end
    return;
end

pix_op = PageOp_recompute_bins();
%
pix_op.outfile = outfile;
pix_op.changes_pix_only_ = true;

pix_op = pix_op.init(obj);
obj    = obj.apply_c(obj,pix_op);

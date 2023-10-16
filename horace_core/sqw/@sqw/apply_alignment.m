function [targ_obj,al_info] = apply_alignment(obj, outfile)
% If pixels are misaligned apply pixel alignment to all pixels and store
% result in modified file, if such file is provided.
%
% Optional Input:
% -----
% outfile   File to save the result of operation. If missed or empty, the
%           result will be stored in tmp file derived from the original
%           file
% Output:
% obj      -- object containing realigned pixels
% al_info  -- if object was misaligned, return its alignment info
%
if nargin<2
    outfile = '';
end
targ_obj = copy(obj);
%
if ~targ_obj.pix.is_misaligned
    if ~isempty(outfile)
        fp = fileparts(outfile);
        if isempty(fp)
            fp = pwd;
            outfile = fullfile(fp,outfile);
        end
        if ~strcmp(outfile,targ_obj.full_filename)
            ll = config_store.instance().get_value('hor_config','log_level');
            % this will lock source object too, as source and target
            % are sharing the same handle and deactivation locks filehandle
            targ_obj = targ_obj.deactivate();
            if targ_obj.is_tmp_obj
                movefile(targ_obj.full_filename,outfile,'f');
            else
                if ll>0
                    tb = tic;
                    fprintf('*** Copying aligned file %s to new file %s\n', ...
                        targ_obj.full_filename,outfile);
                end
                copyfile(targ_obj.full_filename,outfile);
                if obj.is_tmp_obj
                    % unlock existing lock on source object
                    obj.set_as_tmp_obj();
                end
                if ll>0
                    te  = toc(tb);
                    fprintf('*** Copying completed in %d sec\n', ...
                        te);
                end

            end
            targ_obj = targ_obj.activate(outfile);
        end
    end
    al_info = [];
    return;
end
rotmat  = targ_obj.pix.alignment_matr;
rotvec  = rotmat_to_rotvec2(rotmat');
alatt   = targ_obj.data.proj.alatt;
angdeg  = targ_obj.data.proj.angdeg;
al_info = crystal_alignment_info(alatt,angdeg,rotvec);


pix_op = PageOp_recompute_bins();
%
pix_op.outfile = outfile;
pix_op.changes_pix_only = true;
pix_op.op_name = 'apply_alignment';

pix_op = pix_op.init(targ_obj);
targ_obj    = targ_obj.apply_c(pix_op);

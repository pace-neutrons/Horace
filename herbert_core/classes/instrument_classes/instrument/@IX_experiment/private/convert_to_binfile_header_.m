function old_hdr = convert_to_binfile_header_(obj,mode,arg1,arg2,nomangle)
% CONVERT_TO_BINFILE_HEADER_ Convert to the header structure,
% to be stored in the old binary files.
%
% Inputs:
% Required:
% obj   -- the experiment data header object to convert -
% mode  --
%    = '-inst_samp' : the next 2 arguments are an instrument
%                     and sample respectively
%    = '-alatt_angdeg' : the next 2 arguments are the alatt and
%                        angdeg values of the run respectively.
%                        In this case a null instrument and
%                        sample with these values are created
%                        and used.
% arg1  --
%    = instrument to set if mode == '-inst_samp'
%    = alatt -- lattice cell sizes (3x1 vector) if mode ==
%               '-alatt_angdeg'
% arg2  --
%    = sample to set if node == '-inst_samp'
%    = angdeg --lattice angles (3x1 vector) if mode ==
%               '-alatt_angdeg'
% nomangle -- if false or absent, mangle (append to the end)
%             file name with run_id (if one is defined)
%
% Outputs:
% old_hdr  -- struct with the old-style header data

old_hdr = obj.to_bare_struct();
if ~isnan(old_hdr.run_id) && ~nomangle
    old_hdr.filename = sprintf('%s$id$%d',old_hdr.filename,old_hdr.run_id);
end
old_hdr.uoffset = [0,0,0,0];
old_hdr.u_to_rlu = eye(4);
old_hdr.cu = old_hdr.u;
old_hdr.cv = old_hdr.v;
old_hdr = rmfield(old_hdr,{'run_id','u','v'});
if strcmp( mode, '-inst_samp')
    old_hdr.instrument = arg1;
    old_hdr.sample     = arg2;
    old_hdr.alatt      = arg2.alatt;
    old_hdr.angdeg     = arg2.angdeg;
elseif strcmp( mode, '-alatt_angdeg')
    old_hdr.instrument = IX_null_inst();
    old_hdr.sample     = IX_null_sample('',arg1,arg2);
    old_hdr.alatt      = arg1;
    old_hdr.angdeg     = arg2;
else
    error('HERBERT:IX_experiment:invalid_argument',...
        'mode arg is not "-inst_samp" or "-alatt_angdeg". It is: %s', ...
        disp2str(mode));
end

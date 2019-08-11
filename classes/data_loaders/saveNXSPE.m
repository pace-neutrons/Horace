function  saveNXSPE(nxspe_filename,data2save,varargin)
% Save data obtained from various data sources as nxspe file.
%
% Inputs:
% nxspe_filename - the name of the file to save nxspe data.
%                  If the file with this name exists, it will be
%                  overwritten.
%
% data2save      - is one of:
%          1)      the structure, containing the whole nxpse file
%                  information.
%                  This information can be obtained from e.g. mslice
%                  fromwindow command
%           2)     a fully formed rundata or runfatah
%                  class from Horace.
%
%                  If the information is incomplete, additional fields need
%                  to be provided.
%
if ~ischar(nxspe_filename)
    if iscell(nxspe_filename)
        for i=1:numel(nxspe_filename)
            if ~ischar(nxspe_filename)
                error('saveNXSPE:invalid_argument',...
                ' If first input is a cellarray, each element of cellarray must me a filename.')
            end
        end
    else
        error('saveNXSPE:invalid_argument',...
            'first input should be a filename to save nxspe to');
    end
end
if isa(data2save,'rundata') % just use existing
    data2save.saveNXSPE(nxspe_filename,'w');
    return
end
if ~isstruct(data2save)
    error('saveNXSPE:invalid_argument',...
        'second input should be a structure, containign dat to save as nxspe');
end
if isfield(data2save,'efixed') && isfield(data2save,'det_theta') ...
        && isfield(data2save,'emode')
    % that's "fromwindow" info from mslice. Process it
    rd = parce_fromwindow(data2save,nxspe_filename);
    rd.saveNXSPE(nxspe_filename,'w');
    return
end

error('saveNXSPE:not_implemented',...
    ' Advanced options on saveNXSPE are not yet implemented');



function rd = parce_fromwindow(data2save,nxspe_filename)
% the routine takes fromwindow mslice structure and converts it into
% rundata to save in nxspe file
tf = memfile();
tf.S=data2save.S';
tf.ERR=data2save.ERR';
tf.en = data2save.en;
tf.det_par = [ones(numel(data2save.det_theta),1),data2save.det_theta*(180/pi),...
    data2save.det_psi*(180/pi),data2save.det_dtheta,...
    data2save.det_dpsi,data2save.det_group]';
[~,fn] = fileparts(nxspe_filename);
tf.save(fn);
lat = oriented_lattice();
if isfield(data2save,'psi_samp')
    lat.psi = data2save.psi_samp*180/pi;
else
    lat.psi = NaN;
end

rd=rundata([fn,'.mem']);
rd.lattice = lat;
rd.efix = data2save.efixed;

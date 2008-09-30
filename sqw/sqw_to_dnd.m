function dnd = sqw_to_dnd (sqw)
% Create Horace style dnd object from sqw data structure
%
% See dnd_checkfields for the fields in a Horace dnd object.
% See write_sqw_main_header, write_sqw_header, write_sqw_detpar and write_sqw_data for fields of
% a sqw structure.
%
% Notes
% -----
% Recall that the header field is a cell array of headers if there is more than one
% contributing spe file; otherwise it is a structure. A cell array of length unity is NOT valid
%
% There are three flavours of sqw data structure, with closing fields
%  (1) s,e  [normalised by number of contributing pixels]
%  (2) s,e,n [s,e are unnormliased accumulated sums]
%  (3) s,e,npix,urange,pix [s,e are unnormliased accumulated sums]
%
% This routine will handle any of the input cases

% T.G.Perring   2 August 2007

ave = get_header_average(sqw.header);   % get average header information

dnd.file = sqw.main_header.filename;
dnd.grid ='orthogonal-grid';
dnd.title = sqw.main_header.title;
dnd.a = ave.alatt(1);
dnd.b = ave.alatt(2);
dnd.c = ave.alatt(3);
dnd.alpha = ave.angdeg(1);
dnd.beta  = ave.angdeg(2);
dnd.gamma = ave.angdeg(3);
dnd.u = sqw.data.u_to_rlu;
dnd.ulen = sqw.data.ulen;
dnd.label = sqw.data.ulabel;
dnd.p0 = sqw.data.uoffset;
dnd.pax = sqw.data.pax;
dnd.iax = sqw.data.iax;
dnd.uint = sqw.data.iint;
for i=1:length(sqw.data.pax)
    nam = ['p',int2str(i)];
    dnd.(nam) = sqw.data.p{i};
end
if isfield(sqw.data,'npix')
    dnd.s = sqw.data.s;
    dnd.e = sqw.data.e;
    if length(sqw.data.pax)<4
        dnd.n = sqw.data.npix;
    else
        dnd.n = int16(sqw.data.npix);
    end
else
    dnd.s = sqw.data.s;
    dnd.e = sqw.data.e;
    if length(sqw.data.pax)<4
        dnd.n = double(~isnan(sqw.data.s));
    else
        dnd.n = int16(~isnan(sqw.data.s));
    end
end
dnd=dnd_create(dnd);

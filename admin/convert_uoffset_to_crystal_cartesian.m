function convert_uoffset_to_crystal_cartesian(filename,varargin)
% Read uoffset, currently stored in sqw files, and convert this offset into
% crystal Cartesian system coordinate if the value, specified in the sqw
% file 
%
options = {'-convert_to_cc'};
[ok,mess,convert_to_cc] = parse_char_options(varargin,options);
if ~ok
    error('HORACE:admin:invalid_argument',mess);
end

ld = sqw_formats_factory.instance().get_loader(filename);
if ~ld.sqw_type
    error('HORACE:admin:invalid_argument',...
        'Only sqw files may need to change uoffset');
end
[dat,ld] = ld.get_data('-head');
fprintf('****************************************\n');
fprintf('**** Current uoffset: [%d, %d, %d, %d]     *\n',dat.uoffset);
fprintf('****************************************\n');
if ~convert_to_cc
    return
end
fprintf('**** Converting offset into Crystal Cartesian coordinates\n');
head = ld.get_exp_info();
head = header_average(head);
uoffset = head.u_to_rlu\dat.uoffset;
dat.uoffset = uoffset;
ld = ld.set_file_to_update();
ld.put_dnd_metadata(dat,'-update');
fprintf('**** finished                          *\n');
fprintf('****************************************\n');


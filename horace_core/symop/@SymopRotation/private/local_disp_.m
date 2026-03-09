function local_disp_(obj)
%LOCAL_DISP_ Display single rotation operator
if obj.input_nrmv_in_rlu
    units = '(rlu)';
else
    units = ' (cc)';
end
fprintf('Rotation operator:\n');

caxis = mat2str(obj.normvec,2);
coff = mat2str(obj.offset, 2);
len_ax = numel(caxis);  len_cof = numel(coff);
cu = mat2str(obj.u, 2);  cv = mat2str(obj.v, 2);
len_cu = numel(cu);  len_cv = numel(cv);
max_len1 = max(len_ax,len_cu );
max_len2 = max(len_cof,len_cv );
f11 = sprintf('       axis%s: %%%ds;',units, max_len1);
f12 = sprintf('     offset(rlu): %%%ds; ',max_len2);
f21 = sprintf(' In-plane u(rlu): %%%ds;', max_len1);
f22 = sprintf(' In-plane v(rlu): %%%ds;', max_len2);

fprintf([f11,f12,'angle(deg): %5.2f;\n'],caxis,coff, obj.theta_deg);
fprintf([f21,f22,'\n'],cu,cv);
end

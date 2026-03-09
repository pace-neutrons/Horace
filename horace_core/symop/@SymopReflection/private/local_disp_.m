function local_disp_(obj)
if obj.input_nrmv_in_rlu % call to public method to get correct
    % answer regardless of the actual coordinate system is set
    % up or not
    units = '(rlu)';
else
    units = ' (cc)';
end
fprintf('Reflection operator:\n');
cu = mat2str(obj.u, 2);  cof = mat2str(obj.offset, 2);
len_cu = numel(cu);  len_cof = numel(cof);
max_len = max(len_cu,len_cof);
f1 =sprintf(' In-plane u(rlu): %%%ds;',max_len);
f2 =sprintf('     offset(rlu): %%%ds; ',max_len);
fprintf(f1,cu);
fprintf(' In-plane v(rlu): %s\n',mat2str(obj.v, 2));
fprintf(f2,mat2str(obj.offset,2));
fprintf('  normvec %s: %s\n',units,mat2str(obj.normvec, 2));
end
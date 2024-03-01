a=unique_fields_example_class(IX_inst('name','333'));
a
b = unique_fields_example_class(IX_inst('name','666'));
b
u1 = unique_references_container('HHH','unique_fields_example_class');
u1 = u1.add(a);
u1 = u1.add(a);
u1 = u1.add(b);
u1
u1{1}.myfield.name
u1{2}.myfield.name
u1{3}.myfield.name

% bing(u1);
u1.get_unique_field('myfield')

function bing(urc)
disp('bing');
s1=urc.get(1);
v=s1.('myfield');
cls = class(v)

uix = unique( urc.idx_, 'stable' )
glc = urc.global_container('value', urc.global_name_);
urc.global_container('CLEAR','HHH_IX_inst')
disp(glc);
%}
poss_field_values = unique_references_container(['HHH_',cls],cls)
for ii=1:numel(uix)
    sii = glc( uix(ii) )
    %hsh = glc.stored_hashes_( uix(ii) )
    v = sii.('myfield')
    [poss_field_values,nuix] = poss_field_values.add_single_(v)
end

end
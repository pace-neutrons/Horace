function display_single (w)
% Display useful information from projaxes object
%
%   >> display_single(w)

% Original author: T.G.Perring

disp(' ')
disp(' Directions defining projection axes (r.l.u.):')
disp(['            u: [',str_compress(num2str(w.u),', '),']'])
disp(['            v: [',str_compress(num2str(w.v),', '),']'])
if ~isempty(w.w)
    disp(['            w: [',str_compress(num2str(w.w),', '),']'])
else
    disp( '            w:  <empty>')
end
disp(' ')
disp(['      uoffset: [',str_compress(num2str(w.uoffset'),', '),']'])
disp(' ')
if w.nonorthogonal
    disp('nonorthogonal: true   (if u,v,w are non-orthogonal this will be respected)')
else
    disp('nonorthogonal: false  (orthogonal projection axes will be constructed)')
end
disp(' ')
disp(['         type: ',w.type,'    (defines normalisation of axes length)'])
disp(' ')
disp(['          lab: {''',w.lab{1},''', ''',w.lab{2},''', ''',w.lab{3},''', ''',w.lab{4},'''}  (axes labels)'])
disp(' ')

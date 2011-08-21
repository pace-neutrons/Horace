arr2d=[hp1,shift_x(hp1,20),shift_y(hp1,30)];
da(arr2d); lx 0 80; ly 0 80; keep_figure
zz=shift(arr2d,[15,30;20,10;50,5]);
da(zz); lx 0 80; ly 0 80; keep_figure
zz=shift(arr2d,[15,30]);
da(zz); lx 0 80; ly 0 80; keep_figure


arr2d=[hp1,scale_x(shift_y(hp1,20),1.5),scale_y(shift(hp1,[40,0]),2)];
da(arr2d); lx 0 80; ly 0 80; keep_figure
zz=scale(arr2d,[1.5,0.5;1,2;0.75,2]);
da(zz); lx 0 80; ly 0 80; keep_figure
zz=scale(arr2d,[1.5,0.5]);
da(zz); lx 0 80; ly 0 80; keep_figure



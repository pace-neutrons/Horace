%Compare (using the profiler) symmetrising using Marek's code vs the
%original:

% sqw_file='C:\Russell\Software\Mantid\VATES\VATESdemoSSC15\Templates\my_real_file.sqw';
% proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr'; proj.uoffset=[0,0,0,0];
% my_slice=cut_sqw(sqw_file,proj,[-3,0.05,3],[-3,0.05,3],[-3,0.05,3],[100,120]);
% size(my_slice.data.pix)

my_symm_old=symmetrise_sqw_pikulski(my_slice,[1,0,0],[0,0,1],[0,0,0]);




s1 = symop ([1,0,0],[0,1,0],[1,1,0]);
s2 = symop ([1,0,0],[0,0,1],[1,1,0]);

s3 = symop ([1,0,0],90,[0,1,1]);


proj.u = [1,1,1];
proj.v = [0,1,0];
proj.uoffset = [1,1.5,0.5];

alatt = [2.87,2.87,2.87];
angdeg = [90,90,90];

pbin = {[0.1,0.05,0.5], [1,0.1,3],[5,0.2,6]};

[ok, mess, proj_out, pbin_out] = transform_proj (s2, alatt, angdeg, proj, pbin)




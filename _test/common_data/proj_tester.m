function proj_tester(filename)
disp('******************************************************************')
disp('******************************************************************')
disp('******************************************************************')
w = read_sqw(filename);

dp = w.data.proj;
lp = dp.get_line_proj();
%
assertEqualToTol(dp,lp,1.e-5);

pix_range = w.pix.pix_range

img_range = w.data.img_range;
pix_to_img_range = min_max(dp.transform_pix_to_img(w.pix.coordinates));

ll_right = img_range(1,:)'<=pix_to_img_range(:,1);
rl_right = pix_to_img_range(:,2)<=img_range(2,:)';
pix_in_img = [img_range(1,:)',pix_to_img_range(:,1),ll_right,pix_to_img_range(:,2),rl_right,img_range(2,:)'];
disp('pix_range within img_range:')
disp(pix_in_img)

disp('******************************************************************')

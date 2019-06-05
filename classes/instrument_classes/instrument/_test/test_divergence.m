% Test divergence profile

ang = [-0.0855   -0.0681   -0.0506   -0.0332   -0.0157...
    0.0017    0.0192    0.0367    0.0541    0.0716  0.08];

prof = [0 0.0034 15  20.7727   34.1004 26   10.5929  5 2 0 0];

div_old = IX_divergence_profile(ang,prof);
div_new = IX_divergence_profile(ang,prof);

w = IX_dataset_1d(ang,prof);
area=integrate(w);
w = w/area.val;

asamp = rand(div_new,1e7,1);
wsamp = samp2distr(asamp,2000);


acolor k
dl(w)
acolor r
ph(wsamp)


[sigma, av_angle, fwhh] = div_new.profile_width






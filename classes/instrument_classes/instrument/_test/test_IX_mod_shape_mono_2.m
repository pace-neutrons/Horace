function test_IX_mod_shape_mono_2 (shape_freq, mc)
% Test various covariance functions

efix=8;
make_msm = @(x)IX_mod_shape_mono(x.moderator,x.chop_shape,x.chop_mono);
instru_mod = let_instrument_for_tests (efix, 280, 140, 20, 2, 2);
instru_mod.chop_shape.frequency=shape_freq;
obj = make_msm(instru_mod);
obj.energy = efix;

moderator = obj.moderator;
shaping_chopper = obj.shaping_chopper;
mono_chopper = obj.mono_chopper;
[~,t_m_av] = pulse_width(moderator);
wshape = pulse_range(shaping_chopper);
wmono = pulse_range(mono_chopper);
disp('----------------------')
disp(['     moderator t_av: ',num2str(t_m_av)])
disp(['shape chopper width: ',num2str(-wshape)])
disp([' mono chopper width: ',num2str(-wmono)])


if nargin==1
    mc = [1,1,1];
elseif nargin==2 && numel(mc)==2
    npnt = mc(1);
    nloop = mc(2);
    mc = [1,1,1];
    t_cov_all = NaN(nloop,3);
    t_mean_all = NaN(nloop,2);
    for i=1:nloop
        X = obj.rand(mc, [npnt,1]);
        t_cov = cov(X');
        t_cov_all(i,:) = t_cov(1:3);
        t_mean_all(i,:) = mean(X,2)';
    end
    t_cov_mean = mean(t_cov_all,1);
    t_cov_std = std(t_cov_all,1);
    disp(' ')
    disp([' covariance: ',num2str(t_cov_mean)])
    disp(['    std (%): ',num2str(100*t_cov_std./t_cov_mean)])
    disp(' ')
    t_mean_mean = mean(t_mean_all,1);
    t_mean_std = std(t_mean_all,1);
    disp([' covariance: ',num2str(t_mean_mean)])
    disp(['        std: ',num2str(t_mean_std)])
    return
end

disp('----------------------')
disp('Covariance method:')
tic
[t_cov, t_av] = covariance (obj,mc); 
toc
disp(t_cov(1:3)); disp(t_av)

disp('----------------------')
disp('tm-t_ch method:')
tic
[t_cov, t_av] = moments_2D_DEVEL (obj); 
toc
disp(t_cov(1:3)); disp(t_av)

disp('----------------------')
disp('Moments from random sampling')
tic
X = obj.rand(mc, [1e6,1]);
toc
t_cov = cov(X');
disp(t_cov(1:3)); disp(mean(X,2)');

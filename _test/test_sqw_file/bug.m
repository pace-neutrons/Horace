data = 'w2_small_v1.sqw';
proj = projection([1,-1,0],[1,1,0],'uoffset',[1,1,0]);
Emax = 350;
dE   = 5;
Dqk = [-0.05,0.05];
Dql = [-0.05,0.05];
bg_param = [0.382479 0.012739];


w2al = read_horace(data);
%plot(w2al);
%keep_figure
%

bg_before = cut_sqw(w2al,proj ,[-1,1],Dqk ,Dql ,[0,dE,Emax]);
%bg_eval1D = func_eval(bg_real1D,bg_fun,bg_param);
acolor('k');
plot(bg_before)
logy
%
bg = func_eval(w2al,@(q,en,par)(par(1)*exp(-par(2)*(en-50))),bg_param);
%bg = replicate(bg_before,w2al);
disp = w2al-bg;
%plot(disp);
%liny
%keep_figure
bg_after = cut_sqw(w2al,proj ,[-1,1],Dqk ,Dql ,[0,dE,Emax]);
acolor('r');
pl(bg_after)
%plot(w2al);
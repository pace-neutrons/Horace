%%========================================================================================================================
% Tests with d1d objects: still to be converted into a proper test routine as of 2 April 2012

% Make two d1d objects
w1=d1d([1,0,0],[0,2,100]);
w2=d1d([1,0,0],[1,2,101]);

% Put Gaussians on linear backgrounds - construct explicitly
nerr=20;

p1=[110,49,8,30,0.1];     % Gaussian 1
w1=func_eval(w1,@gauss_bkgd,p1);
w1=w1+nerr*rand(numel(w1.s),1);
w1.e=(nerr*(1+rand(numel(w1.s),1))/2).^2;

p2=[90,51,10,40,-0.1];     % Gaussian 1
w2=func_eval(w2,@gauss_bkgd,p2);
w2=w2+nerr*rand(numel(w2.s),1);
w2.e=(nerr*(1+rand(numel(w2.s),1))/2).^2;

acolor b
dp(w1)      % first time plot - even tho w1 is only a few kB, this command causes a just of over 300MB memory!
acolor r
pp(w2)

% Create a single x,y,e triple for testing against original mgenie fit.m

xx=(0:1:101)';
yy=[w1.s(:)';w2.s(:)']; yy=yy(:);
ee=sqrt([w1.e(:)';w2.e(:)']); ee=ee(:);

ss=ixtdataset_1d(xx',yy',ee');
acolor bla, dp(ss)


% Simple fit, to see if working - no test against mgenie fit
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, @func_eval, {{@bkgd, [40,0]}}, 'list', 2);


% Get multifit result
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, '', {{2,1,1,1.25},{3,1,2,0.25}},@func_eval, {{@bkgd, [40,0]}},'', {{},{2,2,1,-1}}, 'list',2);

[wfit_ref, f_ref] = fit (xx,yy,ee, @gauss_2bkgd_bind, [100,50,7,40,0,40,0], [1,0,0,1,1,1,0], 'list',2);


% Check reduction of function evaluations from buffering the calculation. Use profiler.
% Make lots of spectra
ww=repmat(w1,[4,5]);
for i=1:numel(ww)
    ww(i)=ww(i)+nerr*rand(numel(w1.s),1);
    ww(i).e=(nerr*(1+rand(numel(w1.s),1))/2).^2;
end

[wfit, f] = multifit (ww, @func_eval, {@gauss,[100,50,7]}, @func_eval, {{@bkgd, [40,0]}}, 'list', 2);






% Causes of error
% ---------------

% The following is an error because of that ambiguity problem with the background parameters
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, '', {{1,2,0,2},{2,1,1,1.25},{3,1,2,0.25}},...
                               @func_eval, {@bkgd, [40,0]},'', {{},{2,2,1,-1}}, 'list',2);

% The following is an error because of that ambiguity problem with the background binding arguments
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, '', {{1,2,0,2},{2,1,1,1.25},{3,1,2,0.25}},...
                               @func_eval, {{@bkgd, [40,0]}},'', {{},{2,2,1,-1}}, 'list',2);

% Why the background binding arguments ambiguity here?                           
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, '', {{1,2,0,2},{2,1,1,1.25},{3,1,2,0.25}},...
                               @func_eval, {{@bkgd, [40,0]}},'', {{},{{2,2,1,-1}}}, 'list',2);
                           
% Other points

% So many calls to isa_size - what are they all for? - in:
[wfit, f] = multifit ({w1,w2}, @func_eval, {@gauss,[100,50,7]}, '', {{2,1,1,1.25},{3,1,2,0.25}},@func_eval, {{@bkgd, [40,0]}},'', {{},{2,2,1,-1}}, 'list',2);

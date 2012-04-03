% ---------------------------------------------------------------------------------------
% Test various aspects of multifit, using Horace as of July 2009
% ---------------------------------------------------------------------------------------

% Make some test data
w1a=read_horace('c:\temp\w1a.sqw');
w1b=read_horace('c:\temp\w1b.sqw');
w1c=read_horace('c:\temp\w1c.sqw');
w1d=read_horace('c:\temp\w1d.sqw');
w2a=read_horace('c:\temp\w2a.sqw');
w2b=read_horace('c:\temp\w2b.sqw');

% Make three Gaussian peaks:
sqw1a=cut(w1a,[0.4,0.05,1]);
sqw1b=cut(w1b,[0.4,0.05,1]);
sqw1c=cut(w1c,[0.4,0.05,1]);

d1da=dnd(sqw1a);
d1db=dnd(sqw1b);
d1dc=dnd(sqw1c);

sqw_all=[sqw1a,sqw1b,sqw1c];

% Now the test
[wwref,ffref]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2);

% There are error bars on the background for the object which is entirely removed.
[ww,ff]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2,'remove',{[],[-1,3],[]});


% Test fits
% -------------

% Get what the answer should be
[ww0,ff0]=multifit_func(sqw_all([1,3]),@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2);


% Complex case to help decode the p_info structure
[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],[1,1,1],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},[1,1],{{2,1,0}},...
    'list',2);


% Complex case to help decode the p_info structure
[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[1,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[1,1]},{{2,1,0}},...
    'list',2);


% =================================================================================
% Some tests of the new algorithm
% =================================================================================

% Test1:
% ------
[ww,ff]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2,'remove',{[],[-1,3],[]});

% Get what the answer should be:
[ww0,ff0]=multifit_func(sqw_all([1,3]),@test_gauss,[0.15,0.7,0.05],@test_bkgd,[0.1,0],'list',2);



% Test2:
% ------
[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[1,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[1,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[]});

% Get what the answer should be:
[ww0,ff0]=multifit_func(sqw_all([1,3]),@test_gauss,[0.15,0.7,0.015],[1,1,0],{2,1,2},...
    @test_bkgd,{[0.1,-0.05],[0.3,-0.15]},{[0,1],[1,1]},{{2,1,0}},'list',2);



% Test3:
% ------
[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[1,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[1,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]});

% Get what the answer should be:
[ww0,ff0]=multifit_func(sqw_all(1),@test_gauss,[0.15,0.7,0.015],[1,1,0],...
    @test_bkgd,[0.1,-0.05],[0,1],{{2,1,0}},'list',2);



% Test4:
% ------
[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[0,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]});

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[0,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[-1,3],[-1,3],[-1,3]});

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[0,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]},'eval');

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[0,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[-1,3],[-1,3],[-1,3]},'eval');

%------------
% Test writing final parameter values

[ww0,ff0]=multifit_func(sqw_all(1),@test_gauss,[0.15,0.7,0.05],[1,1,0],{2,1,1},...
    @test_bkgd,[0.1,-0.05],[0,1],'list',2);

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[1,1,0],{2,1,3},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[0,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]});

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[1,1,1],{{2,1,3},{3,1}},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[1,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]});

[ww0,ff0]=multifit_func(sqw_all,@test_gauss,[0.15,0.7,0.015],[0,1,1],{{2,1,3},{3,1}},...
    @test_bkgd,{[0.1,-0.05],[0.2,-0.1],[0.3,-0.15]},{[1,1],[1,1],[0,1]},{{2,1,0}},...
    'list',2,'remove',{[],[-1,3],[-1,3]});


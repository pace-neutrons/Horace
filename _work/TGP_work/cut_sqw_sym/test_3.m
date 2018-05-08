make_data = false;

if make_data
    % Create cuts and save to file
    % ----------------------------
    % sqw file from which to take cuts for setup
    data400='D:\data\Fe\sqw_Toby\Fe_ei401.sqw';
    data800='D:\data\Fe\sqw_Toby\Fe_ei787.sqw';
    
    % 2D plane
    proj100.u = [1,0,0];
    proj100.v = [0,1,0];
    wce = cut_sqw (data800, proj100, 0.05, 0.05, [-0.1,0.1], [150,170]);
    wce = cut_sqw (data800, proj100, [-3,0.05,3], [-3,0.05,3], [-0.1,0.1], [150,170]);
    
    
    %% Two symmetry related cuts along [1,1,0] type directions
    proj1.u=[1,1,0];
    proj1.v=[-1,1,0];
    proj1.uoffset = [2,0,0]
    w110_1 = cut_sqw(data800,proj1,[-1,0.025,1],[-0.1,0.1],[-0.05,0.05],[150,160]);
    
    proj2.u=[1,-1,0];
    proj2.v=[1,1,0];
    proj2.uoffset = [2,0,0]
    w110_2 = cut_sqw(data800,proj2,[-1,0.025,1],[-0.1,0.1],[-0.05,0.05],[150,160]);
    
    % Now perform symmetrisation cut that does the two together
    sym2 = symop([1,0,0],[0,0,1],[2,0,0]);
    w110_12 = cut_sqw_sym(data800,proj1,[-1,0.025,1],[-0.1,0.1],[-0.05,0.05],[150,160],sym2);
    
    d110_12 = cut_sqw_sym(data800,proj1,[-1,0.025,1],[-0.1,0.1],[-0.05,0.05],[150,160],sym2,'-nopix');
      
    
    % Plot the results
    % -----------------
    acolor k
    plot(w110_1)
    acolor b
    pp(w110_2)
    
    % Should find that the seven points between x=-0.1 and x=+0.1 should be identical
    % to the points in w110_1, as all the pixels in this range from w110_2 are repeats
    acolor r
    pp(w110_12)
    
    % The '-nopix' option should overlay for points outside x=[-0.1,0.1]; 
    % Inside the range they should be the average (but not exactly, as the signal
    % is weighted by the number of pixels in each bin). At x=+/-0.1, there are
    % some shared pixels from the two cuts, some not, so more complicated)
    acolor g
    pp(d110_12)
    
    
    %% Tobyfit
    
    % Now that we are sure that the symmetrisation works, combine two cuts that are
    % clearly not symmetry related so that we can test that Tobyfit is correctly
    % simulating with calculated q values, not those stored in the sqw object

    proj400.u = [1,0,0];
    proj400.v = [0,1,0];
    
    wce = cut_sqw (data400, proj400, 0.05, 0.05, [-0.1,0.1], [90,110], '-nopix');
    plot(wce)
    keep_figure
    lx -2 3
    ly -2 4
    lz 0 0.3

    % Cut from (1,-1,0) to (3,1,0)
    proj200_1.u = [1,1,0];
    proj200_1.v = [-1,1,0];
    proj200_1.uoffset = [2,0,0];
    w200_1 = cut_sqw (data400, proj200_1, [-1,0.025,1], [-0.05,0.05], [-0.05,0.05], [90,110]);

    % Cut running inessential the opposite direction
    proj200_2.u = [-1,-1,0];
    proj200_2.v = [-1,1,0];
    proj200_2.uoffset = [2,0,0];
    w200_2 = cut_sqw (data400, proj200_2, [-1,0.025,1], [-0.2-0.05,0.2+0.05], [-0.05,0.05], [90,110]);
    
    % Use symmetrisation to combine two cuts
    sym_rot = symop([0,0,1],180,[1.9,0.1,0]);
    w200_12 = cut_sqw_sym (data400, proj200_1, [-1,0.025,1], [-0.05,0.05], [-0.05,0.05], [90,110], sym_rot);
    
    acolor k
    dp(w200_1)
    acolor b
    pp(w200_2)
    acolor r
    pp(w200_12)
    
    
    % Simulate the cuts
    gam = 50; Seff = 1;  J0 = 30; J1 = 0;
    par_HFM = [1,8,gam,Seff,0,J0,J1,0,0,0];
    
    % Old tobyfit (wrong symmetrisation):
    kk = tobyfit(w200_12);
    kk = kk.set_fun (@sqw_iron,par_HFM);
    kk = kk.set_bfun (@linear_bg,[0,0]);
    kk = kk.set_mc_points (10);
    
    w200_12_sim = kk.simulate;
    
    acolor g
    pl(w200_12_sim)
    
    % New tobyfit (correct symmetrisation):
    kkk = tobyfit(w200_12,'fermi_test');
    kkk = kkk.set_fun (@sqw_iron,par_HFM);
    kkk = kkk.set_bfun (@linear_bg,[0,0]);
    kkk = kkk.set_mc_points (10);
    
    w200_12_simnew = kkk.simulate;
    
    acolor m
    pl(w200_12_simnew)
    
    
    
    %% Save results
    datafile='test_tobyfit_1_data.nog';
    save(datafile,'w110a','w110b','w110arr','-mat')
    
    
else
    % Read in pre-prepared cuts
    % -------------------------
    datafile='test_tobyfit_1_data.nog';
    load(datafile,'-mat');
end


function conv = mf_leg_to_new(funcline)
% MATLAB wrapper for python script to modernise multifit syntax
%
% >> mf_leg_to_new("[wfit,fitdata]=multifit_sqw(my_new_cut,@sr122_xsec,pars,pfree,pbind,'list',1);")
% ans =
%
%    kk = multifit(my_new_cut);
%    kk = kk.set_fun(@sr122_xsec);
%    kk = kk.set_pin(pars);
%    kk = kk.set_free(pfree);
%    kk = kk.set_bind(pbind);
%    kk = kk.set_options('listing', 1);
%    [wfit,fitdata] = kk.fit();
%
% Script to roughly convert from multifit_legacy to modern multifit syntax
%
% J. Wilkins 8-9-2023



    pth = [horace_paths.root, pathsep, 'tools'];
    if count(py.sys.path, pwd) == 0
        insert(py.sys.path, int32(0), pth);
    end

    conv = py.mf_leg_to_new.convert_legacy_multifit(funcline);

end

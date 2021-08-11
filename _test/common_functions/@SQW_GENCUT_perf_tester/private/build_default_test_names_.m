function  build_default_test_names_(obj,nwk)
% generate default test names to use as keys for performance
% database
if isnumeric(nwk)
    nwk = num2str(nwk);
end
comb_method = obj.combine_method_name();
pc = parallel_config;
cluster = pc.parallel_cluster;
% 1
tf{1} = sprintf('gen_tmp_nwk_%s_%s',nwk,cluster);
% combine method name includes workers if they are used, but if
% they are not, we still need them to store appropriate
% dependence.
tf{2} = sprintf('comb_tmp_nwk_%s_%s',nwk,comb_method);

obj.default_test_names_('gen_sqw') = tf;
% 2
tf{1} = ['cutH1D_Small_nwk',nwk];
tf{2} = ['cutK1D_Small_nwk',nwk];
tf{3} = ['cutL1D_Small_nwk',nwk];
tf{4} = ['cutE_Small_nwk',nwk];
obj.default_test_names_('small_cut') = tf;
% 3
tf{1} = ['cutH1D_AllInt_nopix_nwk',nwk];
tf{2} = ['cutK1D_AllInt_nopix_nwk',nwk];
tf{3} = ['cutL1D_AllInt_nopix_nwk',nwk];
tf{4} = ['cutE_AllInt_nopix_nwk',nwk];
obj.default_test_names_('big_cut_nopix') = tf;
% 4
tf{1} =sprintf('cutH1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{2} =sprintf('cutK1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{3} =sprintf('cutL1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{4} =sprintf('cutE_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
obj.default_test_names_('big_cut_filebased') = tf;

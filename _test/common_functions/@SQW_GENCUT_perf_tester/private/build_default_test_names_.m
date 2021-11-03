function  test_names_map = build_default_test_names_(obj,nwk,addinfo)
% generate default test names to use as keys for performance
% database
% Inputs:
% nwk      -- Number of parallel workers used to run the algorithm
% addinfo  -- char array, describing other properties of the algorithm.
%
if isnumeric(nwk)
    nwk = num2str(nwk);
end
if ~exist('addinfo','var')
    addinfo = '_';
end
if ischar(addinfo)
    if addinfo(1) ~='_'
        addinfo = ['_',addinfo];
    end
else
    error('HORACE:SQW_GENCUT_parf_tester:invalid_argument',...
        'addinfo type can be only char, but provided %s with value %s',...
        class(addinfo),fevalc('disp(addinfo)'));
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
tf{1} = sprintf('cutH1D_Small_nwk%s%s',nwk,addinfo);
tf{2} = sprintf('cutK1D_Small_nwk%s%s',nwk,addinfo);
tf{3} = sprintf('cutL1D_Small_nwk%s%s',nwk,addinfo);
tf{4} = sprintf('cutE_Small_nwk%s%s',nwk,addinfo);
obj.default_test_names_('small_cut') = tf;
% 3
tf{1} = sprintf('cutH1D_AllInt_nopix_nwk%s%s',nwk,addinfo);
tf{2} = sprintf('cutK1D_AllInt_nopix_nwk%s%s',nwk,addinfo);
tf{3} = sprintf('cutL1D_AllInt_nopix_nwk%s%s',nwk,addinfo);
tf{4} = sprintf('cutE_AllInt_nopix_nwk%s%s',nwk,addinfo);
obj.default_test_names_('big_cut_nopix') = tf;
% 4
tf{1} =sprintf('cutH1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{2} =sprintf('cutK1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{3} =sprintf('cutL1D_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
tf{4} =sprintf('cutE_AllInt_flBsd_nwk%s_comb_%s',nwk,comb_method);
obj.default_test_names_('big_cut_filebased') = tf;
test_names_map = obj.default_test_names_;
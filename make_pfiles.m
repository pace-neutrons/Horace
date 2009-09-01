%This is a script to convert all private methods in Horace to pfiles, in
%preparation for a beta release.

fileroot='C:\SVN_area\Horace_sqw\';
filepath=cell(1,19);
filepath{1}='@d0d\private';
filepath{2}='@d1d\private';
filepath{3}='@d2d\private';
filepath{4}='@d3d\private';
filepath{5}='@d4d\private';
filepath{6}='@sqw\private';
filepath{7}='private';
filepath{8}='@sigvar\private';

filepath{9}='developer_only\@sigvar';
filepath{10}='developer_only\@sigvar\private';
filepath{11}='developer_only\@testsigvar';
filepath{12}='developer_only\@testsigvar\private';
filepath{13}='developer_only\class_template';
filepath{14}='developer_only\class_template\private';
filepath{15}='developer_only\operator_template';

filepath{16}='libisis\@d1d';
filepath{17}='libisis\@d2d';
filepath{18}='libisis\@d3d';
filepath{19}='libisis\@sqw';

filepath{20}='@sqw';
filepath{21}='GUI';

filepath{22}='@sigvar';

for i=1:22
    thepath=[fileroot,filepath{i}];
    cd(thepath);
    pcode *.m
    delete([thepath,'\*.m']);
end

%this has now all been done.

function fieldstore=get_horace_fields(handles)
%
% Subroutine to get all of the information about editable fields in current
% horace gui.
%

fieldstore=cell(101,1);

fieldstore{1}=get(handles.gen_sqw_filename_edit,'String');
fieldstore{2}=get(handles.gen_sqw_parfile_edit,'String');
fieldstore{3}=get(handles.gen_sqw_u_edit,'String');
fieldstore{4}=get(handles.gen_sqw_v_edit,'String');
fieldstore{5}=get(handles.gen_sqw_efix_edit,'String');
fieldstore{6}=get(handles.gen_sqw_alatt_edit,'String');
fieldstore{7}=get(handles.gen_sqw_angdeg_edit,'String');
fieldstore{8}=num2str(get(handles.gen_sqw_emode_popupmenu,'Value'));
fieldstore{9}=get(handles.gen_sqw_offsets_edit,'String');
fieldstore{10}=get(handles.gen_sqw_psi_edit,'String');
fieldstore{11}=get(handles.gen_sqw_listbox,'String');

fieldstore{12}=get(handles.sqw_filename_edit,'String');
fieldstore{13}=get(handles.Cutfile_u_edit,'String');
fieldstore{14}=get(handles.Cutfile_v_edit,'String');
fieldstore{15}=get(handles.Cutfile_w_edit,'String');
fieldstore{16}=num2str(get(handles.Cutfile_rlu_1_radiobutton,'Value'));
fieldstore{17}=num2str(get(handles.Cutfile_ang_1_radiobutton,'Value'));
fieldstore{18}=num2str(get(handles.Cutfile_rlu_2_radiobutton,'Value'));
fieldstore{19}=num2str(get(handles.Cutfile_ang_2_radiobutton,'Value'));
fieldstore{20}=num2str(get(handles.Cutfile_rlu_3_radiobutton,'Value'));
fieldstore{21}=num2str(get(handles.Cutfile_ang_3_radiobutton,'Value'));
fieldstore{22}=get(handles.Cutfile_ax1_range_edit,'String');
fieldstore{23}=get(handles.Cutfile_ax2_range_edit,'String');
fieldstore{24}=get(handles.Cutfile_ax3_range_edit,'String');
fieldstore{25}=get(handles.Cutfile_ax4_range_edit,'String');
fieldstore{26}=num2str(get(handles.Cutfile_keep_pix_radiobutton,'Value'));
fieldstore{27}=get(handles.Cutfile_out_obj_edit,'String');
fieldstore{28}=num2str(get(handles.Cutfile_out_file_radio,'Value'));
fieldstore{29}=get(handles.Cutfile_out_file_edit,'String');

fieldstore{30}=num2str(get(handles.plot_marker_popupmenu,'Value'));
fieldstore{31}=num2str(get(handles.plot_colour_popupmenu,'Value'));
fieldstore{32}=num2str(get(handles.smoothing_popupmenu,'Value'));
fieldstore{33}=num2str(get(handles.plot_over_marker_popupmenu,'Value'));
fieldstore{34}=num2str(get(handles.plot_over_colour_popupmenu,'Value'));
fieldstore{35}=get(handles.savefile_edit,'String');

fieldstore{36}=get(handles.Rep_outobj_edit,'String');
fieldstore{37}=num2str(get(handles.Rep_outfile_radiobutton,'Value'));
fieldstore{38}=get(handles.Rep_outfile_edit,'String');

fieldstore{39}=get(handles.Bose_temp_edit,'String');
fieldstore{40}=get(handles.Bose_outobj_edit,'String');
fieldstore{41}=num2str(get(handles.Bose_outfile_radiobutton,'Value'));
fieldstore{42}=get(handles.Bose_outfile_edit,'String');

fieldstore{43}=num2str(get(handles.Bin_obj_radiobutton,'Value'));
fieldstore{44}=num2str(get(handles.Bin_number_radiobutton,'Value'));
fieldstore{45}=get(handles.Bin_number_edit,'String');
fieldstore{46}=num2str(get(handles.Bin_function_popupmenu,'Value'));
fieldstore{47}=get(handles.Bin_outobj_edit,'String');
fieldstore{48}=num2str(get(handles.Bin_outfile_radiobutton,'Value'));
fieldstore{49}=get(handles.Bin_outfile_edit,'String');

fieldstore{50}=num2str(get(handles.Unary_func_popupmenu,'Value'));
fieldstore{51}=get(handles.Unary_outobj_edit,'String');
fieldstore{52}=num2str(get(handles.Unary_outfile_radiobutton,'Value'));
fieldstore{53}=get(handles.Unary_outfile_edit,'String');

fieldstore{54}=get(handles.Cut_ax1_edit,'String');
fieldstore{55}=get(handles.Cut_ax2_edit,'String');
fieldstore{56}=get(handles.Cut_ax3_edit,'String');
fieldstore{57}=get(handles.Cut_ax4_edit,'String');
fieldstore{58}=num2str(get(handles.Cut_retain_radiobutton,'Value'));
fieldstore{59}=get(handles.Cut_Outobj_edit,'String');
fieldstore{60}=num2str(get(handles.Cut_Outfile_radiobutton,'Value'));
fieldstore{61}=get(handles.Cut_outfile_edit,'String');

fieldstore{62}=num2str(get(handles.Rebin_template_radiobutton,'Value'));
fieldstore{63}=num2str(get(handles.Rebin_lostephi_radiobutton,'Value'));
fieldstore{64}=get(handles.Rebin_lostephi_edit,'String');
fieldstore{65}=get(handles.Rebin_outobj_edit,'String');
fieldstore{66}=num2str(get(handles.Rebin_outfile_radiobutton,'Value'));
fieldstore{67}=get(handles.Rebin_outfile_edit,'String');

fieldstore{68}=num2str(get(handles.Sym_midpoint_radiobutton,'Value'));
fieldstore{69}=get(handles.Sym_midpoint_edit,'String');
fieldstore{70}=num2str(get(handles.Sym_plane_radiobutton,'Value'));
fieldstore{71}=get(handles.Sym_v1_edit,'String');
fieldstore{72}=get(handles.Sym_v2_edit,'String');
fieldstore{73}=get(handles.Sym_v3_edit,'String');
fieldstore{74}=get(handles.Sym_outobj_edit,'String');
fieldstore{75}=num2str(get(handles.Sym_outfile_radiobutton,'Value'));
fieldstore{76}=get(handles.Sym_outfile_edit,'String');

fieldstore{77}=num2str(get(handles.Comb_tolerance_radiobutton,'Value'));
fieldstore{78}=get(handles.Comb_tolerance_edit,'String');
fieldstore{79}=get(handles.Comb_outobj_edit,'String');
fieldstore{80}=num2str(get(handles.Comb_outfile_radiobutton,'Value'));
fieldstore{81}=get(handles.Comb_outfile_edit,'String');


%For elements of the handles array that may not exist, have to check before
%saving them:
if isfield(handles,'gen_emode')
    fieldstore{82}=handles.gen_emode;
else
    fieldstore{82}='';
end
%===
if isfield(handles,'plotmarker')
    fieldstore{83}=handles.plotmarker;
else
    fieldstore{83}='';
end
if isfield(handles,'plotcolour')
    fieldstore{84}=handles.plotcolour;
else
    fieldstore{84}='';
end
%===
if isfield(handles,'plotovermarker')
    fieldstore{85}=handles.plotovermarker;
else
    fieldstore{85}='';
end
if isfield(handles,'plotovercolour')
    fieldstore{86}=handles.plotovercolour;
else
    fieldstore{86}='';
end
if isfield(handles,'horacefig')
    %fieldstore{87}=handles.horacefig;
    fieldstore{87}='';%realise we shouldn't be filling this in
else
    fieldstore{87}='';
end
%=====
if isfield(handles,'bin_funcstr')
    fieldstore{88}=handles.bin_funcstr;
else
    fieldstore{88}='';
end
%====
if isfield(handles,'un_funcstr')
    fieldstore{89}=handles.un_funcstr;
else
    fieldstore{89}='';
end
%===
if isfield(handles,'listbox_selected')
    fieldstore{90}=num2str(handles.listbox_selected);
else
    fieldstore{90}='';
end

fieldstore{91}=get(handles.DatafilePanel, 'Visible');
fieldstore{92}=get(handles.WorkspacePanel, 'Visible');
fieldstore{93}=get(handles.gen_sqw_panel, 'Visible');

fieldstore{94}=get(handles.CutPanel, 'Visible');
fieldstore{95}=get(handles.UnaryPanel, 'Visible');
fieldstore{96}=get(handles.BinaryPanel, 'Visible');
fieldstore{97}=get(handles.BosePanel, 'Visible');
fieldstore{98}=get(handles.ReplicatePanel, 'Visible');
fieldstore{99}=get(handles.CombinePanel, 'Visible');
fieldstore{100}=get(handles.SymmetrisePanel, 'Visible');
fieldstore{101}=get(handles.RebinPanel, 'Visible');



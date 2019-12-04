function handles_out=set_horace_fields(handles_in,data_loaded)
%
% Subroutine to take Horace data fields read from a saved file, and fill
% them in the GUI.
%

%Initialise output:
handles_out=handles_in;

%Convert data_loaded into a cell array
dd=cellstr(data_loaded);

set(handles_out.gen_sqw_filename_edit,'String',dd{1});
set(handles_out.gen_sqw_parfile_edit,'String',dd{2});
set(handles_out.gen_sqw_u_edit,'String',dd{3});
set(handles_out.gen_sqw_v_edit,'String',dd{4});
set(handles_out.gen_sqw_efix_edit,'String',dd{5});
set(handles_out.gen_sqw_alatt_edit,'String',dd{6});
set(handles_out.gen_sqw_angdeg_edit,'String',dd{7});
set(handles_out.gen_sqw_emode_popupmenu,'Value',str2double(dd{8}));
set(handles_out.gen_sqw_offsets_edit,'String',dd{9});
set(handles_out.gen_sqw_psi_edit,'String',dd{10});
set(handles_out.gen_sqw_listbox,'String',dd{11});

set(handles_out.sqw_filename_edit,'String',dd{12});
set(handles_out.Cutfile_u_edit,'String',dd{13});
set(handles_out.Cutfile_v_edit,'String',dd{14});
set(handles_out.Cutfile_w_edit,'String',dd{15});
(set(handles_out.Cutfile_rlu_1_radiobutton,'Value',str2double(dd{16})));
(set(handles_out.Cutfile_ang_1_radiobutton,'Value',str2double(dd{17})));
(set(handles_out.Cutfile_rlu_2_radiobutton,'Value',str2double(dd{18})));
(set(handles_out.Cutfile_ang_2_radiobutton,'Value',str2double(dd{19})));
(set(handles_out.Cutfile_rlu_3_radiobutton,'Value',str2double(dd{20})));
(set(handles_out.Cutfile_ang_3_radiobutton,'Value',str2double(dd{21})));
set(handles_out.Cutfile_ax1_range_edit,'String',dd{22});
set(handles_out.Cutfile_ax2_range_edit,'String',dd{23});
set(handles_out.Cutfile_ax3_range_edit,'String',dd{24});
set(handles_out.Cutfile_ax4_range_edit,'String',dd{25});
(set(handles_out.Cutfile_keep_pix_radiobutton,'Value',str2double(dd{26})));
set(handles_out.Cutfile_out_obj_edit,'String',dd{27});
(set(handles_out.Cutfile_out_file_radio,'Value',str2double(dd{28})));
set(handles_out.Cutfile_out_file_edit,'String',dd{29});

(set(handles_out.plot_marker_popupmenu,'Value',str2double(dd{30})));
(set(handles_out.plot_colour_popupmenu,'Value',str2double(dd{31})));
(set(handles_out.smoothing_popupmenu,'Value',str2double(dd{32})));
(set(handles_out.plot_over_marker_popupmenu,'Value',str2double(dd{33})));
(set(handles_out.plot_over_colour_popupmenu,'Value',str2double(dd{34})));
set(handles_out.savefile_edit,'String',dd{35});

set(handles_out.Rep_outobj_edit,'String',dd{36});
(set(handles_out.Rep_outfile_radiobutton,'Value',str2double(dd{37})));
set(handles_out.Rep_outfile_edit,'String',dd{38});

set(handles_out.Bose_temp_edit,'String',dd{39});
set(handles_out.Bose_outobj_edit,'String',dd{40});
(set(handles_out.Bose_outfile_radiobutton,'Value',str2double(dd{41})));
set(handles_out.Bose_outfile_edit,'String',dd{42});

(set(handles_out.Bin_obj_radiobutton,'Value',str2double(dd{43})));
(set(handles_out.Bin_number_radiobutton,'Value',str2double(dd{44})));
set(handles_out.Bin_number_edit,'String',dd{45});
(set(handles_out.Bin_function_popupmenu,'Value',str2double(dd{46})));
set(handles_out.Bin_outobj_edit,'String',dd{47});
(set(handles_out.Bin_outfile_radiobutton,'Value',str2double(dd{48})));
set(handles_out.Bin_outfile_edit,'String',dd{49});

(set(handles_out.Unary_func_popupmenu,'Value',str2double(dd{50})));
set(handles_out.Unary_outobj_edit,'String',dd{51});
(set(handles_out.Unary_outfile_radiobutton,'Value',str2double(dd{52})));
set(handles_out.Unary_outfile_edit,'String',dd{53});

set(handles_out.Cut_ax1_edit,'String',dd{54});
set(handles_out.Cut_ax2_edit,'String',dd{55});
set(handles_out.Cut_ax3_edit,'String',dd{56});
set(handles_out.Cut_ax4_edit,'String',dd{57});
(set(handles_out.Cut_retain_radiobutton,'Value',str2double(dd{58})));
set(handles_out.Cut_Outobj_edit,'String',dd{59});
(set(handles_out.Cut_Outfile_radiobutton,'Value',str2double(dd{60})));
set(handles_out.Cut_outfile_edit,'String',dd{61});

(set(handles_out.Rebin_template_radiobutton,'Value',str2double(dd{62})));
(set(handles_out.Rebin_lostephi_radiobutton,'Value',str2double(dd{63})));
set(handles_out.Rebin_lostephi_edit,'String',dd{64});
set(handles_out.Rebin_outobj_edit,'String',dd{65});
(set(handles_out.Rebin_outfile_radiobutton,'Value',str2double(dd{66})));
set(handles_out.Rebin_outfile_edit,'String',dd{67});

(set(handles_out.Sym_midpoint_radiobutton,'Value',str2double(dd{68})));
set(handles_out.Sym_midpoint_edit,'String',dd{69});
(set(handles_out.Sym_plane_radiobutton,'Value',str2double(dd{70})));
set(handles_out.Sym_v1_edit,'String',dd{71});
set(handles_out.Sym_v2_edit,'String',dd{72});
set(handles_out.Sym_v3_edit,'String',dd{73});
set(handles_out.Sym_outobj_edit,'String',dd{74});
(set(handles_out.Sym_outfile_radiobutton,'Value',str2double(dd{75})));
set(handles_out.Sym_outfile_edit,'String',dd{76});

(set(handles_out.Comb_tolerance_radiobutton,'Value',str2double(dd{77})));
set(handles_out.Comb_tolerance_edit,'String',dd{78});
set(handles_out.Comb_outobj_edit,'String',dd{79});
(set(handles_out.Comb_outfile_radiobutton,'Value',str2double(dd{80})));
set(handles_out.Comb_outfile_edit,'String',dd{81});


%For elements of the handles_out array that may not exist, have to check before
%saving them:
if ~isempty(dd{82})
    handles_out.gen_emode=dd{82};
end
%===
if ~isempty(dd{83})
    handles_out.plotmarker=dd{83};
end
if ~isempty(dd{84})
    handles_out.plotcolour=dd{84};
end
%===
if ~isempty(dd{85})
    handles_out.plotovermarker=dd{85};
end
if ~isempty(dd{86})
    handles_out.plotovercolour;
end
%====
%Do not use dd{87}
%=====
if ~isempty(dd{88})
    handles_out.bin_funcstr=dd{88};
end
%====
if ~isempty(dd{89})
    handles_out.un_funcstr=dd{89};
end
%===
if ~isempty(dd{90})
    handles_out.listbox_selected=str2double(dd{90});
end

%============

set(handles_out.DatafilePanel, 'Visible',dd{91});
set(handles_out.WorkspacePanel, 'Visible',dd{92});
set(handles_out.gen_sqw_panel, 'Visible',dd{93});

set(handles_out.CutPanel, 'Visible',dd{94});
set(handles_out.UnaryPanel, 'Visible',dd{95});
set(handles_out.BinaryPanel, 'Visible',dd{96});
set(handles_out.BosePanel, 'Visible',dd{97});
set(handles_out.ReplicatePanel, 'Visible',dd{98});
set(handles_out.CombinePanel, 'Visible',dd{99});
set(handles_out.SymmetrisePanel, 'Visible',dd{100});
set(handles_out.RebinPanel, 'Visible',dd{101});





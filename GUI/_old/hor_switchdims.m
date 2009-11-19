function handles_out=hor_switchdims(handles_in,ndims)
%
%updates the GUI window depending on the number of dimensions of a dataset
%being examined (from workspace)
%
% R.A. Ewings 11/11/2008
%
handles_out=handles_in;
if ndims==0
    set(handles_out.cut_panel,'Visible','off');
    set(handles_out.Plot_panel,'Visible','off');
    disp('0-dimensional object selected - no plot or cut operations possible');
elseif ndims==1
    set(handles_out.cut_panel,'Visible','on');
    set(handles_out.Plot_panel,'Visible','on');
    %
    set(handles_out.ax_label1_radio,'Visible','on');
    set(handles_out.axislabel_edit1,'Visible','on');
    set(handles_out.LoLim_Ax1_edit,'Visible','on');
    set(handles_out.Step_Ax1_edit,'Visible','on');
    set(handles_out.HiLim_Ax1_edit,'Visible','on');
    %
    set(handles_out.ax_label2_radio,'Visible','off');
    set(handles_out.axislabel_edit2,'Visible','on');
    set(handles_out.LoLim_Ax2_edit,'Visible','off');
    set(handles_out.Step_Ax2_edit,'Visible','off');
    set(handles_out.HiLim_Ax2_edit,'Visible','off');
    %
    set(handles_out.ax_label3_radio,'Visible','off');
    set(handles_out.axislabel_edit3,'Visible','on');
    set(handles_out.LoLim_Ax3_edit,'Visible','off');
    set(handles_out.Step_Ax3_edit,'Visible','off');
    set(handles_out.HiLim_Ax3_edit,'Visible','off');
    %
    set(handles_out.ax_label4_radio,'Visible','off');
    set(handles_out.axislabel_edit4,'Visible','on');
    set(handles_out.LoLim_Ax4_edit,'Visible','off');
    set(handles_out.Step_Ax4_edit,'Visible','off');
    set(handles_out.HiLim_Ax4_edit,'Visible','off');
    %
    set(handles_out.PlotAxis1_edit,'Visible','on');
    set(handles_out.PlotAx1_lo_edit,'Visible','on');
    set(handles_out.PlotAx1_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu1,'Visible','on');
    %
    set(handles_out.PlotAxis2_edit,'Visible','on');
    set(handles_out.PlotAx2_lo_edit,'Visible','on');
    set(handles_out.PlotAx2_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu2,'Visible','on');
    %
    set(handles_out.PlotAxis3_edit,'Visible','off');
    set(handles_out.PlotAx3_lo_edit,'Visible','off');
    set(handles_out.PlotAx3_hi_edit,'Visible','off');
    set(handles_out.linlogScale_menu3,'Visible','off');
    %
    set(handles_out.SmoothAx1_button,'Visible','on');
    set(handles_out.SmoothAxis1_text,'Visible','on');
    set(handles_out.SmoothAx1_menu,'Visible','on');
    set(handles_out.SmoothWid1_edit,'Visible','on');
    %
    set(handles_out.SmoothAx2_button,'Visible','off');
    set(handles_out.SmoothAxis2_text,'Visible','off');
    set(handles_out.SmoothWid2_edit,'Visible','off');
    %
    set(handles_out.SmoothAx3_button,'Visible','off');
    set(handles_out.SmoothAxis3_text,'Visible','off');
    set(handles_out.SmoothWid3_edit,'Visible','off');
    %
    set(handles_out.PlotStyle_panel,'Visible','on');
    set(handles_out.PlotOver_pushbutton,'Visible','on');
elseif ndims==2
    set(handles_out.cut_panel,'Visible','on');
    set(handles_out.Plot_panel,'Visible','on');
    %
    set(handles_out.ax_label1_radio,'Visible','on');
    set(handles_out.axislabel_edit1,'Visible','on');
    set(handles_out.LoLim_Ax1_edit,'Visible','on');
    set(handles_out.Step_Ax1_edit,'Visible','on');
    set(handles_out.HiLim_Ax1_edit,'Visible','on');
    %
    set(handles_out.ax_label2_radio,'Visible','on');
    set(handles_out.axislabel_edit2,'Visible','on');
    set(handles_out.LoLim_Ax2_edit,'Visible','on');
    set(handles_out.Step_Ax2_edit,'Visible','on');
    set(handles_out.HiLim_Ax2_edit,'Visible','on');
    %
    set(handles_out.ax_label3_radio,'Visible','off');
    set(handles_out.axislabel_edit3,'Visible','on');
    set(handles_out.LoLim_Ax3_edit,'Visible','off');
    set(handles_out.Step_Ax3_edit,'Visible','off');
    set(handles_out.HiLim_Ax3_edit,'Visible','off');
    %
    set(handles_out.ax_label4_radio,'Visible','off');
    set(handles_out.axislabel_edit4,'Visible','on');
    set(handles_out.LoLim_Ax4_edit,'Visible','off');
    set(handles_out.Step_Ax4_edit,'Visible','off');
    set(handles_out.HiLim_Ax4_edit,'Visible','off');
    %
    set(handles_out.PlotAxis1_edit,'Visible','on');
    set(handles_out.PlotAx1_lo_edit,'Visible','on');
    set(handles_out.PlotAx1_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu1,'Visible','on');
    %
    set(handles_out.PlotAxis2_edit,'Visible','on');
    set(handles_out.PlotAx2_lo_edit,'Visible','on');
    set(handles_out.PlotAx2_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu2,'Visible','on');
    %
    set(handles_out.PlotAxis3_edit,'Visible','on');
    set(handles_out.PlotAx3_lo_edit,'Visible','on');
    set(handles_out.PlotAx3_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu3,'Visible','on');
    %
    set(handles_out.SmoothAx1_button,'Visible','on');
    set(handles_out.SmoothAxis1_text,'Visible','on');
    set(handles_out.SmoothAx1_menu,'Visible','on');
    set(handles_out.SmoothWid1_edit,'Visible','on');
    %
    set(handles_out.SmoothAx2_button,'Visible','on');
    set(handles_out.SmoothAxis2_text,'Visible','on');
    set(handles_out.SmoothWid2_edit,'Visible','on');
    %
    set(handles_out.SmoothAx3_button,'Visible','off');
    set(handles_out.SmoothAxis3_text,'Visible','off');
    set(handles_out.SmoothWid3_edit,'Visible','off');
    %
    set(handles_out.PlotStyle_panel,'Visible','off');
    set(handles_out.PlotOver_pushbutton,'Visible','off');
elseif ndims==3
    set(handles_out.cut_panel,'Visible','on');
    set(handles_out.Plot_panel,'Visible','on');
    %
    set(handles_out.ax_label1_radio,'Visible','on');
    set(handles_out.axislabel_edit1,'Visible','on');
    set(handles_out.LoLim_Ax1_edit,'Visible','on');
    set(handles_out.Step_Ax1_edit,'Visible','on');
    set(handles_out.HiLim_Ax1_edit,'Visible','on');
    %
    set(handles_out.ax_label2_radio,'Visible','on');
    set(handles_out.axislabel_edit2,'Visible','on');
    set(handles_out.LoLim_Ax2_edit,'Visible','on');
    set(handles_out.Step_Ax2_edit,'Visible','on');
    set(handles_out.HiLim_Ax2_edit,'Visible','on');
    %
    set(handles_out.ax_label3_radio,'Visible','on');
    set(handles_out.axislabel_edit3,'Visible','on');
    set(handles_out.LoLim_Ax3_edit,'Visible','on');
    set(handles_out.Step_Ax3_edit,'Visible','on');
    set(handles_out.HiLim_Ax3_edit,'Visible','on');
    %
    set(handles_out.ax_label4_radio,'Visible','off');
    set(handles_out.axislabel_edit4,'Visible','on');
    set(handles_out.LoLim_Ax4_edit,'Visible','off');
    set(handles_out.Step_Ax4_edit,'Visible','off');
    set(handles_out.HiLim_Ax4_edit,'Visible','off');
    %
    %NB I don't think the lx, ly, lz commands actually work with
    %sliceomatic - need to check this!
    set(handles_out.PlotAxis1_edit,'Visible','on');
    set(handles_out.PlotAx1_lo_edit,'Visible','on');
    set(handles_out.PlotAx1_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu1,'Visible','on');
    %
    set(handles_out.PlotAxis2_edit,'Visible','on');
    set(handles_out.PlotAx2_lo_edit,'Visible','on');
    set(handles_out.PlotAx2_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu2,'Visible','on');
    %
    set(handles_out.PlotAxis3_edit,'Visible','on');
    set(handles_out.PlotAx3_lo_edit,'Visible','on');
    set(handles_out.PlotAx3_hi_edit,'Visible','on');
    set(handles_out.linlogScale_menu3,'Visible','on');
    %
    set(handles_out.SmoothAx1_button,'Visible','on');
    set(handles_out.SmoothAxis1_text,'Visible','on');
    set(handles_out.SmoothAx1_menu,'Visible','on');
    set(handles_out.SmoothWid1_edit,'Visible','on');
    %
    set(handles_out.SmoothAx2_button,'Visible','on');
    set(handles_out.SmoothAxis2_text,'Visible','on');
    set(handles_out.SmoothWid2_edit,'Visible','on');
    %
    set(handles_out.SmoothAx3_button,'Visible','on');
    set(handles_out.SmoothAxis3_text,'Visible','on');
    set(handles_out.SmoothWid3_edit,'Visible','on');
    %
    set(handles_out.PlotStyle_panel,'Visible','off');
    set(handles_out.PlotOver_pushbutton,'Visible','off');
elseif ndims==4
    set(handles_out.cut_panel,'Visible','on');
    set(handles_out.Plot_panel,'Visible','off');
    %disp('4-dimensional odject selected - no plot operation possible');
    %get rid of this message because it gets annoying after a while!
    %
    set(handles_out.ax_label1_radio,'Visible','on');
    set(handles_out.axislabel_edit1,'Visible','on');
    set(handles_out.LoLim_Ax1_edit,'Visible','on');
    set(handles_out.Step_Ax1_edit,'Visible','on');
    set(handles_out.HiLim_Ax1_edit,'Visible','on');
    %
    set(handles_out.ax_label2_radio,'Visible','on');
    set(handles_out.axislabel_edit2,'Visible','on');
    set(handles_out.LoLim_Ax2_edit,'Visible','on');
    set(handles_out.Step_Ax2_edit,'Visible','on');
    set(handles_out.HiLim_Ax2_edit,'Visible','on');
    %
    set(handles_out.ax_label3_radio,'Visible','on');
    set(handles_out.axislabel_edit3,'Visible','on');
    set(handles_out.LoLim_Ax3_edit,'Visible','on');
    set(handles_out.Step_Ax3_edit,'Visible','on');
    set(handles_out.HiLim_Ax3_edit,'Visible','on');
    %
    set(handles_out.ax_label4_radio,'Visible','on');
    set(handles_out.axislabel_edit4,'Visible','on');
    set(handles_out.LoLim_Ax4_edit,'Visible','on');
    set(handles_out.Step_Ax4_edit,'Visible','on');
    set(handles_out.HiLim_Ax4_edit,'Visible','on');
end

%put in upper and lower limits of integration if the radio buttons are
%already checked:
if get(handles_out.ax_label1_radio,'Value') == get(handles_out.ax_label1_radio,'Max')...
        && strcmp(get(handles_out.ax_label1_radio,'Visible'),'on');
    set(handles_out.LoLim_Ax1_edit,'Visible','on');
    set(handles_out.HiLim_Ax1_edit,'Visible','on');
    set(handles_out.Step_Ax1_edit,'Visible','off');
elseif strcmp(get(handles_out.ax_label1_radio,'Visible'),'off');
    set(handles_out.LoLim_Ax1_edit,'Visible','off');
    set(handles_out.HiLim_Ax1_edit,'Visible','off');
    set(handles_out.Step_Ax1_edit,'Visible','off');
end
if get(handles_out.ax_label2_radio,'Value') == get(handles_out.ax_label2_radio,'Max')...
        && strcmp(get(handles_out.ax_label2_radio,'Visible'),'on');
    set(handles_out.LoLim_Ax2_edit,'Visible','on');
    set(handles_out.HiLim_Ax2_edit,'Visible','on');
    set(handles_out.Step_Ax2_edit,'Visible','off');
elseif strcmp(get(handles_out.ax_label2_radio,'Visible'),'off');
    set(handles_out.LoLim_Ax2_edit,'Visible','off');
    set(handles_out.HiLim_Ax2_edit,'Visible','off');
    set(handles_out.Step_Ax2_edit,'Visible','off');
end
if get(handles_out.ax_label3_radio,'Value') == get(handles_out.ax_label3_radio,'Max')...
        && strcmp(get(handles_out.ax_label3_radio,'Visible'),'on');
    set(handles_out.LoLim_Ax3_edit,'Visible','on');
    set(handles_out.HiLim_Ax3_edit,'Visible','on');
    set(handles_out.Step_Ax3_edit,'Visible','off');
elseif strcmp(get(handles_out.ax_label3_radio,'Visible'),'off');
    set(handles_out.LoLim_Ax3_edit,'Visible','off');
    set(handles_out.HiLim_Ax3_edit,'Visible','off');
    set(handles_out.Step_Ax3_edit,'Visible','off');
end
if get(handles_out.ax_label4_radio,'Value') == get(handles_out.ax_label4_radio,'Max')...
        && strcmp(get(handles_out.ax_label4_radio,'Visible'),'on');
    set(handles_out.LoLim_Ax4_edit,'Visible','on');
    set(handles_out.HiLim_Ax4_edit,'Visible','on');
    set(handles_out.Step_Ax4_edit,'Visible','off');
elseif strcmp(get(handles_out.ax_label4_radio,'Visible'),'off');
    set(handles_out.LoLim_Ax4_edit,'Visible','off');
    set(handles_out.HiLim_Ax4_edit,'Visible','off');
    set(handles_out.Step_Ax4_edit,'Visible','off');
end


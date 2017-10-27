function rize_figure_(fig_h)
% real function to rize a image on top of any window
% as textbook suggestions do not work.
%

if verLessThan('matlab','8.4')
    figure(fig_h);
else
    fJFrame = get(fig_h,'JavaFrame');
    drawnow expose
    jw = fJFrame.fHG2Client.getWindow();
    %
    if isjava(jw) % somethimes it is not recognized as jave
        jw.setAlwaysOnTop(true);
        jw.setAlwaysOnTop(false);
    end
end

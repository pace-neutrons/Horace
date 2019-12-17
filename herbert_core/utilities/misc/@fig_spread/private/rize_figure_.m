function rize_figure_(fig_h)
% Function to rize a image on top of any window
%
% as old way does not work for new Matlab graphics.
%
%
% $Revision:: 839 ($Date:: 2019-12-16 18:18:44 +0000 (Mon, 16 Dec 2019) $)
%
if verLessThan('matlab','8.4')
    figure(fig_h);
else
    fJFrame = get(fig_h,'JavaFrame');
    drawnow expose
    jw = fJFrame.fHG2Client.getWindow();
    %
    if isjava(jw) % somethimes it is not recognized as java within 
                  % a running script while always recognized in debugger
        jw.setAlwaysOnTop(true);
        jw.setAlwaysOnTop(false);
    end
end


function rize_figure_(fig_h)
% Function to raise a Matlab figure window above all other windows.
%
% The history of this function is as follows:
% - The conventional matlab way to do this is to use the figure function with
%   the figure handle as the input argument: 
%       >> figure(fig_h)
%
% - Apparently, the behaviour changed in R2014b when Matlab overhauled the
%   graphics. An algorithm was written using Java calls.
%
% - This became deprecated from R2019b, which is why a warning printed 
%   to the command window was suppressed in the classdef file for fig_spread:
%       >> warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
%   However, the algorithm continued to work.
%
% - From R2025a the JavaFrame property became obsolete. The original call
%       >> figure(fig_h)
%   appears to work. [Indeed, it seems to work for R2014b to R2024b in the
%   intended manner, but in case there are circumstances where that is not true
%   the Java algorithm has been retained]

if verLessThan('matlab','8.4')
    figure(fig_h);
    
elseif verLessThan('matlab','25.1')
    state = warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved');
    fJFrame = get(fig_h,'JavaFrame');
    drawnow expose
    jw = fJFrame.fHG2Client.getWindow();
    %
    if isjava(jw) % somethimes it is not recognized as java within 
                  % a running script while always recognized in debugger
        jw.setAlwaysOnTop(true);
        jw.setAlwaysOnTop(false);
    end
    warning(state)  % return warning to initial state
    
else
    figure(fig_h);
end

function horace_welcome
% Print welcome window to Horace

% Read in Horace figure (300 x 594 pixels)
horace_picture=imread('T:\SVN_area\Horace_sqw\documentation\300px-Quintus_Horatius_Flaccus.jpg','jpg');
im_wid=300; im_ht=594;

% Read in ISIS logo
[isis_logo,colmap]=imread('T:\SVN_area\Horace_sqw\documentation\isislogo_small.gif','gif');
isis_wid=size(isis_logo,2);
isis_ht=size(isis_logo,1);
grayscale = 0.2989*colmap(:,1) + 0.5870*colmap(:,2) + 0.1140*colmap(:,3);   % convert to gray scale

isis_logo=grayscale(isis_logo+1);
clo=min(isis_logo(:)); chi=max(isis_logo(:));
glo=0; ghi=0.8; % rgb=[0.8,0.8,0.8] seems to be standard matlab gray
isis_logo=((glo*chi-ghi*clo)+(ghi-glo)*isis_logo)/(chi-clo); % scale colour map
isis_logo(end,end)=1;                   % to enforce scaling when plotting later


% Get screen size
units_save = get(0,'Units');    % units of screen size
set(0,'Units','pixels');        % set units to pixels
scrsz = get(0,'ScreenSize');
set(0,'Units',units_save);      % reset units to whatever they were before

% Create figure for Horace welcome
wid=scrsz(3);   % width of screen in pixels
ht=scrsz(4);    % height of screen in pixels
fig_wid=700; fig_ht=650;

fig_pos = [(wid/2 - fig_wid/2) (ht/2 - fig_ht/2) fig_wid, fig_ht];
colordef white
h=figure('name','Horace','NumberTitle','off','MenuBar','none','Position',fig_pos,'Units','pixels');

set(gca,'Units','pixels')
im_offset=(fig_ht-im_ht)/2;
set(gca,'Position',[im_offset,im_offset,im_wid,im_ht])
image(horace_picture,'CDataMapping','scaled')
colormap('gray')
axis off


% Units of figure and axes are pixels; find distance from right edge of axes to right edge of figure,
% and add this to right of distance measured from axes origin

txt_x_cent=im_wid+(fig_wid-(im_offset+im_wid))/2; % centre line of remaining part of figure box in units of axes

txt_x_left=im_wid+75;

ht=text('string','HORACE','Position',[txt_x_cent,70],'FontSize',50,'FontAngle','normal',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','T.G. Perring, R.A. Ewings, J. van Duijn','Position',[txt_x_cent,150],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','ISIS Facility','Position',[txt_x_cent,200],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','STFC Rutherford Appleton Laboratory','Position',[txt_x_cent,220],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','Software to visualise and manipulate','Position',[txt_x_left,280],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','left','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','S({\bfQ},{\omega}) data from time-of-flight neutron','Position',[txt_x_left,300],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','left','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels','Interpreter','tex');

ht=text('string','spectrometers.','Position',[txt_x_left,320],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','left','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','For more information visit:','Position',[txt_x_left,360],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','left','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

ht=text('string','http://horace.isis.rl.ac.uk','Position',[txt_x_cent,380],'FontSize',10,'FontAngle','normal',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

% Caption to main Horace figure
ht=text('string','Quintus Horatius Flaccus  (65 BC - 8 BC)','Position',[im_wid/2,608],'FontSize',10,'FontAngle','italic',...
    'HorizontalAlignment','center','VerticalAlignment','middle',...
    'FontName','Helvetica','FontUnits','pixels');

% Now plot ISIS logo
axes
set(gca,'color',0.8*[1,1,1])    % seems to be standard matlab gray
set(gca,'Units','pixels')
set(gca,'Position',[fig_wid-im_offset-isis_wid,im_offset,isis_wid,isis_ht])
image(isis_logo,'CDataMapping','scaled')
axis off




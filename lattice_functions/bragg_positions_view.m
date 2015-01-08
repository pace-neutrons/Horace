function bragg_positions_view(wcut,wpeak)
% View the output of fitting to Bragg peaks performed by bragg_positions
%
%   >> bragg_positions_view(wcut,wpeak)
%
% This utility allows the cuts and peak analysis to be plotted together
% for each of the three cuts through all of the Bragg peaks that were passed
% to the function bragg_positions.
%
% The input arguments are the following two outputs from bragg_positions:
%
%   wcut            Array of cuts, size (n x 3),  along three orthogonal directions
%                  through each Bragg point from which the peak positions were determined
%                  The cuts are IX_dataset_1d objects and can be plotted using the plot
%                  functions for these methods.
%   wpeak           Array of spectra, size (n x 3), that summarise the peak analysis.
%                  Can be overplotted on the corresponding cuts in output argument wcut.
%                  The peak summaries are IX_dataset_1d objects and can be plotted using the plot
%                  functions for these methods.
%
%
%
% EXAMPLE OF USE:
%
%   >> [rlu0,width,wcut,wpeak]=bragg_positions(w, rlu,...)  % other arguments are needed
%   >> bragg_positions_view(wcut,wpeak)

% Check input
npk=size(wcut,1);
ncmp=size(wcut,2);
if numel(size(wcut))~=2 || npk<1 || ncmp~=3 || ~isequal(size(wcut),size(wpeak)) ||...
        ~isa(wcut,'IX_dataset_1d') || ~isa(wpeak,'IX_dataset_1d')
    error('Array of cuts and peak fits must both be (n x 3) arrays of IX_datset_1d objects.')
end

% Plot peaks
ipk=1; icmp=1;
plot_cut_peak(wcut(ipk,icmp),wpeak(ipk,icmp),ipk,icmp)
while true
    disp('---------------------------------------------------------------------------------')
    disp( 'Enter one of the following:')
    disp(['  - peak number (1-',num2str(npk),') and scan number (1-3) e.g. ',num2str(npk),',3'])
    disp(['  - <CR> to continue from present peak and scan (',num2str(ipk),',',num2str(icmp),')'])
    disp( '  - Q or q to quit');
    disp(' ')
    opt=input('Type option: ','s');
    if isempty(opt)
        icmp=icmp+1;
        if icmp>3
            ipk=ipk+1;
            icmp=1;
            if ipk>npk
                return
            end
        end
        % Plot:
        plot_cut_peak(wcut(ipk,icmp),wpeak(ipk,icmp),ipk,icmp)
    elseif any(strncmpi(opt,{'quit','exit'},numel(opt)))
        return
    else
        val=str2num(opt);
        if numel(val)==2 && all((round(val)-val)==0) && (val(1)>=1&&val(1)<=npk) && (val(2)>=1&&val(2)<=3)
            ipk=val(1);
            icmp=val(2);
            % Plot:
            plot_cut_peak(wcut(ipk,icmp),wpeak(ipk,icmp),ipk,icmp)
        else
            disp(' ')
            disp('*** INVALID INPUT. Try again:')
        end
    end
    disp(' ')
end

%-----------------------------------------------------------------------------
function plot_cut_peak(wcut,wpeak,ipk,icmp)
acolor b
dd(wcut)
acolor r
pl(wpeak)
text(0.05,0.8,['Peak: ',num2str(ipk),'  Scan: ',num2str(icmp)],'units','normalized')

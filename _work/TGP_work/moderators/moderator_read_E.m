function [x,y]= moderator_read_E(filename)


% this function takes a mcstas moderator file '*.mcstas' and plots the
% intensity v time (us) for a specified energy E, x=time(us) and y is
% intensity per us
Energy=[2:2:10];% wavelength values to look at moderator
Energy=sort(Energy,'ascend')


ts=1;te=600;% the start and end times of the moderator to look at in us
tbin=(0:2:600); % setup time bins taken from moderator
fid = fopen([filename],'r');

for loop=1:length(Energy);
    E=Energy(loop);
    count=0;
    flag=0;
    while flag==0;
        line1 = fgets(fid);
        fc=line1(1:6);
        TF = strcmpi(fc,'energy');
        if (TF==1);
            en = sscanf(line1,'%*s %*s %f %*s %f'); % contains the energy start and finish
            en=en.*1e9; %puts values into meV
            if (E >en(1) && E <= en(2));
                flag=1;
                line1 = fgets(fid);
                line1 = fgets(fid);
                t=0;
                while t< ts; % this finds the time > 1 us
                    line1 = fgets(fid);
                    dat=sscanf(line1,'%f %f %*s');
                    t=dat(1)/100;
                end
                while t <te; % this gets the data for time <te
                    line1 = fgets(fid);count=count+1;
                    dat=sscanf(line1,'%f %f %*s');
                    t=dat(1)/100; % time in us
                    time(count)=t; % time in us
                    inten(count)=dat(2); %intensity
                end
                n=[1:1:length(time)-1];
                delt=time(n+1)-time(n); % thes are the time intervals
                inten=inten(1:end-1);inten=inten./delt; % this divides by time to give data per us
                [N,edges,bin] = histcounts(time,tbin); %N is the number of counts in each time bin
                for I=1:length(tbin)-1 ; %loop around number of bins
                    flagbinmember=find(bin ==I);
                    binmean(I)=mean(inten(flagbinmember));
                end
                binmean=spline(tbin(1:end-1),binmean,tbin(1:end-1)); % gets rid of Nans and makes sure there is s point at every bin
                line1 = fgets(fid);
                x=tbin;y=binmean;
            end
            
            
        end
    end
    [FWHM,timenew,gembase]=single_peak_FWHM(x,y,ts,te,E);
    
    figure(1);
    a=ishold;
    if (a==0);
        hold;
    end
    m=max(gembase);gembase=gembase./m;
    plot(timenew,gembase);
    xlabel('time us');
    ylabel('Intensty');
    str=['Moderator profile(s)'];
    title(str);
    fw(loop)=FWHM;
end

figure
 plot(Energy,fw,'rs');
    xlabel('Energy (meV)');
    ylabel('FWHM');
    str=['Moderator ' filename ' FWHM us'];
    title(str);


function [FWHM,timenew,gembase]=single_peak_FWHM(x,y,ts,te,E);

x=x(1:end-1);
npeak=1; %the number of peaks to fit
tmin=ts; %min time to analyse data
tmax=te; % max time to analyse data

% program takes diffraction data output from Mcstas. Finds the peaks and
% normalises them all to a hefunction [x,y]=mcstas_plot(filename)

gembase= y;
lam=sqrt(81/E);
step=round(2*lam);



time=[tmin:step:tmax];% first time smooths the data
gembase=interp1(x,gembase,time,'cubic');
timenew=[tmin:2:tmax];
gembase=interp1(time,gembase,timenew,'cubic');

final=0.*gembase;
le=length(final);


peaks=find(max(gembase)==gembase);
peak=peaks(1);
a=timenew(peak);
den=gembase(peak);
final= gembase./den;
finalc=abs(final-0.5);




lam1=min(finalc(1:peak));
xlam1ind=find(finalc(1:peak)==lam1);
xlam1=timenew((xlam1ind));

lam2=min(finalc(peak:le));
xlam2ind=find(finalc(peak+1:le)==lam2)+peak;
xlam2=timenew((xlam2ind));

FWHM=abs(xlam1(1)-xlam2(1));  %this gets FWHM in u


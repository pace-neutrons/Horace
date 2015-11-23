function [xcoords,ycoords,zcoords,pts,ptlabs]=...
    calc_coverage_from_detpars(Ei,hw,omega_min,omega_max,detpar,u,v,alatt,angdeg)
%
% Calculate the coverage of reciprocal space of a Horace type angle sweep,
% using the instrument parameter file instead of a manually specified
% curtain of detectors.

% this is a modified version of the function which draws the plots,
% designed for use with the GUI. We choose not to draw the figures here,
% but have as outputs all of the variables that allow them to be drawn in
% the gui main function.


lam=sqrt(81.81/Ei);%neutron wavelength
if hw>Ei
    error('eps chosen is larger than Ei');
end

%Draw a circle which encloses the full reciprocal space
% figure;
% subplot(2,2,1);
% spac=circle([0,0],2*pi*2/lam,100,'-b');
% hold on;

kfhw=(0.6947*sqrt(Ei - hw));

centre=[-2*pi/lam,0];

%detpar=get_par(parfile);

%the angles given in the detpar file give a rotation in the equatorial
%plane (2theta), and then an azimuthal angle which is a rotation around the
%circle defined by 2theta.

tth=detpar.phi;
azi=detpar.azim;

%define angular width of pixel by looking at width (detpar.width) compared
%to x2
angwid=atand(detpar.width(1)/detpar.x2(1));

% tth=detpar(2,:);
% azi=detpar(3,:);
rho=kfhw.*ones(size(tth));

checkit=diff(azi);%difference in azimuthal angle between adjacent pixels in list

%We want to find where the difference is greater than say 3 - this would
%correspond either to a sign change, which is either the middle of a tube
%or the ends. Or if one has horizontal tubs (like MAPS) there is a big change
%between going from one end of the tube to the other.
%For the former we just have a couple of half tubes, which for
%drawing purposes is ok.

%New code
c1=find(abs(checkit) > 5);
%This is a list of ends / middles. But want the index immediateley after each of
%these. So in a loop make a new array where we interleave into ff:
ff=[1];
for i=1:numel(c1)
    ff=[ff c1(i) c1(i)+1];
end

%Old code
% test2=sign(checkit);%sign - there is a discontinuity in sign when we move to the next tube along
% test3=diff(test2);%where sign is the same, this is zero. Non-zero where not.
% ff=find(abs(test3)>0);%find indices of non-zeros
% ff=ff([2:2:end]);%these are the extremal edges of tubes
% 
%This bit then breaks each tube up into 16 sections
%ind=[round(linspace(1,ff(1),8))];
ind=[];
for i=1:2:length(ff)-1
    ind=[ind round(linspace(ff(i),ff(i+1),16))];
end

% ind=ff;

counter=1;
for i=linspace(omega_min,omega_max,30)
    %rotmat=[cosd(i) sind(i); -sind(i) cosd(i)];
    rotmat=[cosd(180+i) sind(180+i); -sind(180+i) cosd(180+i)];
    
    %Pixel centre positions
    X=rho.*cosd(tth);
    Y=(rho.*sind(tth)).*cosd(azi);
    Z=(rho.*sind(tth)).*sind(-azi);
    
    %Pixel vertices - because MAPS is a special case with horizontal tubes
    %the code needs to be clever enough to work out whether or not the tube
    %is vertical or horizontal. If vertical then vertices will be +/- X and
    %Y. If the horizontal then +/- X and Z (or Y and Z!!!). To sort this
    %out determine the line joining pairs of pixels that we count, then use
    %this to work out what sort of patch is required.
    
    
    %In order to have a plot that is not insane, we need to count a reduced
    %number of these pixels. To do so, we need to calculate their periodicity,
    %or just to take a fixed fraction of them...

    Xnew=X(ind);
    Ynew=Y(ind);
    Znew=Z(ind);
    
    coords=[Xnew+centre(1); Ynew+centre(2)];
    newcoords=rotmat*coords;
    newcoords=[newcoords; Znew];
    xcoords{counter}=newcoords(1,:); ycoords{counter}=newcoords(2,:); zcoords{counter}=Znew;
    
%     H{counter}=plot(newcoords(1,:),newcoords(2,:),'Color',jj(counter,:));
%     hold on;
    counter=counter+1;
end

%====================================
%Dots at reciprocal lattice pts (out of plane as well):

[bm,arlu,angrlu]=bmatrix(alatt,angdeg);
ub=ubmatrix(u,v,bm);

%Calculate the space that might be covered, in rlu
xlist=[floor((-2*pi*2/lam)./arlu(1)):eps+ceil((2*pi*2/lam)./arlu(1))];
ylist=[floor((-2*pi*2/lam)./arlu(2)):eps+ceil((2*pi*2/lam)./arlu(2))];
zlist=[floor((-2*pi*2/lam)./arlu(3)):eps+ceil((2*pi*2/lam)./arlu(3))];

counter=1;
pts=[];
for i=1:numel(xlist)
    for j=1:numel(ylist)
        for k=1:numel(zlist)
            qp=[xlist(i)*ub*[1,0,0]'] + [ylist(j)*ub*[0,1,0]'] + [zlist(k)*ub*[0,0,1]'];
            if sqrt(sum(qp.^2))<=2*pi*2/lam
                pts=[pts; qp'];
                ptlabs{counter}=num2str([xlist(i) ylist(j) zlist(k)]);
                counter=counter+1;
            end
        end
    end
end



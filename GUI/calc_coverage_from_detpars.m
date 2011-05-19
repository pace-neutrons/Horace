function [xcoords,ycoords,zcoords,pts]=...
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

%detpar=get_par_matlab_testing(parfile);

%the angles given in the detpar file give a rotation in the equatorial
%plane (2theta), and then an azimuthal angle which is a rotation around the
%circle defined by 2theta.

tth=detpar(2,:);
azi=detpar(3,:);
rho=kfhw.*ones(size(tth));

checkit=diff(azi);%difference in azimuthal angle between adjacent pixels in list
test2=sign(checkit);%sign - there is a discontinuity in sign when we move to the next tube along
test3=diff(test2);%where sign is the same, this is zero. Non-zero where not.
ff=find(abs(test3)>0);%find indices of non-zeros
ff=ff([2:2:end]);%these are the extremal edges of tubes

ind=[round(linspace(1,ff(1),16))];
for i=1:length(ff)-1
    ind=[ind round(linspace(ff(i),ff(i+1),16))];
end

jj=jet(30);
counter=1;
for i=linspace(omega_min,omega_max,30)
    rotmat=[cosd(i) sind(i); -sind(i) cosd(i)];
    
    X=rho.*cosd(tth);
    Y=(rho.*sind(tth)).*cosd(azi);
    Z=(rho.*sind(tth)).*sind(-azi);

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
areal=alatt(1)*[1,0,0]';
breal=alatt(2)*([cosd(angdeg(1)) -sind(angdeg(1)) 0; sind(angdeg(1)) cosd(angdeg(1)) 0; 0 0 1])*[1,0,0]';
aa=angdeg(3);
uvec=cross(breal,[0,0,1]);
uvec=uvec./norm(uvec);
rotmat_generic=[cosd(aa)+(uvec(1)^2)*(1-cosd(aa)),...
        (uvec(1)*uvec(2)*(1-cosd(aa)) - uvec(3)*sind(aa)),...
        (uvec(1)*uvec(3)*(1-cosd(aa)) + uvec(2)*sind(aa));...
        (uvec(2)*uvec(1)*(1-cosd(aa)) + uvec(3)*sind(aa)),...
        cosd(aa)+(uvec(2)^2)*(1-cosd(aa)),...
        (uvec(2)*uvec(3)*(1-cosd(aa)) - uvec(1)*sind(aa));...
        (uvec(3)*uvec(1)*(1-cosd(aa)) - uvec(2)*sind(aa)),...
        (uvec(3)*uvec(2)*(1-cosd(aa)) + uvec(1)*sind(aa)),...
        cosd(aa)+(uvec(3)^2)*(1-cosd(aa))];
creal=alatt(3)*rotmat_generic*(breal./alatt(2));    

as=2*pi*(cross(breal,creal))./(dot(areal,cross(breal,creal)));
bs=2*pi*(cross(creal,areal))./(dot(areal,cross(breal,creal)));
cs=2*pi*(cross(areal,breal))./(dot(areal,cross(breal,creal)));

%Next point is to work out how to draw the plane defined by u and v, and
%put reciprocal lattice points in the right places.

qpar=u(1).*as + u(2).*bs + u(3).*cs;
qperp=v(1).*as + v(2).*bs + v(3).*cs;
w=(cross(v',u'));
qoop=w(1).*as + w(2).*bs + w(3).*cs;

xlist=[floor((-2*pi*2/lam)/norm(qpar)):eps+ceil((2*pi*2/lam)/norm(qpar))];
ylist=[floor((-2*pi*2/lam)/norm(qperp)):eps+ceil((2*pi*2/lam)/norm(qperp))];
zlist=[floor((-2*pi*2/lam)/norm(qoop)):eps+ceil((2*pi*2/lam)/norm(qoop))];

pts=[];
for i=1:numel(xlist)
    for j=1:numel(ylist)
        for k=1:numel(zlist)
            if sqrt(sum((xlist(i).*qpar).^2) + sum((ylist(j).*qperp).^2) + sum((zlist(k).*qoop).^2))<=2*pi*2/lam
                newpt=[xlist(i)*norm(qpar) ylist(j)*norm(qperp) zlist(k)*norm(qoop)];
                %newpt=[xlist(i).*qpar'+ylist(j).*qperp'+zlist(k).*qoop'];
                pts=[pts; newpt];
            end
        end
    end
end
% plot(pts(:,1),pts(:,2),'ok','LineWidth',1,'MarkerSize',4);

%===
%Make the plot look a little bit nicer:
% set(gca,'DataAspectRatio',[1,1,1]);
% grid on;
% set(gca,'Layer','top');
% for i=1:numel(xcoords)
%     mmin(i)=min(zcoords{i});
%     mmax(i)=max(zcoords{i});
% end
% axis([-4*pi/lam 4*pi/lam -4*pi/lam 4*pi/lam min(mmin)-1 max(mmax)+1 ...
%     -0.2 0.2]);
% %note the title here is special case for IN5
% title(['Ei=',num2str(Ei),'meV, E=',num2str(hw),'meV, ',...
%     num2str(omega_min+180),'<psi<',num2str(omega_max+180)]);
% colormap jet
% colorbar
% caxis([omega_min,omega_max]);

%================================================

%Next step is to plot a side view as well:
%A cleverer way of showing the side view would be to use patches of the y
%and z co-ordinates.
% subplot(2,2,2);
% counter=1;
% for i=linspace(omega_min,omega_max,30)
%     plot(ycoords{counter},zcoords{counter},'Color',jj(counter,:));
%     hold on;
%     counter=counter+1;
% end
% 
% set(gca,'DataAspectRatio',[1,1,1]);
% grid on;
% set(gca,'Layer','top');
% hold on;
% plot(pts(:,2),pts(:,3),'ok','LineWidth',1,'MarkerSize',4);
% colormap jet
% colorbar
% caxis([omega_min,omega_max]);
% 
% %==========================================================================
% %Also plot view from bottom (of 1st panel):
% subplot(2,2,3);
% counter=1;
% for i=linspace(omega_min,omega_max,30)
%     plot(xcoords{counter},zcoords{counter},'Color',jj(counter,:));
%     hold on;
%     counter=counter+1;
% end
% 
% set(gca,'DataAspectRatio',[1,1,1]);
% grid on;
% set(gca,'Layer','top');
% hold on;
% plot(pts(:,1),pts(:,3),'ok','LineWidth',1,'MarkerSize',4);
% colormap jet
% colorbar
% caxis([omega_min,omega_max]);
% 
% 








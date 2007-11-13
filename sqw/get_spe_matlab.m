function [S,ERR,en] = get_spe_matlab(spe_filename)
% function [S,ERR,en] = get_spe_matlab(spe_filename)
% loads data from an ASCII .spe file   
% returns 
%             S (ndet,ne)[intensity in units as given by data.axislabel(4,:)] 
%             ERR (ndet,ne) [errors of .S, same units]
%             en (1,ne)[meV]    
%
% R.C. 24-July-1998
% 6-August-1998 incorporate field .det_group and .title
% I.Bustinduy Mon Aug 27 12:39:40 CEST 2007

% === if no input parameter given, return
if ~exist('spe_filename','var'),
   help get_spe;
   return
end

filename=deblank(spe_filename); % remove blancs from beginning and end of spe_filename
filename=fliplr(deblank(fliplr(filename)));
% === if error opening file, return
fid=fopen(filename,'rt');
if fid==-1,
   disp(['Error opening file ' filename ' . Data not read.']);
   data=[];
   return
end
fclose(fid);

fid=fopen(filename,'rt');
% === read number of detectors and energy bins
ndet=fscanf(fid,'%d',1);   % number of detector groups 
ne=fscanf(fid,'%d',1);  % number of points along the energy axis
temp=fgetl(fid);	% read eol
%disp([num2str(ndet) ' detector(s) and ' num2str(ne) ' energy bin(s)']);
drawnow;

% === read 2Theta scattering angles for all detectors
temp=fgetl(fid);	% read string '### Phi Grid'
det_theta=fscanf(fid,'%10f',ndet+1); % read phi grid, last value superfluous
det_theta=det_theta(1:ndet)*pi/180;  % leave out last value and transform degrees --> radians
temp=fgetl(fid);	% read eol character of the Phi grid table
temp=fgetl(fid);	% read string '### Energy Grid'
en=fscanf(fid,'%10f',ne+1); % read energy grid
en=(en(2:ne+1)+en(1:ne))/2; % take median values, centres of bins

S=zeros(ndet,ne);
ERR=S;

for i=1:ndet,
   temp=fgetl(fid);
   %while isempty(temp)|isempty(findstr(temp,'### S(Phi,w)')),
   temp=fgetl(fid);			% get rid of line ### S(Phi,w)
   %end
   temp=fscanf(fid,'%10f',ne);
   S(i,:)=transpose(temp);
   temp=fgetl(fid);
   %while isempty(temp),
   %   temp=fgetl(fid),			
   %end
   temp=fgetl(fid);
   temp=fscanf(fid,'%10f',ne);
   ERR(i,:)=transpose(temp);   
end
fclose(fid);

% BUILD UP DATA STRUCTURE 
en=en;
S=S';
ERR=ERR';

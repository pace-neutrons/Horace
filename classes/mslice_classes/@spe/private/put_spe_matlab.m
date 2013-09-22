function [ok,mess]=put_spe_matlab(data,file)
% Writes ASCII .spe file
%   >> [ok,mess,filename,filepath]=put_spe(data,file)
%
% data has following fields:
%   data.filename   Name of file excluding path
%   data.filepath   Path to file including terminating file separator
%   data.S          [ne x ndet] array of signal values
%   data.ERR        [ne x ndet] array of error values (st. dev.)
%   data.en         Column vector of energy bin boundaries
%
% Output:
% -------
%   ok              True if all OK, false otherwise
%   mess            Error message; empty if ok=true

% T.G.Perring 2 Jan 2008 - based on R.Coldea's save_spe
%
% Corrections to account for IEEE format on non-VMS machines.
% Write spe file. Note that on PC systems, numbers are written with three digits in the exponent
% e.g. -1.234E+007. It turns out that with format %-10.4G that Matlab will always give 4 sig. fig.,
% so that the result is an 11 character string if exponent form is needed. This will cause the spe
% file read routines to break. This is why in the following there is a test for PC (windows) - see
% sprintf documentation
%
% 15 Aug 2009: modified to make write consistent with matlab write as far as can.
%
% 9 Sep 2013: Seems that the exponent is no longer always written as Esnnn  (s= + or -, nnn three
% digits. Make the test now that three digits are written, not ispc.


ok=true;
mess='';

% It is assumed that before entry have already performed:
% --------------------------------------------------------
% null_data = -1.0e30;    % conventional NaN in spe files
% index=~isfinite(data.S)|data.S<=null_data|~isfinite(data.ERR);
% if sum(index(:)>0)
%     data.S(index)=null_data;
%     data.ERR(index)=0;
% end

% But further changes to S, ERR will be required for the matlab write to work if
% the .spe convention of 10 characters per entry is to be adhered to.
small_data = 1.0e-30;
big_data = 1.0e30;

data.S(data.S>big_data)=big_data;
data.S(abs(data.S)<small_data)=0;
data.ERR(data.ERR>big_data)=big_data;
data.ERR(abs(data.ERR)<small_data)=0;


% Now ready to write:
% --------------------
fid = fopen (file, 'wt');
if (fid < 0)
    ok=false;
    mess=['ERROR: cannot open file ' file];
    return
end

ne=size(data.S,1);
ndet=size(data.S,2);

% === write ndet, ne
fprintf(fid,'%-8d %-8d \n',ndet,ne);    

% === write phi grid (unused)
phi_grid=zeros(1,(ndet+1));
fprintf(fid,'%s\n','### Phi Grid');
fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',phi_grid(:));
if rem(ndet+1,8)~=0,
    fprintf(fid,'\n');
end

% === write energy grid
en_grid=round(data.en*1e5)/1e5;	%truncate at the 5th decimal point
fprintf(fid,'%s\n','### Energy Grid');
fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',en_grid(:));
if rem(ne+1,8)~=0,
  	fprintf(fid,'\n');
end

% === write S(det,energy) and ERR(det,energy)
% Test if thriple digit exponent guaranteed
triple_exp=(12-strfind(sprintf('%13.4E',-4.01e2),'E')==3);
for i=1:ndet
    fprintf(fid,'%s\n','### S(Phi,w)');
    if triple_exp
        for j=1:8:ne
            temp = sprintf('%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E',data.S(j:min(j+7,ne),i));
            temp = strrep(strrep(temp, 'E+0', 'E+'), 'E-0', 'E-');
            fprintf(fid,'%s\n',temp);
        end
    else
        fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',data.S(:,i));
        if rem(ne,8)~=0,
            fprintf(fid,'\n');
        end
    end
    fprintf(fid,'%s\n','### Errors');
    if triple_exp
        for j=1:8:ne
            temp = sprintf('%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E%+11.3E',data.ERR(j:min(j+7,ne),i));
            temp = strrep(strrep(temp, 'E+0', 'E+'), 'E-0', 'E-');
            fprintf(fid,'%s\n',temp);
        end
    else
        fprintf(fid,'%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G%-10.4G\n',data.ERR(:,i));
        if rem(ne,8)~=0,
            fprintf(fid,'\n');
        end
    end
end
fclose(fid);

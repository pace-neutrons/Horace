function [cut,ok,mess]=get_cut(filename)
% Read a cut file with all pixel information (.cut or Mfit .cut)
%
%   >> [cut,ok,mess]=get_cut(filename)
%
%   filename        Name of file from which to read cut
%
%   cut             Structure with the fields described below
%   ok              =true if all OK; =false otherwise
%   mess            ='' if OK==true error message if OK==false
%
%
% Contents of cut structure:
% ---------------------------
% - If succesfully read, then will contain fields:
%
%         x: [1xn double]
%         y: [1xn double]
%         e: [1xn double]
%   npixels: [1xn double]
%    pixels: [mx6 double], m=sum(npixels(:)). COntains, for each pixel:
%                 detector_index, hbarw_centre, delta_hbarw, x, signal, error
%   x_label: '[ Q_h, 0, 3 ]  in 2.894 Å^{-1}, <Q_vert>=0.00084693 <Q_l>=3.0052'
%   y_label: 'Intensity (abs. units)'
%     title: {'map02114.spe, , Ei=447 meV'  [1x56 char]  [1x54 char]}
%   CutFile: 'bog.cut'
%    CutDir: 'c:\temp\'
%
% - Additionally, footer information in the file of the form <label> = <value> will be added as fields
%  to an appendix
%      e.g.  as = 2.507    results in the field:     appendix.as = '2.507'
%   Multiple occurences of a label result in the created field being a cellarray of strings
%
% - For a valid cut, not all fields will be permitted. Check_fields.m is the ultimate arbiter,
%   but as of 6/8/09 the only valid options are:
%
%    .cut single crystal cut:
%    -------------------------
%     title, x_label, y_label constructed by this routine
%     CutFile, CutDir created by this routine
%     appendix is empty structure
%
%    mfit single crystal cut:
%    ------------------------
%     title, x_label, y_label read from footer
%     CutFile, CutDir created by this routine
%
%     appendix contains fields:
%
%      MspFile: 'crystal_psd.msp'
%       MspDir: 'T:\matlab\mslice\ver2007a\mslice\mslice\'
%       efixed: '250'
%        emode: '1'
%       sample: '1'
%           as: '5.354'
%           bs: '13.153'
%           cs: '5.401'
%           aa: '90'
%           bb: '90'
%           cc: '90'
%           ux: '1'
%           uy: '0'
%           uz: '0'
%           vx: '0'
%           vy: '1'
%           vz: '0'
%     psi_samp: '98.5'

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(filename);

% Read file
try
    [x,y,e,npixels,pixels,footer]=get_cut_mex(file_tmp);
    cut.x=x'; cut.y=y'; cut.e=e'; cut.npixels=npixels'; cut.pixels=pixels';
    % Read footer information
    appendix=get_labels_to_struct(footer);
catch
    try     % try matlab algorithm
        disp(['Matlab loading of .cut file : ' file_tmp]);
        % Open file for reading
        fid=fopen(file_tmp,'rt');
        if fid==-1,
            error(['Error opening file ' file_tmp ]);
        end
        % Read x,y,e and complete pixel information
        n=fscanf(fid,'%d',1);	% number of data points in the cut
        cut.x=zeros(1,n);
        cut.y=zeros(1,n);	% intensities
        cut.e=zeros(1,n);	% errors
        cut.npixels=zeros(1,n);
        cut.pixels=[];      % pixel matrices
        for i=1:n,
            temp=fscanf(fid,'%g',4);
            cut.x(i)=temp(1);
            cut.y(i)=temp(2);
            cut.e(i)=temp(3);
            cut.npixels(i)=temp(4);
            d=fscanf(fid,'%g',6*cut.npixels(i));
            cut.pixels=[cut.pixels;reshape(d,6,cut.npixels(i))'];
        end
        % Read footer information
        appendix=get_labels_to_struct(fid);
        fclose(fid);
    catch
        ok=false;
        mess='Unable to read cut from file.';
        return
    end
end

% Move fields into appendix, if one is present
if isempty(appendix)
    %     disp('Have reached the end of file without finding any information appended.');
    [pathname,file,ext]=fileparts(file_tmp);
    cut.x_label='x coordinate of cut';
    cut.y_label='Intensity';
    cut.title=avoidtex([file,ext]);
    cut.CutFile=[file,ext];                 % If no labels, then Radu *does not* avoidtex the CutFile
    cut.CutDir=[pathname,filesep];          % If no labels, then Radu does not return the CutDir
    return;
else
    movefields={'x_label','y_label','title'};   % Because we move x-label, y_label, title in that order, the order these fields appear in the appendix is irrelevant
    ind=isfield(appendix,movefields);
    for i=find(ind)
        cut.(movefields{i})=appendix.(movefields{i});
    end
    appendix=rmfield(appendix,movefields(ind));
    [pathname,file,ext]=fileparts(file_tmp);
    cut.CutFile=[file,ext];                 % If labels, then Radu *does* avoidtex the CutFile
    cut.CutDir=[pathname,filesep];          % If labels, then Radu returns the CutDir
    % Invert order of MspDir and MspFile to match that of cut object structure, if necessary
    appnames=fieldnames(appendix);
    if numel(appnames)>=2 && all(strcmp(appnames(1:2),{'MspDir';'MspFile'}))
        perm=1:numel(appnames); perm(1)=2; perm(2)=1;
        appendix=orderfields(appendix,perm);
    end
    cut.appendix=appendix;
end

disp(['Loaded .cut ( ' num2str(numel(cut.npixels)) ' data points and ' num2str(size(cut.pixels,1)) ' pixels) from file : ']);
disp(file_tmp);

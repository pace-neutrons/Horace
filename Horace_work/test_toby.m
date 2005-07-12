msp = 'c:\temp\horace\ei40.msp';
data_in_dir = 'c:\temp\horace'
fin = 'c:\temp\horace\tbmno3_files.txt';
fout= 'c:\temp\horace\tbmno3.bin';
u1 = [1,0,0];
u2 = [0,1,0];
u3 = [0,0,1];

tic
gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u3);
toc




fid= fopen('c:\temp\horace\tbmno3.bin', 'r');    % open spebin file
h_main = get_header(fid);   % get the main header information
fclose(fid);


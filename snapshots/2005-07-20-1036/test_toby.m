%--------------------------------------------------------
msp = 'c:\temp\horace\ei40.msp';
data_in_dir = 'c:\temp\horace';
fin = 'c:\temp\horace\test.txt';
fout= 'c:\temp\horace\test.bin';
u1 = [1,0,0];
u2 = [0,1,0];
u3 = [0,0,1];

tic
gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u3);
toc

tic
d4d = slice_4d ('c:\temp\horace\test.bin', [0,1,0], [0,0,1],...
    [0,0,0,0], [-2,0.2,2], [-2,0.2,2], [-2,0.2,2], 'rrr')
toc

%--------------------------------------------------------
% Read in the Rb2MnF4 data to slice
msp = 'G:\experiments\Rb2MnF4\rb2mnf4_2651_psd.msp';
data_in_dir = 'G:\experiments\Rb2MnF4'
fin = 'c:\temp\sliceomatic.txt';
fout= 'c:\temp\Rb2MnF4.bin';
u1 = [0,1,0];
u2 = [1,0,0];
u3 = [0,0,1];

tic
gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u3, 'bing', 'bang', 'bong');
toc
%--------------------------------------------------------


fid= fopen('c:\temp\horace\tbmno3.bin', 'r');    % open spebin file
h_main = get_header(fid);   % get the main header information
fclose(fid);


hor_path = 'd:\users\abuts\SVN\ISIS\Horace_153'

horace_on(hor_path)
cd(fullfile(hor_path,'_test\test_sqw_file'));

x = input('enter something after attaching to the matlab');
runtests test_sqw_reader
%tr=test_sqw_reader('t1');
%tr.test_read_pix_buf_mex_multithread();
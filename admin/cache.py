#!/usr/bin/python
#
import multiprocessing
from itertools import count
import time
import sys
import argparse

class progress_rep:
    """ report progress """
    def __init__(self,all_size,n_threads=None):
        self._all_size = all_size
        self._tick_size = all_size/100
        if n_threads is None:
            self._n_threads = 1
        else:
            self._n_threads = n_threads

        self._tick_cnt = 0
        self._tick_barrier = self._tick_size
        self._prev_size = 0
        self._start_time = time.time()
        self._prev_time = self._start_time
        self._run_time  = self._start_time
    #
    def check_progress(self,cur_size):
        """ check current progress and report if boundaries are set up"""

        self._tick_cnt += 1
        if cur_size >=self._tick_barrier:
            self._report_progress(cur_size)
            self._tick_barrier += self._tick_size
    #
    def _report_progress(self,cur_size):
            pers = 100*float(cur_size)/float(self._all_size);
            self._prev_time  = self._run_time
            self._run_time   = time.time()
            tot_size = float(cur_size*self._n_threads)/(1024*1024)
            block_size = float(cur_size - self._prev_size)*self._n_threads/(1024*1024)
            tot_time = self._run_time-self._start_time
            block_time = self._run_time-self._prev_time
            Av_speed = tot_size / tot_time
            Loc_speed = block_size / block_time
            sys.stdout.write(\
                "Read: {0:.1f}MB Completed: {1:3.1f}% Av Speed: {2:3.2f}MB/s: Loc speed: {3:3.2f}MB/s\r"\
                .format(tot_size,pers,Av_speed,Loc_speed))
            sys.stdout.flush()
            self._prev_size = cur_size

def read_chunk(filename,start,size,buf_size,progress,n_workers):
    """ read (and discard) chunk of binary data"""
    success=False
    if progress:
        prog_rep = progress_rep(size,n_workers)
        
    fh = open(filename,'rb')
    if fh<0:
        raise ValueError("Can not open file: "+filename)
    fh.seek(start,0)
    block = buf_size
    got   = 0
    with open(filename, "rb") as f:
        while got < size:
            bl = fh.read(block)
            got = got+block
            if got+block> size:
                block = size-got
            if progress:
                prog_rep.check_progress(got)
    if progress:
       print ""
    success=True
    return success


def process_file(argi):
    """ """
    filename = argi['filename']
    n_threads = argi['nthreads']
    buf_size = argi['buffer']

    fh = open(filename,'rb')
    if fh<0:
        raise ValueError("Can not open file: "+filename)
    fh.seek(0,2);
    file_size = fh.tell()
    #print 'File size=',nbytes
    fh.close()

    block_size = int(file_size/n_threads)+1
    chunk_size = []
    chunk_beg = []
    start_ch = 0
    end_ch   = block_size
    if buf_size == 0:
        buf_size = block_size
    if buf_size > sys.maxint/1024:
        buf_size = sys.maxint/1024

    for i in xrange(0,n_threads):
        if end_ch > file_size:
            block_size = file_size-start_ch
        chunk_size.append(block_size)
        chunk_beg.append(start_ch)
        start_ch = end_ch;
        end_ch   = end_ch+block_size;
    #---------------------------------------------------------------------------------------------

    job_list = [];
    #read_chunk(filename,chunk_beg[0],chunk_size[0],buf_size,True,n_threads)
    for nthr in xrange(n_threads):
        if nthr == 0:
            log=True
        else:
            log=False
        p = multiprocessing.Process(target=read_chunk, args=(filename,chunk_beg[nthr],chunk_size[nthr],buf_size,log,n_threads,))
        p.start()
        job_list.append(p)
    #
    for p in job_list:
        p.join();


if __name__ == '__main__':
    """Read file using multiple threads to place file into CEPH cashe"""

    parser = argparse.ArgumentParser(add_help=True, version='0.1',description='Read file using multiple threads to place file into CEPH cashe')
    parser.add_argument('filename',action='store', type=str,default="",help='file to read to cashe')
    parser.add_argument('-n',action='store', dest='nthreads',type=int,default=16,help='number of threads to process file. Default is 16 threads')
    parser.add_argument('-b',action='store', dest='buffer',type=int,default=4096,help='Buffer size to read each chunk of data. Default is 4096 bytes.')

    args = vars(parser.parse_args())
    process_file(args)

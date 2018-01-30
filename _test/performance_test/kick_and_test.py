#!/usr/bin/python
#
import multiprocessing
import threading
import time
import os,sys
import argparse
import numpy
# Emulate multithreaded Horace workflow to check CEPH validity

class arr_holder(threading.Thread):
    """ Class to generate test data"""

    def __init__(self,n_chunk=0,chunk_size=1024,n_chunks=None):
        threading.Thread.__init__(self,group=None,target=None,name='TestDataGenerator')

        self.rc = 0
        self.data_lock = threading.Condition()
        self.write_lock= threading.Condition()
        self.generating = True
        self.ready_to_write = False


        self.reset_data(n_chunk,chunk_size,n_chunks)

    def reset_data(self,n_chunk,chunk_size,n_chunks):
        self._chunk_size = chunk_size
        self._arr_holder = []

        if n_chunks is None:
            n_chunks = 1
        self._n_chunks = n_chunks
        #
        self.gen_test_data(666)


    def gen_test_data(self,n_chunk):
        numpy.random.seed(n_chunk)
        tmp = self._arr_holder
        if n_chunk % 2 == 0:
            self._arr_holder = numpy.random.normal(-1,1,self._chunk_size);
        else:
            self._arr_holder = numpy.ones(self._chunk_size)*n_chunk;

        return tmp;

    def swap(self,other_arr=None):

        tmp = self._arr_holder
        if other_arr:
            self._arr_holder = other_arr
        else:
            self._arr_holder = []
        #self.data_lock.notify()
        return tmp

    def run(self):
       for nch in xrange(0,self._n_chunks):
           while self.generating:
                self.data_lock.acquire()
                self.gen_test_data(nch)
                #print('generated ChN: {0}'.format(nch))
                self.generating = False
                self.data_lock.release()
           self.write_lock.acquire()
           self.ready_to_write = True
           self.write_lock.release()

           while not self.generating :
               try:
                   self.data_lock.wait()
               except RuntimeError:
                   pass
       self.write_lock.acquire()
       self.ready_to_write = True
       self.write_lock.release()
       return


class check_file_thread_wrapper(threading.Thread):
    """ wrapper around check file to run it in the thread loop"""
    total_check = True

    def __init__(self,filename,file_size,chunk_size,n_processes):
        threading.Thread.__init__(self,group=None,target=None,name = 'testing_file:{0}'.format(filename))
        #
        self._filename = filename
        self._file_size = file_size
        self._chunk_size = chunk_size
        self._n_processes = n_processes

    def run(self):
        if not check_file_thread_wrapper.total_check:
            raise IOError("Error checking previous file on another thread")
        print(" Checking file: {0}".format(self._filename))
        ok = True
        try:
            ok = check_file(self._filename,self._file_size,self._chunk_size,self._n_processes)
        except ValueError:
            check_file_thread_wrapper.total_check = False
            raise
        if not ok:
            check_file_thread_wrapper.total_check = False
            raise IOError("Error when testing file {0}".format(self._filename))
        return



#


def write_test_file(filename,fielsize,chunk_size):
    """ Write test data file"""

    fd = open(filename,'wb')
    if fd<0:
        raise RuntimeError("Can not open test file %s".format(filename))
    n_chunks = fielsize/chunk_size

    input_data = arr_holder(0,chunk_size,n_chunks)
    #input_data.reset_data(0,chunk_size,n_chunks)
    input_data.generating = True
    input_data.start()
    #input_data.run()
    while input_data.generating:
       pass

    time1= time.time()
    size1 = 0
    tot_size = float(n_chunks*chunk_size*8)/(1024*1024)

    for n_ch in xrange(0,n_chunks):
        input_data.data_lock.acquire()
        test_data = input_data.swap()
        input_data.generating = True
        input_data.data_lock.release()
        try:
          input_data.data_lock.notify()
        except RuntimeError:
          pass

        while not input_data.ready_to_write:
            pass
        fd.write(test_data)
        input_data.write_lock.acquire()
        input_data.ready_to_write = False
        input_data.write_lock.release()

        #print 'nch=',n_ch,' td=',test_data[0:5]
        cur_size = float(n_ch*chunk_size*8)/(1024*1024)
        pers     = 100*cur_size /tot_size
        cur_time = time.time()
        ds = cur_size - size1
        dt = cur_time - time1
        Wr_speed = ds / dt
        sys.stdout.write(\
           "file: {0} Written: {1:.1f}MB Completed: {2:3.1f}% Write Speed: {3:3.2f}MB/s\r"\
           .format(filename,cur_size,pers,Wr_speed))
        sys.stdout.flush()
        size1 = cur_size
        time1 = cur_time


    input_data.generating = True
    fd.close()
    input_data.join()
    sys.stdout.write("\n")
    sys.stdout.flush()



def chunk_wrapper(pout,filename,chunk_num,chunk_size,n_chunks):
    """ multiprocessing piped wrapper around read_and_test_chunk"""
    ok,n_faling_chunk = read_and_test_chunk(filename,chunk_num,chunk_size,n_chunks)
    pout.send([ok,n_faling_chunk])
    pout.close()

def read_and_test_chunk(filename,chunk_num,chunk_size,n_chunks):
    """ read and verify chunk of binary data.

        Used for read data in a single thread.
        Inputs:
        filename -- name of the binary file to read
        start    -- initial position to read data from
        size     -- the number of bytes to read from the file
        buf_size -- the size of the buffer to use while reading the data
        progress -- True if progress messages should be printed and False if not
        n_workers -- number of threads to read file. Used to estimate the progress
                    of multithreaded job.
    """
    success=False
    checker = arr_holder(0,chunk_size)

    fh = open(filename,'rb')
    if fh<0:
        raise ValueError("Can not open file: "+filename)
    start = chunk_num*chunk_size*8L
    fh.seek(start,0)
    with open(filename, "rb") as f:
        for nch in xrange(chunk_num,chunk_num+n_chunks+1):
            data = numpy.frombuffer(fh.read(chunk_size*8));
            checker.gen_test_data(nch)
            sample = checker.swap()
            ok = numpy.array_equal(sample,data)
            if not ok:
                return (False,nch)
    return (True,0)


def check_file(filename,file_size,chunk_size,n_threads):
    """ Read special file using multiple threads and check file integrity 

        Input:
        dictionary, generated by ArgumentParser, containing the
        name of the file to read and some auxiliary information
        about reading job parameters.
    """

    # Estimate the file size
    fh = open(filename,'rb')
    if fh<0:
        raise ValueError("Can not open file: "+filename)
    fh.close()

    # Evaluate the parameters of the file reading jobs.
    n_chunks = file_size/chunk_size
    n_chunks_per_thread = int(n_chunks/n_threads)
    nch_per_thread = [n_chunks_per_thread]*n_threads
    n_chunks_tot_distr = numpy.sum(nch_per_thread)

    for i in xrange(0,n_threads):
        if n_chunks_tot_distr < n_chunks :
            nch_per_thread[i] = nch_per_thread[i]+1
            n_chunks_tot_distr= n_chunks_tot_distr+1
        else:
            break
    start_chunk_num = numpy.append([0],numpy.cumsum(nch_per_thread))

    #---------------------------------------------------------------------------------------------
    # Start parallel jobs:
    job_list  = []
    result_p  = []
    #read_chunk(filename,chunk_beg[0],chunk_size[0],buf_size,True,n_threads)
    for nthr in xrange(n_threads):
        if nthr == 0:
            log=True
        else:
            log=False
        parent_conn, child_conn = multiprocessing.Pipe()
        p = multiprocessing.Process(target=chunk_wrapper, args=(child_conn,filename,start_chunk_num[nthr],chunk_size,nch_per_thread[nthr]-1,))
        p.start()
        result_p.append(parent_conn)
        job_list.append(p)
    # Wait for jobs to finish.
    ok = True
    for p,proc_out in zip(job_list,result_p):
        out = proc_out.recv()
        if not out[0]:
            ok = False
            print('file: {0} Error reading chunk N:{1}'.format(filename,out[1]))
        p.join()
    return ok
#------------------------------------------------

if __name__ == '__main__':
    """test io operations over large files on CEPH"""

    parser = argparse.ArgumentParser(add_help=True, version='0.1',description='test Horace-like IO operations on CEPHs')
    parser.add_argument('-nthreads',action='store', dest='n_threads',type=int,default=8,help='number of threads to process file. Default is 16 threads')
    parser.add_argument('-buffer',action='store', dest='buffer',type=int,default=10000000,help='Horace buffer size to read/write each chunk of data.'+ \
            'Expressed in Horace "pseudopixels" with default  10^7 pseudopixels. One pseudopixel occupies 40 bytes.')
    parser.add_argument('-nchunks',action='store', dest='n_chunks',type=int,default=250,help='Number of chunks (buffers) to write. Default 250. Test file size is equal to n_chunks*buffer.')
    parser.add_argument('-nfiles',action='store', dest='n_files',type=int,default=100,help='Number of files to test. (write and read) Default -- 100')


    args = vars(parser.parse_args())
    #process_file(args)
    #chunk_size = 5*10000000
    chunk_size = args['buffer']*5
    filesize   = args['n_chunks']*chunk_size
    nthreads   = args['n_threads']
    n_files    = args['n_files']

#    write_test_file("test_file.tmp",filesize,chunk_size)
#    ok=read_and_test_chunk("test_file.tmp",75,chunk_size,25)
    #ok = check_file("test_file.tmp",filesize,chunk_size,4)
    #if not ok:
    #    raise IOError("Errors in file")
    filelist = map(lambda i: 'test_file{0:0>3}.tmp'.format(i),range(0,n_files))
    write_test_file(filelist[0],filesize,chunk_size)
    for ind in xrange(1,n_files):
        checker = check_file_thread_wrapper(filelist[ind-1],filesize,chunk_size,nthreads)
        checker.start()

        write_test_file(filelist[ind],filesize,chunk_size)
        checker.join()
        checker = []
        try:
            os.remove(filelist[ind-1])
        except:
            pass
    #---------------------------------
    ok = check_file(filelist[n_files-1],filesize,chunk_size,nthreads)
    try:
        os.remove(filelist[n_files-1])
    except:
        pass
    if not ok:
        raise IOError("Errors in file {0}".format(filelist[n_files-1]))
    else:
        print ("Successfully wrote and verified {0} test files".format(n_files))
        for fl in filelist:
            try:
                os.remove(fl)
            except:
                pass

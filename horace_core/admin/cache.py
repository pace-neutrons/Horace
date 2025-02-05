#!/usr/bin/env python3
"""
Read file using multiple threads to place file into CEPH cache.
"""
import argparse
import functools
import multiprocessing
import os
import sys
import time

from typing import Tuple

__version__ = "0.1"

if sys.version_info < (3, 6):
    raise SystemError("%s requires at least Python 3.6" % sys.argv[0])


def report_progress(bytes_read: int, prev_time: float, prev_mbytes: int,
                    start_time: float, total_size: int,
                    thread_id: int, nthreads: int) -> Tuple[float, int]:
    """ Local function to report timings """
    curr_time = time.time()
    tot_time = curr_time - start_time
    block_time = curr_time - prev_time

    mbytes_read = bytes_read // 1024**2

    # Estimate based on local read rate
    av_speed = (mbytes_read*nthreads) / tot_time
    loc_speed = (mbytes_read - prev_mbytes) / block_time

    print(f"{thread_id}: "
          f"Read: {mbytes_read:.1f} MB "
          f"Completed: {bytes_read/total_size:3.1%} "
          f"Av Speed: {av_speed:3.2f} MB/s "
          f"Loc speed: {loc_speed:3.2f} MB/s", flush=True)
    return curr_time, mbytes_read


def read_chunk(start: int, size: int, thread_id: int,
               filename: os.PathLike, buffer_size: int, nthreads: int):
    """ read (and discard) chunk of binary data.

        Used for read data in a single thread.
        Inputs:
        start    -- initial position to read data from
        size     -- the number of bytes to read from the file
        thread_id -- Index of local thread
        filename -- name of the binary file to read
        buffer_size -- the size of the buffer to use while reading the data
        nthreads -- number of threads to read file. Used to estimate the progress
                    of multithreaded job.
    """

    # Set up for multi-threaded logging, would need extra CLI arg
    log = thread_id == 0

    if log:
        prev_time = time.time()
        prev_mbytes = 0
        report = functools.partial(report_progress,
                                   start_time=prev_time, nthreads=nthreads,
                                   total_size=size, thread_id=thread_id)

    with open(filename, 'rb', buffering=0) as file:
        file.seek(start)

        for bytes_read in range(0, size, buffer_size):
            block = min(buffer_size, size - bytes_read)
            file.read(block)
            if log and time.time() - prev_time > 0.2:
                prev_time, prev_mbytes = report(bytes_read, prev_time, prev_mbytes)

        if log:
            report(size, prev_time, prev_mbytes)


def process_file(filename: os.PathLike, nthreads: int, buffer_size: int):
    """ Read binary file using multiple threads """

    # Estimate the file size
    file_size = os.path.getsize(filename)
    print(f'File size={file_size//(1024**3):.0f}GB')

    # Evaluate the parameters of the file reading jobs.
    block_size, remainder = divmod(file_size, nthreads)

    chunk_size = [block_size] * (nthreads-1)
    chunk_size.append(remainder if remainder else block_size)

    chunk_beg = [block_size*i for i in range(nthreads)]

    if buffer_size <= 0:
        buffer_size = block_size
    buffer_size = min(buffer_size, sys.maxsize // 1024)

    # Assign constants to function
    map_chunk = functools.partial(read_chunk, filename=filename,
                                  buffer_size=buffer_size, nthreads=nthreads)

    with multiprocessing.Pool(nthreads) as pool:
        pool.starmap(map_chunk, zip(chunk_beg, chunk_size, range(nthreads)))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(add_help=True,
                                     description='Read file using multiple threads to place file into CEPH cache',
                                     formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument('filename', type=str, help='file to read for caching in CEPHS')
    parser.add_argument('--nthreads', '-n', type=int, default=16, help='number of threads to process file.')
    parser.add_argument('--buffer', '-b', dest='buffer_size', type=int, default=4096, help='Buffer size to read each chunk of data.')
    parser.add_argument('--version', '-V', action='version', version=__version__)

    args = parser.parse_args()
    process_file(**vars(args))

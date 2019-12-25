#pragma once
#include <vector>
#include <list>
#include <cmath>
#include <mpi.h>

class SendMessHolder {
public:
    MPI_Request theRequest;
    int mess_tag;
    int destination;
    std::vector<uint8_t> mess_body;
   //
    //SendMessHolder(SendMessHolder&& other) noexcept;
    SendMessHolder() :
        theRequest(0), mess_tag(0), destination(0) {}
    SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
    void init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
};

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

    MPI_wrapper() :
        labIndex(-1), numProcs(0), isTested(false),
        assynch_queue_max_len_(10), assynch_mess_num_(0) {}
    int init(bool isTested = false,int assynch_queue_max_len=10);
    void close();
    void barrier();
    void send(int data_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer);

    ~MPI_wrapper() {
        this->close();
    }
    // index of the current MPI lab (worker)
    int labIndex;
    // total  number of MPI labs (workers)
    int numProcs;
    // test mode used to run various test operations over MPI_wrapper in single process, 
    // when no real mpi exchange is initiated.
    bool isTested;
private:
    // the length of the queue to keep assynchroneous messages. If this length is exceeded,
    // something is wrong and the job should be interrupted
    int assynch_queue_max_len_;
    // the current length of the assycnhroneous messages queue. (len(assyncMessList));
    int assynch_mess_num_;
    // the list of assyncroneous messages, stored until delivered
    std::list<SendMessHolder> assyncMessList;
    // add message to the asynchroneous messages queue and check if the queue is exceeded
    SendMessHolder* add_to_async_queue(uint8_t*pBuffer,size_t n_bytes,int dest_address, int data_tag);
    // add wait for previous message to be receivedto and send message to synchroneous transfer 
    SendMessHolder* set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

};
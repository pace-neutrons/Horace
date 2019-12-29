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
        theRequest(-1), mess_tag(-1), destination(-1) {}
    SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
    void init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
};

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

    MPI_wrapper() :
        labIndex(-1), numProcs(0), isTested(false),
        assynch_queue_max_len_(10) {}
    int init(bool isTested = false, int assynch_queue_max_len = 10);
    void close();
    void barrier();
    void labSend(int data_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer);
    void labProbe(int data_address, int data_tag, int& addres_present, int& tag_present);

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
    // return the number of asynchroneous messages in the queue
    size_t assync_queue_len() {
        return this->assyncMessList.size();
    }
    //----------------------------------------------------------------------------------
    // The methods used in unit tests -- have no sence in real life

    // get access to the asynchroneous messages queue
    std::list<SendMessHolder>* get_async_queue() {
        return &this->assyncMessList;
    }
    // get access to the synchroneous messages holder.
    SendMessHolder* get_sync_queue() {
        return &this->SyncMessHolder;
    }
private:
    // the length of the queue to keep assynchroneous messages. If this length is exceeded,
    // something is wrong and the job should be interrupted
    int assynch_queue_max_len_;

    // the list of assyncroneous messages, stored until delivered
    std::list<SendMessHolder> assyncMessList;

    SendMessHolder SyncMessHolder;

    // add message to the asynchroneous messages queue and check if the queue is exceeded
    SendMessHolder* add_to_async_queue(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
    // add wait for previous message to be receivedto and send message to synchroneous transfer 
    SendMessHolder* set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

};
#pragma once
#include <vector>
#include <list>
#include <cmath>
#include <mpi.h>
#include "input_parser.h"

/** Helper class to keep information on send message unit MPI framework reports delivered.
*
* in test mode also used to simulate send/receive operations.
*/
class SendMessHolder {
public:
    // Holder for ISend request property
    MPI_Request theRequest;
    // The holder for the tag of the message to send
    int mess_tag;
    // The holder for the address of the message to send
    int destination;
    // vector of the message contents, used as the buffer of the message contents until the message is received
    std::vector<uint8_t> mess_body;
      //SendMessHolder(SendMessHolder&& other) noexcept;
    SendMessHolder() :
        mess_tag(-1), destination(-1) {
        this->theRequest = (MPI_Request)(-1);
    }
    SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

    void init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
};

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

    MPI_wrapper() :
        labIndex(-1), numProcs(0), isTested(false),
        async_queue_max_len_(10) {}
    int init(bool isTested = false, int assynch_queue_max_len = 10, int data_mess_tag=5);
    void close();
    void barrier();
    void clearAll();
    void labSend(int data_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer);
    void labProbe(const std::vector<int32_t> &data_address, const std::vector<int32_t> &data_tag, 
        std::vector<int32_t> & addres_present, std::vector<int32_t> & tag_present);
    void labReceive(int source_address, int source_data_tag, bool isSynchronous, mxArray* plhs[], int nlhs);
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
    size_t async_queue_len() {
        return this->asyncMessList.size();
    }
    // the tag of message, containing data (processed differently, not yet implemented.)
    static int data_mess_tag;

    //----------------------------------------------------------------------------------
    // The methods used in unit tests -- have no meaning in real communications

    static bool MPI_wrapper_gtested;
    // get access to the asynchroneous messages queue
    std::list<SendMessHolder>* get_async_queue() {
        return &this->asyncMessList;
    }
    // get access to the synchroneous messages holder.
    SendMessHolder* get_sync_queue() {
        return &this->SyncMessHolder;
    }
    // check if any message present in test mode
    bool any_message_present() {
        if (SyncMessHolder.theRequest==0) 
            return true;
        for (auto it = asyncMessList.rbegin(); it != asyncMessList.rend(); it++) {
            if (it->theRequest == 0) {
                return true;
            }
        }
        return false;
    }
private:
    // the length of the queue to keep assynchroneous messages. If this length is exceeded,
    // something is wrong and the job should be interrupted
    int async_queue_max_len_;

    // the list of assyncroneous messages, stored until delivered
    std::list<SendMessHolder> asyncMessList;

    SendMessHolder SyncMessHolder;

    // add message to the asynchroneous messages queue and check if the queue is exceeded
    SendMessHolder* add_to_async_queue(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
    // add wait for previous message to be receivedto and send message to synchroneous transfer 
    SendMessHolder* set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

};

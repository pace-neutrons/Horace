#pragma once
#include <vector>
#include <list>
#include <cmath>
#include <mpi.h>
#include <chrono>
#include <thread>
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

    SendMessHolder() :
        mess_tag(-1), destination(-1) {
        this->theRequest = (MPI_Request)(-1);
    }
    SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

    void init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

    // method checks if the message was delivered to the target worker
    int is_delivered(bool is_tested);
    // method checks if the message has been send.
    bool is_send();

    // the container to keep subsequent synchronous messages in test mode. Not used in production
    std::list<SendMessHolder> test_sync_mess_list;

    SendMessHolder(SendMessHolder&& other) noexcept;
    SendMessHolder(const SendMessHolder& other);
    SendMessHolder &operator=(SendMessHolder &&other);
    SendMessHolder & operator=(const SendMessHolder & other);


};

/* The class which describes a block of information necessary to process block of pixels */
class MPI_wrapper {
public:

    MPI_wrapper() :
        labIndex(-1), numLabs(0), isTested(false),
        async_queue_max_len_(10) {}
    int init(const InitParamHolder &init_par);
    void close();
    void barrier();
    void clearAll();
    void labSend(int data_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer);
    void labProbe(const std::vector<int32_t> &data_address, const std::vector<int32_t> &data_tag,
        std::vector<int32_t> & addres_present, std::vector<int32_t> & tag_present, bool interrupt_only=false);
    void labReceive(int source_address, int source_data_tag, bool isSynchronous, mxArray* plhs[], int nlhs);
    ~MPI_wrapper() {
        this->close();
    }
    // index of the current MPI lab (worker)
    int labIndex;
    // total  number of MPI labs (workers)
    int numLabs;
    // vector containing the names of the all nodes of the pool
    std::vector<std::string> node_names;
    // test mode used to run various test operations over MPI_wrapper in single process, 
    // when no real MPI exchange is initiated.
    bool isTested;
    // return the number of asynchronous messages in the queue
    size_t async_queue_len() {
        return this->asyncMessList.size();
    }
    // the tag of message, containing data (processed differently, not yet implemented.)
    static int data_mess_tag;
    // the tag of message, containing interrupts. Organizes independent channel to check for interrupts
    static int interrupt_mess_tag;

    // pack node_names variable into linear buffer to be able to send it over MPI with one message 
    // and restore it later (kind of primitive serialization)
    void pack_node_names_list(std::vector<char>& buf)const;
    // unpack node_names variable from linear buffer received over MPI and restore the structure
    // (kind of primitive de-serialization)
    void unpack_node_names_list(const std::vector<char>& buf);
    //----------------------------------------------------------------------------------
    // The methods used in unit tests -- have no meaning in real communications
    static bool MPI_wrapper_gtested;
    // get access to the asynchronous messages queue
    std::list<SendMessHolder>* get_async_queue() {
        return &this->asyncMessList;
    }
    // get access to the synchronous messages holder.
    SendMessHolder* get_sync_queue(int dest_address = 0) {
        return &this->SyncMessHolder[dest_address];
    }
    // get access to the interrupt holder
    SendMessHolder *get_interrupt_queue(int dest_address = 0) {
        return &this->InterruptHolder[dest_address];
    }
    // check if any message present in test mode
    bool any_message_present() {
        for (const auto &msg : InterruptHolder) {
            if (msg.theRequest == 0)  return true;
        }
        for (const auto &msg : SyncMessHolder) {
            if (msg.theRequest == 0)  return true;
        }
        for (auto it = asyncMessList.rbegin(); it != asyncMessList.rend(); it++) {
            if (it->theRequest == 0)  return true;
        }
        return false;
    }
private:
    // the length of the queue to keep asynchronous messages. If this length is exceeded,
    // something is wrong and the job should be interrupted
    int async_queue_max_len_;

    // the list of asynchronous messages, stored until delivered
    std::list<SendMessHolder> asyncMessList;

    std::vector<SendMessHolder> SyncMessHolder;
    std::vector<SendMessHolder> InterruptHolder;

    // add message to the asynchronous messages queue and check if the queue is exceeded
    SendMessHolder* add_to_async_queue(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);
    // add wait for previous message to be received to and send message to synchronous transfer 
    SendMessHolder* set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag);

};

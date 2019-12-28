#include "MPI_wrapper.h"
#include "input_parser.h"

int MPI_wrapper::init(bool isTested, int assynch_messages_queue_len) {
    int* argc(nullptr);
    char*** argv(nullptr);
    int err(-1);
    // initiate the assynchroneous messages queue.
    this->assynch_queue_max_len_ = assynch_messages_queue_len;
    this->assynch_mess_num_ = 0;
    this->assyncMessList.clear();
    //
    if (isTested) {
        // set up test values and return without initializeing the framework
        this->isTested = true;
        this->numProcs = 1;
        this->labIndex = 0;
        return 0;
    }
    try {
        err = MPI_Init(argc, argv);
    }
    catch (...) {}

    if (err != MPI_SUCCESS) {
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
            "Can not initialize MPI framework");
    }

    MPI_Comm_size(MPI_COMM_WORLD, &this->numProcs);
    MPI_Comm_rank(MPI_COMM_WORLD, &this->labIndex);

    return 0;
}
void MPI_wrapper::close() {
    if (this->isTested) {
        // nthing to close in test mode
        return;
    }
    MPI_Finalize();
}
void MPI_wrapper::barrier() {
    if (this->isTested) {
        // no barrier as only one local client can be tested
        return;
    }

    MPI_Barrier(MPI_COMM_WORLD);
}
/** Send message using initalized mpi framework
* Inputs:
* dest_address    -- the  address of the worker to send data to
* data_tag        -- the MPI messages tag
* is_synchroneous -- should the message to be send synchronously or not.
* data_buffer     -- pointer to the begining of the buffer containing the data
* nbytes_to_transfer -- amount of bytes of data to transfer.
*/
void MPI_wrapper::send(int dest_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer) {

    SendMessHolder* pSendMessage(nullptr);
    if (is_synchroneous)
        pSendMessage = this->set_sync_transfer(data_buffer, nbytes_to_transfer, dest_address, data_tag);

    else
        pSendMessage = this->add_to_async_queue(data_buffer, nbytes_to_transfer, dest_address, data_tag);

    if (this->isTested) { // set testing request state to the first byte of the message bufer. 
        //Its probably a pointer, but will be used as a number for testing purposes
        pSendMessage->theRequest = (MPI_Request)data_buffer[0];
        return;
    }
    int mess_size = static_cast<int>(pSendMessage->mess_body.size());
    MPI_Issend(&(pSendMessage->mess_body[0]), mess_size, MPI_CHAR,
        pSendMessage->destination, pSendMessage->mess_tag, MPI_COMM_WORLD,
        &(pSendMessage->theRequest));
}

/** Place message in assynchoneous messages queue preparing it for sending and verify if any previous messages were received
   Thow if the queue is overfilled

*/
SendMessHolder* MPI_wrapper::add_to_async_queue(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {

    //
    SendMessHolder* messToSend(nullptr), * prevMess(nullptr);
    //
    int isDelivered;
    MPI_Status status; // not clear what to do about it.
    auto pMess = this->assyncMessList.rbegin();
    while (pMess != this->assyncMessList.rend()) {
        if (this->isTested)
            isDelivered = bool(pMess->theRequest);
        else {
            MPI_Test(&pMess->theRequest, &isDelivered, &status);
        }

        if (isDelivered) {
            prevMess = messToSend;
            messToSend = &(*pMess);
            pMess++;
            if (prevMess) { //delete previous message which is the last message
                this->assyncMessList.pop_back();
            }
        }
        else { // not delivered
            break;
        }
    }

    if (messToSend) { // reuse existing delivered message space not to allocate memory again
        messToSend->init(pBuffer, n_bytes, dest_address, data_tag);
        this->assyncMessList.push_front(*messToSend);
        this->assyncMessList.pop_back();
    }
    else { // no space in the cache to recycle.
        if (this->assync_queue_len()+1 > this->assynch_queue_max_len_) {
            mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:runtime_error",
                "the number of assynchroneous messages exceed the maximal numnber");
        }

        // add new message
        SendMessHolder mess(pBuffer, n_bytes, dest_address, data_tag);
        this->assyncMessList.push_front(mess);
    }
    messToSend = &(*assyncMessList.begin());
    return messToSend;

}

SendMessHolder* MPI_wrapper::set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {
    return new SendMessHolder();

}
//
///** Move constructor for send message
//    to avoid copying vector contents*/
//SendMessHolder::SendMessHolder(SendMessHolder&& other) noexcept {
//    if (&other == this)return;
//
//    this->theRequest = other.theRequest;
//    this->mess_tag = other.mess_tag;
//    this->destination = other.destination;
//    this->mess_body.swap(other.mess_body);
//
//}
/** Construtor building message from message holder*/
SendMessHolder::SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {

    this->init(pBuffer, n_bytes, dest_address, data_tag);

}
/** Init function is the part of the constructor, used to re-initialize existing message
* Inputs:
* dest_address    -- the  address of the worker to send data to
* data_tag        -- the MPI messages tag
* is_synchroneous -- should the message to be send synchronously or not.
* data_buffer     -- pointer to the begining of the buffer containing the data
* nbytes_to_transfer -- amount of bytes of data to transfer.
*/
void SendMessHolder::init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {
    this->mess_body.resize(n_bytes);
    this->mess_tag = data_tag;
    this->destination = dest_address;

    for (int i = 0; i < n_bytes; i++) {
        this->mess_body[i] = pBuffer[i];
    }

}

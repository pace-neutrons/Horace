#include "MPI_wrapper.h"
#include "input_parser.h"
/** Initialize MPI communications framework */
int MPI_wrapper::init(bool isTested, int assynch_messages_queue_len) {
    int* argc(nullptr);
    char*** argv(nullptr);
    int err(-1);
    // initiate the assynchroneous messages queue.
    this->assynch_queue_max_len_ = assynch_messages_queue_len;
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

/** Complete MPI operations and finalize MPI exchange framework*/
void MPI_wrapper::close() {
    if (this->isTested) {
        // nthing to close in test mode
        return;
    }
    MPI_Finalize();
}

/** Set up MPI barrier to synchronize all MPI workers */
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
void MPI_wrapper::labSend(int dest_address, int data_tag, bool is_synchroneous, uint8_t* data_buffer, size_t nbytes_to_transfer) {

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
    auto err = MPI_Issend(&(pSendMessage->mess_body[0]), mess_size, MPI_CHAR,
        pSendMessage->destination, pSendMessage->mess_tag, MPI_COMM_WORLD,
        &(pSendMessage->theRequest));
    if (err != MPI_SUCCESS) {
        std::stringstream buf;
        buf << " The MPI_Issend for Worker N" << this->labIndex + 1 << "have failed with Error, code= "
            << labIndex << std::endl;
        mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str());
    }

}

/** Place message in assynchoneous messages queue preparing it for sending and verify if any previous messages were received
   Thow if the allocate queue slpace is overfilled
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
            auto err = MPI_Test(&pMess->theRequest, &isDelivered, &status);
            if (err != MPI_SUCCESS) {
                std::stringstream buf;
                buf << " The MPI_Test for messages in the queue for Worker N" << this->labIndex + 1 << "have failed with Error, code= "
                    << labIndex << std::endl;
                mexErrMsgIdAndTxt("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str());
            }
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
        if (this->assync_queue_len() + 1 > this->assynch_queue_max_len_) {
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
    // Not implemented -- do nothing
    return new SendMessHolder();

}

/* in test mode, verify if data source and data tag for message correspond data source and data tag requested */
bool check_address_tag_requsted(SendMessHolder const& Mess, int addr_requested, int tag_requested) {
    if (Mess.theRequest ==0 ) {// Assume that in test mode, request==0 means message is sent but not delivered, so it is present in the queue
        if (addr_requested >= 0) {
            if (Mess.destination == addr_requested) {
                if (tag_requested >= 0) {
                    if (Mess.mess_tag == tag_requested)return true; // correct tag
                    else return false; // weong tag
                }
                else {
                    return true; // any tag
                }
            }
            else {
                return false; //wrong address present
            }
        }
        else {
            return true; // any address
        }

    }
    else
        return false; // no correct message
}

/** try for a message intended for this worker is present
Inputs:
data_address -- the address of a worker to ask for a message. -1 -- any worker
data_tag     -- the tag of the message to ask for. -1 -- to ask for any tag
Outputs:
addres_present -- if message present, the address the message has been sent from. -1 if no message for the address(es) requested is present.
tag_presnet    -- if message present, the tag of the message present, -1 if no message with the requested tag is present.
*/
void MPI_wrapper::labProbe(int data_address, int data_tag, int& addres_present, int& tag_present) {
    if (this->isTested) { // As there is only one host there, treat send message as the present message
        if (check_address_tag_requsted(this->SyncMessHolder, data_address, data_tag)) {
            addres_present = this->SyncMessHolder.destination;
            tag_present = this->SyncMessHolder.mess_tag;
            return;
        }

        addres_present = -1;
        tag_present = -1;
        auto pAsynchMess = this->assyncMessList.rbegin();
        for (pAsynchMess; pAsynchMess != this->assyncMessList.rend(); pAsynchMess++) {

            if (check_address_tag_requsted(*pAsynchMess, data_address, data_tag)) {
                addres_present = pAsynchMess->destination;
                tag_present = pAsynchMess->mess_tag;
                break;
            }
        }
    }
    else { // real MPI asynchroneous probe
        if (data_address < 0)
            data_address = MPI_ANY_SOURCE;
        if (data_tag < 0)
            data_tag = MPI_ANY_TAG;
        int flag;
        MPI_Status status;
        MPI_Iprobe(data_address, data_tag, MPI_COMM_WORLD, &flag, &status);
        if (flag) {
            addres_present = status.MPI_SOURCE;
            tag_present = status.MPI_TAG;
        }
        else {
            addres_present = -1;
            tag_present = -1;
        }
    }
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

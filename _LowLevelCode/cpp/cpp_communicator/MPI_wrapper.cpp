#include "MPI_wrapper.h"
#include "input_parser.h"
#include <tuple> 

// static data message tag, used by MPI wrapper to distinguish data messages and process them differently.
int MPI_wrapper::data_mess_tag = 5;
// static interrupt message tag, used by MPI wrapper to distinguish interrupts and process them differently.
int MPI_wrapper::interrupt_mess_tag = 100;
// auxiliary property to help with running unit tests
bool MPI_wrapper::MPI_wrapper_gtested = false;

/** Initialize MPI communications framework
* Inputs:
* init_param - the structure, containing the parameters, necessary for initialization.
*/
int MPI_wrapper::init(const InitParamHolder& init_param) {
    //%int const * const isTestedInfo, int async_messages_queue_len,
    //int data_mess_tag, int interrupt_mess_tag) {

    MPI_wrapper::data_mess_tag = init_param.data_message_tag;
    MPI_wrapper::interrupt_mess_tag = init_param.interrupt_tag;

    int* argc(nullptr);
    char*** argv(nullptr);
    int err(-1);
    // initiate the asynchronous messages queue.
    this->async_queue_max_len_ = init_param.async_queue_length;
    this->asyncMessList.clear();
    //
    if (init_param.is_tested) {
        // set up test values and return without initializing the framework
        this->isTested = true;
        this->labIndex = (int)init_param.debug_frmwk_param[0];
        this->numLabs = (int)init_param.debug_frmwk_param[1];
        this->SyncMessHolder.resize(this->numLabs);
        this->InterruptHolder.resize(this->numLabs);
        this->node_names.resize(this->numLabs);
        if (this->labIndex == 0) {
            char node_name[100];
            for (int i = 0; i < this->numLabs; i++) {
                sprintf(node_name, "Node%d\n", i + 1);
                this->node_names[i].assign(node_name, strlen(node_name + 1));
            }
        }
        return 0;
    }
    int is_initialized;
    MPI_Initialized(&is_initialized);
    if (is_initialized) {
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
            "MPI framework is initialized before MPI init was invoked");
    }

    try {
        err = MPI_Init(argc, argv);
    }
    catch (...) {}
    if (err != MPI_SUCCESS) {
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
            "Can not initialize MPI framework");
    }

    char node_name[MPI_MAX_PROCESSOR_NAME];
    MPI_Comm_size(MPI_COMM_WORLD, &this->numLabs);
    MPI_Comm_rank(MPI_COMM_WORLD, &this->labIndex);
    int node_name_length;
    unsigned long int buf_length;
    std::vector<char> pool_names_buffer;
    MPI_Get_processor_name(node_name, &node_name_length);

    this->SyncMessHolder.resize(this->numLabs);
    this->InterruptHolder.resize(this->numLabs);
    this->node_names.resize(this->numLabs);
    // check communications established and send information about pull names to all nodes of the pool
    this->node_names[this->labIndex].assign(node_name, node_name_length);
    MPI_Status stat;
    if (this->labIndex == 0) {

        for (int nneighbour = 1; nneighbour < this->numLabs; nneighbour++) {
            auto ok = MPI_Probe(nneighbour, MPI_wrapper::data_mess_tag, MPI_COMM_WORLD, &stat);
            if (ok != MPI_SUCCESS) {
                std::stringstream buf;
                buf << " The Node-1 MPI_probe failed asking for initialization exchange message from Worker N "
                    << nneighbour + 1
                    << " the error, code== "
                    << ok << std::endl;
                throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str(), MPI_wrapper::MPI_wrapper_gtested);
            }
            MPI_Get_count(&stat, MPI_BYTE, &node_name_length);
            MPI_Recv(node_name, node_name_length, MPI_BYTE, nneighbour, MPI_wrapper::data_mess_tag, MPI_COMM_WORLD, &stat);

            this->node_names[nneighbour].assign(node_name, node_name_length);
        }

        // send information about the pool to all neighbours
        this->pack_node_names_list(pool_names_buffer);

        buf_length = static_cast<unsigned long int>(pool_names_buffer.size());
        MPI_Bcast(&buf_length, 1, MPI_UNSIGNED_LONG, 0, MPI_COMM_WORLD);
        MPI_Bcast(&pool_names_buffer[0], buf_length, MPI_BYTE, 0, MPI_COMM_WORLD);
    }
    else {
        MPI_Ssend(node_name, node_name_length, MPI_BYTE, 0, MPI_wrapper::data_mess_tag, MPI_COMM_WORLD);

        // slave to receive the information about the pool names (including themselves)
        MPI_Bcast(&buf_length, 1, MPI_UNSIGNED_LONG, 0, MPI_COMM_WORLD);
        pool_names_buffer.resize(buf_length);
        MPI_Bcast(&pool_names_buffer[0], buf_length, MPI_BYTE, 0, MPI_COMM_WORLD);

        this->unpack_node_names_list(pool_names_buffer);
    }

    return 0;
}

/** Complete MPI operations and finalize MPI exchange framework*/
void MPI_wrapper::close() {
    if (this->isTested) {
        // nothing to close in test mode
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

/** Send message using initialized mpi framework
* Inputs:
* dest_address    -- the  address of the worker to send data to
* data_tag        -- the MPI messages tag
* is_synchronous -- should the message to be send synchronously or not.
* data_buffer     -- pointer to the beginning of the buffer containing the data
* nbytes_to_transfer -- amount of bytes of data to transfer.
*/
void MPI_wrapper::labSend(int dest_address, int data_tag, bool is_synchronous, uint8_t* data_buffer, size_t nbytes_to_transfer) {

    SendMessHolder* pSendMessage(nullptr);
    MPI_Status status;
    if (data_tag == MPI_wrapper::interrupt_mess_tag) { // send message to special interrupt channel
        if (this->InterruptHolder[dest_address].is_send() &&
            !this->InterruptHolder[dest_address].is_delivered(this->isTested)) { // how should we handle such situation?
            // not sure. two interrupts in a row to the same address is a problem. Let's assume that
            // proper barriers will be in place not to allow such situation.
            // Meanwhile, wait until the previous interrupt is delivered
            if (this->isTested) {
                std::stringstream buf;
                buf << " Attempt to send next interrupt message to Worker N: "
                    << dest_address + 1
                    << " until the previous one is delivered is not allowed\n";
                throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str(), MPI_wrapper::MPI_wrapper_gtested);

            }
            else
            {
                // wait until the previous interrupt message is delivered
                auto ok = MPI_Wait(&(this->InterruptHolder[dest_address].theRequest), &status);
                if (ok != MPI_SUCCESS) {
                    std::stringstream buf;
                    buf << " The MPI_Wait until previous interrupt message in the queue for Worker N"
                        << dest_address + 1
                        << "is delivered have failed with Error, code= "
                        << ok << std::endl;
                    throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str());
                }

            }

        }
        this->InterruptHolder[dest_address].init(data_buffer, nbytes_to_transfer, dest_address, data_tag);
        if (this->isTested) {
            // set testing request state to 0 (false) send but not delivered
            this->InterruptHolder[dest_address].theRequest = 0;
        }
        else {
            int mess_size = static_cast<int>(nbytes_to_transfer);
            auto err = MPI_Isend(data_buffer, mess_size, MPI_CHAR, dest_address, data_tag, MPI_COMM_WORLD,
                &(InterruptHolder[dest_address].theRequest));
        }
        return;
    }
    if (is_synchronous)
        pSendMessage = this->set_sync_transfer(data_buffer, nbytes_to_transfer, dest_address, data_tag);
    else
        pSendMessage = this->add_to_async_queue(data_buffer, nbytes_to_transfer, dest_address, data_tag);

    if (this->isTested) { // set testing request state to 0 (false) send but not delivered
        pSendMessage->theRequest = 0;
        return;
    }
    int mess_size = static_cast<int>(pSendMessage->mess_body.size());
    auto err = MPI_Issend(&(pSendMessage->mess_body[0]), mess_size, MPI_CHAR,
        pSendMessage->destination, pSendMessage->mess_tag, MPI_COMM_WORLD,
        &(pSendMessage->theRequest));
    if (err != MPI_SUCCESS) {
        std::stringstream buf;
        buf << " The MPI_Issend for Worker N" << this->labIndex + 1 << "have failed with Error, code= "
            << err << std::endl;
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str());

    }

}

/** Place message in asynchronous messages queue preparing it for sending and verify if any previous messages were received
    Throw if the allowed queue space is exceeded
*/
SendMessHolder* MPI_wrapper::add_to_async_queue(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {

    //
    SendMessHolder* messToSend(nullptr);
    auto pPrevMess = this->asyncMessList.end();
    auto pMessToSend = this->asyncMessList.end();

    //
    int isDelivered;
    auto pMess = this->asyncMessList.begin();
    while (pMess != this->asyncMessList.end()) {

        isDelivered = pMess->is_delivered(this->isTested);

        if (isDelivered) { // pick current delivered message for reuse
            pPrevMess = pMessToSend;
            pMessToSend = pMess;
            messToSend = &(*pMessToSend);
            if (pPrevMess != this->asyncMessList.end()) { //delete previously selected delivered message
                this->asyncMessList.erase(pPrevMess);
            }
        }
        pMess++;

    }

    if (messToSend) { // reuse existing delivered message space not to allocate memory again
        messToSend->init(pBuffer, n_bytes, dest_address, data_tag);
    }
    else { // no space in the cache to recycle.
        if (this->async_queue_len() + 1 > this->async_queue_max_len_) {
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
                "the number of asynchronous messages exceed the maximal number",
                MPI_wrapper::MPI_wrapper_gtested);
        }

        // add new message
        this->asyncMessList.push_front(SendMessHolder(pBuffer, n_bytes, dest_address, data_tag));
        messToSend = &(*asyncMessList.begin());

    }
    return messToSend;

}

SendMessHolder* MPI_wrapper::set_sync_transfer(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {
    MPI_Status status;
    SendMessHolder* pMessHolder(nullptr);
    if (this->SyncMessHolder[dest_address].is_send() && !this->SyncMessHolder[dest_address].is_delivered(this->isTested)) {
        if (this->isTested) {
            this->SyncMessHolder[dest_address]
                .test_sync_mess_list
                .push_back(SendMessHolder(pBuffer, n_bytes, dest_address, data_tag));
            pMessHolder = &(this->SyncMessHolder[dest_address].test_sync_mess_list.back());
        }
        else { // wait until previous synchronous message is delivered, then use the holder for 
            // the next message
            auto err = MPI_Wait(&(this->SyncMessHolder[dest_address].theRequest), &status);
            if (err != MPI_SUCCESS) {
                std::stringstream buf;
                buf << " The MPI_Wait for delivery of synchronous message from Worker N" << this->labIndex + 1 << "have failed with Error, code= "
                    << err << std::endl;
                throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str());
            }
            this->SyncMessHolder[dest_address].init(pBuffer, n_bytes, dest_address, data_tag);
            pMessHolder = &SyncMessHolder[dest_address];
        }
    }
    else {
        this->SyncMessHolder[dest_address].init(pBuffer, n_bytes, dest_address, data_tag);
        pMessHolder = &SyncMessHolder[dest_address];
    }

    return pMessHolder;

}

/* in test mode, verify if data source and data tag for message correspond data source and data tag requested
*
* Non-send message has negative destination address and delivered message has theRequest tag == 0 so only
* valid queue messages are verified and returned
*/
bool check_address_tag_requsted(SendMessHolder const& Mess, int addr_requested, int tag_requested) {
    if (Mess.theRequest == 0) {// Assume that in test mode, request==0 means message is sent but not delivered, so it is present in the queue
        if (addr_requested >= 0) {
            if (Mess.destination == addr_requested) {
                if (tag_requested >= 0) {
                    if (Mess.mess_tag == tag_requested)return true; // correct tag
                    else return false; // wrong tag
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

/** Probe for a message(s) intended for this worker is present
Inputs:
data_address   -- the vector of addresses of a workers to ask for a message.
data_tag       -- the vector of tags of the messages to ask for. -1 -- to ask for any tag
interrupt_only -- if true, check only for interrupts
Outputs:
addres_present -- vector, containing the addresses of the labs, who have sent messages. Empty if no messages
tag_presnet    -- vector, containing the tags of the present messages
*/
void MPI_wrapper::labProbe(const std::vector<int32_t>& data_address, const std::vector<int32_t>& data_tag,
    std::vector<int32_t>& addres_present, std::vector<int32_t>& tag_present, bool interrupt_only) {

    typedef std::tuple<int32_t, int32_t> address;
    std::vector<address> addres_tmp;
    addres_tmp.reserve(data_address.size()); // most probable request is one tag per address
    bool any_mess_present = false;
    for (size_t i = 0; i < data_address.size(); i++) {
        if (data_address[i] < 0) { // it is not allowed now
            std::stringstream buf;
            buf << "labProbe issued for any worker. This mode  is not supported \n";
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str(), MPI_wrapper::MPI_wrapper_gtested);

        }
        //*********  Check interrupt channel
        bool interrupt_present(false);
        if (this->isTested) {
            if (check_address_tag_requsted(this->InterruptHolder[data_address[i]], data_address[i], MPI_wrapper::interrupt_mess_tag)) {
                addres_tmp.push_back(std::make_tuple(this->InterruptHolder[data_address[i]].destination,
                    MPI_wrapper::interrupt_mess_tag));
                interrupt_present = true;
            }
        }
        else {
            int flag;
            MPI_Status status;
            MPI_Iprobe(data_address[i], MPI_wrapper::interrupt_mess_tag, MPI_COMM_WORLD, &flag, &status);
            if (flag) {
                addres_tmp.push_back(std::make_tuple(status.MPI_SOURCE, status.MPI_TAG));
                interrupt_present = true;
            }
        }
        //*********  End interrupt check
        // 
        //*********  Check other requested messages from the lab specified as input
        if (!(interrupt_present || interrupt_only)) {
            for (size_t j = 0; j < data_tag.size(); j++) {
                if (data_tag[j] == MPI_wrapper::interrupt_mess_tag)continue; // have already checked

                if (this->isTested) {

                    if ((data_tag[j] == MPI_wrapper::data_mess_tag || data_tag[j] == -1) &&
                        check_address_tag_requsted(this->SyncMessHolder[data_address[i]], data_address[i], MPI_wrapper::data_mess_tag)) {
                        addres_tmp.push_back(std::make_tuple(this->SyncMessHolder[data_address[i]].destination,
                            this->SyncMessHolder[data_address[i]].mess_tag));
                        break;
                    }

                    auto pAsynchMess = this->asyncMessList.rbegin();
                    for (pAsynchMess; pAsynchMess != this->asyncMessList.rend(); pAsynchMess++) {

                        if (check_address_tag_requsted(*pAsynchMess, data_address[i], data_tag[j])) {
                            addres_tmp.push_back(std::make_tuple(pAsynchMess->destination, pAsynchMess->mess_tag));
                            break;
                        }
                    }
                }
                else { // real MPI asynchronous probe
                    int search_tag;

                    if (data_tag[j] < 0)
                        search_tag = MPI_ANY_TAG;
                    else
                        search_tag = data_tag[j];

                    int flag;
                    MPI_Status status;
                    MPI_Iprobe(data_address[i], search_tag, MPI_COMM_WORLD, &flag, &status);
                    if (flag) {
                        addres_tmp.push_back(std::make_tuple(status.MPI_SOURCE, status.MPI_TAG));
                        break;
                    }
                }
            } // j
        } //********* End of Check for other messages
    } //i -- all sources
    addres_present.resize(0);
    tag_present.resize(0);

    if (addres_tmp.size() == 0) {
        return;
    }
    addres_present.reserve(addres_tmp.size());
    tag_present.reserve(addres_tmp.size());
    for (auto&& it : addres_tmp) {
        addres_present.push_back(std::get<0>(it));
        tag_present.push_back(std::get<1>(it));
    }


}

/* Create outputs for labReceive and return pointers to the arrays locations for copying results
into these outputs  */
std::tuple<char*, void*, int32_t*> create_plhs_for_labReceive(mxArray* plhs[], int nlhs, int data_size, int cell_size) {


    plhs[(int)labReceive_Out::mess_contents] = mxCreateNumericMatrix(1, data_size, mxUINT8_CLASS, mxREAL);
    plhs[(int)labReceive_Out::data_celarray] = mxCreateNumericMatrix(1, cell_size, mxCELL_CLASS, mxREAL);

    char* pBuff = reinterpret_cast<char*>(mxGetData(plhs[(int)labReceive_Out::mess_contents]));
    void* pCell = reinterpret_cast<void*>(mxGetData(plhs[(int)labReceive_Out::data_celarray]));
    int32_t* pSourceAddress(nullptr);
    if (nlhs >= (int)labReceive_Out::real_source_address) {
        if (data_size > 0) {
            plhs[(int)labReceive_Out::real_source_address] = mxCreateNumericMatrix(1, 2, mxINT32_CLASS, mxREAL);
            pSourceAddress = reinterpret_cast<int32_t*>(mxGetData(plhs[(int)labReceive_Out::real_source_address]));
        }
        else
            plhs[(int)labReceive_Out::real_source_address] = mxCreateNumericMatrix(1, 0, mxINT32_CLASS, mxREAL);
    }

    return std::make_tuple(pBuff, pCell, pSourceAddress);
}

/** receive message from another MPI worker
Inputs:
source_address  -- where ask for message
source_data_tag -- the requested data tag, If -1, any tag.
isSynchronous   -- if true, block the program execution until requested message is received.
                   If false and message is not present, return empty result
nlhs            -- The number of output arguments. Should be larger or equal than
                   labReceive_Out::N_OUTPUT_Arguments -1
Output:
mxArray* plhs[]   -- on input array of Matlab pointers to output parameters of mex routine
                     on output:
                     element labReceive_Out::mess_contents keeps pointer to received message contents
                     element labReceive_Out::data_celarray pointer to cellarray of pointers to large data
                     when appropriate message with tag equal data_tag is received.
*/
void MPI_wrapper::labReceive(int source_address, int source_data_tag, bool isSynchronous, mxArray* plhs[], int nlhs) {

    if (source_data_tag == -1)source_data_tag = MPI_ANY_TAG;
    if (source_address == -1) { // not allowed in our framework
        throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
            "LabReceive from any address is not allowed", MPI_wrapper::MPI_wrapper_gtested);
    }
    int message_size(0);
    std::tuple<char*, void*, int32_t*> outPtrs;

    if (source_data_tag != MPI_wrapper::interrupt_mess_tag) {
        // if interrupt is present, receive interrupt instead of 
        // message initially asked for
        std::vector<int32_t> address(1, source_address);
        std::vector<int32_t> tag(1, MPI_wrapper::interrupt_mess_tag);
        std::vector<int32_t> out_address, out_tag;
        this->labProbe(address, tag, out_address, out_tag, true);
        if (out_address.size() > 0) {
            source_data_tag = MPI_wrapper::interrupt_mess_tag;
        }
    }



    if (this->isTested) {
        SendMessHolder* pMess(nullptr);
        SendMessHolder* pPrevMess(nullptr);

        if (check_address_tag_requsted(InterruptHolder[source_address], source_address, source_data_tag)) {
            pMess = &this->InterruptHolder[source_address];
        }

        if (isSynchronous) {
            if (!this->any_message_present()) {
                throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
                    "Synchronous waiting in test mode is not allowed", MPI_wrapper::MPI_wrapper_gtested);
            }
        }

        // find last requested message
        if (!pMess && check_address_tag_requsted(SyncMessHolder[source_address], source_address, source_data_tag)) {
            pMess = &this->SyncMessHolder[source_address];
        }
        if (!pMess) {
            // look through the queue and find message to receive
            for (auto it = asyncMessList.rbegin(); it != asyncMessList.rend(); it++) {
                if (check_address_tag_requsted(*it, source_address, source_data_tag)) {
                    pPrevMess = pMess;
                    pMess = &(*it);
                    if (bool(pPrevMess) && (source_data_tag != MPI_ANY_TAG)) {
                        if (pPrevMess->mess_tag == pMess->mess_tag) {
                            pPrevMess->theRequest = (MPI_Request)1; // Mark previous message delivered and ignore it.
                        }
                        else {
                            pMess = pPrevMess; // other type of message is sitting in the queue. Receive the previous message
                            break;
                        }
                    }
                }
            }
        }

        // if no message exist, return empty matrices.
        if (!pMess) {
            create_plhs_for_labReceive(plhs, nlhs, 0, 0);
            return;
        }
        pMess->theRequest = (MPI_Request)1; // mark the message as received

        message_size = (int)pMess->mess_body.size();
        outPtrs = create_plhs_for_labReceive(plhs, nlhs, message_size, 0);
        char* pBuff = std::get<0>(outPtrs);
        for (int i = 0; i < message_size; i++) {
            pBuff[i] = pMess->mess_body[i];
        }
        source_address = pMess->destination;
        source_data_tag = pMess->mess_tag;
        // we buffer data messages in test mode, so synchronous message is the only case when this can happen
        if (!pMess->test_sync_mess_list.empty()) {
            auto nextMess = std::move(pMess->test_sync_mess_list.front());
            pMess->test_sync_mess_list.pop_front();
            nextMess.test_sync_mess_list.swap(pMess->test_sync_mess_list);
            SyncMessHolder[source_address] = std::move(nextMess);
        }
    }
    else {  // real receive
        MPI_Status status;
        if (isSynchronous) { // get messages parameters. Wait until it appears
            MPI_Probe(source_address, source_data_tag, MPI_COMM_WORLD, &status);
        }
        else {
            int mess_exist;
            MPI_Iprobe(source_address, source_data_tag, MPI_COMM_WORLD, &mess_exist, &status);
            if (!mess_exist) {
                create_plhs_for_labReceive(plhs, nlhs, 0, 0);
                return;
            }

        }
        source_address = status.MPI_SOURCE;
        source_data_tag = status.MPI_TAG;
        MPI_Get_count(&status, MPI_CHAR, &message_size);
        if (isSynchronous || (source_data_tag == MPI_ANY_TAG)) {
            outPtrs = create_plhs_for_labReceive(plhs, nlhs, message_size, 0);

            char* pBuff = std::get<0>(outPtrs);
            auto err = MPI_Recv(pBuff, message_size, MPI_CHAR, source_address, source_data_tag, MPI_COMM_WORLD, &status);
            if (err != MPI_SUCCESS)throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
                "Error receiving message");
        }
        else { // receive all subsequent messages of the same kind
            std::vector<char> Buf(message_size);
            void* pBuff = &Buf[0];
            auto err = MPI_Recv(pBuff, message_size, MPI_CHAR, source_address, source_data_tag, MPI_COMM_WORLD, &status);
            if (err != MPI_SUCCESS)throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
                "Error receiving message");
            int mess_exist;
            MPI_Iprobe(source_address, source_data_tag, MPI_COMM_WORLD, &mess_exist, &status);
            while (mess_exist && (status.MPI_TAG == source_data_tag)) {
                MPI_Get_count(&status, MPI_CHAR, &message_size);
                Buf.resize(message_size);
                pBuff = &Buf[0];
                auto err = MPI_Recv(pBuff, message_size, MPI_CHAR, source_address, source_data_tag, MPI_COMM_WORLD, &status);
                if (err != MPI_SUCCESS)throw_error("MPI_MEX_COMMUNICATOR:runtime_error",
                    "Error receiving message");
                MPI_Iprobe(source_address, source_data_tag, MPI_COMM_WORLD, &mess_exist, &status);
            }
            outPtrs = create_plhs_for_labReceive(plhs, nlhs, message_size, 0);
            char* pOut = std::get<0>(outPtrs);
            for (size_t i = 0; i < message_size; i++)
                pOut[i] = Buf[i];
        }
    }
    // return information about real data source, if requested
    int32_t* pInfo = std::get<2>(outPtrs);
    if (pInfo) {
        pInfo[0] = source_address;
        pInfo[1] = source_data_tag;
    }


}
/** Receive and discard all messages, directed to this lab.
* In test mode marks all messages as not send and delivered.
*/
void MPI_wrapper::clearAll() {

    if (this->isTested) {
        for (size_t i = 0; i < this->SyncMessHolder.size(); i++) {
            SyncMessHolder[i].theRequest = MPI_Request(-1);
            SyncMessHolder[i].destination = -1;
            InterruptHolder[i].theRequest = MPI_Request(-1);
            InterruptHolder[i].destination = -1;
        }
        this->asyncMessList.clear();
    }
    else {  // real receive and ignore the results
        MPI_Status status;
        int mess_exist, message_size;
        std::vector <uint8_t> buf;
        void* pBuf(nullptr);
        MPI_Iprobe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &mess_exist, &status);
        while (mess_exist) {
            MPI_Get_count(&status, MPI_CHAR, &message_size);
            buf.resize(message_size);
            pBuf = &buf[0];
            auto source_address = status.MPI_SOURCE;
            auto source_data_tag = status.MPI_TAG;
            MPI_Recv(pBuf, message_size, MPI_CHAR, source_address, source_data_tag, MPI_COMM_WORLD, &status);

            MPI_Iprobe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &mess_exist, &status);
        }
    }
}

/** pack node_names variable into linear buffer to be able to send it over MPI with one message
 and restore it later (kind of primitive serialization)
 Input:
     takes the structure of the class variable node_names
 Output:
    fills in the buffer vector with the restorable structure values
*/
void MPI_wrapper::pack_node_names_list(std::vector<char>& buf)const {

    size_t i;
    size_t BlockSize = sizeof(size_t);
    // estimate the size of the node-names data
    size_t buf_size = BlockSize;
    for (i = 0; i < this->node_names.size(); i++) {
        buf_size += (this->node_names[i].size() + 1);
    }
    // fill-in the buffer
    buf.reserve(buf_size);
    size_t sizebuf = this->node_names.size();
    auto pBuf = reinterpret_cast<char*>(&sizebuf);
    for (i = 0; i < BlockSize; i++) buf.push_back(pBuf[i]);

    // copy all node names
    for (i = 0; i < this->node_names.size(); i++) {
        auto pString_start = this->node_names[i].c_str();
        for (size_t j = 0; j <= this->node_names[i].size(); j++) {
            buf.push_back(pString_start[j]);
        }
    }

}
/** unpack node_names variable from linear buffer received over MPI and restore the structure
* (reverse to pack_node_names_list)   kind of primitive de-serialization.
*/
void MPI_wrapper::unpack_node_names_list(const std::vector<char>& buf) {

    size_t i;
    auto buf_start = &buf[0];
    size_t nNames = size_t(*reinterpret_cast<size_t const*>(buf_start));
    buf_start += sizeof(size_t);
    this->node_names.resize(nNames);
    for (i = 0; i < nNames; i++) {
        this->node_names[i].assign(buf_start);
        buf_start += this->node_names[i].size() + 1;
    }
}

//
/** Constructor building message from message holder*/
SendMessHolder::SendMessHolder(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) :
    mess_tag(-1), destination(-1) {

    this->init(pBuffer, n_bytes, dest_address, data_tag);

}
/** Init function is the part of the constructor, used to re-initialize existing message
* Inputs:
* dest_address    -- the  address of the worker to send data to
* data_tag        -- the MPI messages tag
* is_synchroneous -- should the message to be send synchronously or not.
* data_buffer     -- pointer to the beginning of the buffer containing the data
* nbytes_to_transfer -- amount of bytes of data to transfer.
*/
void SendMessHolder::init(uint8_t* pBuffer, size_t n_bytes, int dest_address, int data_tag) {

    this->mess_body.resize(n_bytes);
    this->mess_tag = data_tag;
    this->destination = dest_address;
    this->theRequest = (MPI_Request)(-1);

    for (int i = 0; i < n_bytes; i++) {
        this->mess_body[i] = pBuffer[i];
    }

}
/** Check if the non-empty message, assigned to the message holder has been delivered.
 * Inputs:
 * is_tested -- boolean to check if the framework works in test mode
 * Returns:
  int value > 0 if the message was delivered or 0 if it is not.
  Throws if MPI_Tests fails
  Message never sent never delivered
*/
int SendMessHolder::is_delivered(bool is_tested) {
    int isDelivered;
    MPI_Status status; // not clear what to do about this status.

    if (is_tested)
        isDelivered = (this->theRequest == MPI_Request(1)) && is_send();
    else {
        if (this->destination == -1) { // message was never sent so never delivered
            return 0;
        }
        auto err = MPI_Test(&this->theRequest, &isDelivered, &status);
        if (err != MPI_SUCCESS) {
            std::stringstream buf;
            buf << " The MPI_Test for messages in the queue for Worker N" << this->destination + 1 << "have failed with Error, code= "
                << err << std::endl;
            throw_error("MPI_MEX_COMMUNICATOR:runtime_error", buf.str().c_str(), MPI_wrapper::MPI_wrapper_gtested);
        }
    }
    return isDelivered;
}
/** Check if the message holder is responsible for send message (e.g. non-empty message)

 * Inputs:
 * is_tested -- boolean to check if the framework works in test mode
 * Returns:
    true if the message has been send and false if it is not
  Message never sent never delivered
*/

bool SendMessHolder::is_send() {

    if (this->destination > -1)
        return true;
    else
        return false;
}

SendMessHolder& SendMessHolder::operator=(SendMessHolder&& other) {
    if (this == &other)return *this;

    this->theRequest = other.theRequest;
    this->mess_tag = other.mess_tag;
    this->destination = other.destination;

    this->mess_body.swap(other.mess_body);
    this->test_sync_mess_list.swap(other.test_sync_mess_list);

    other.theRequest = (MPI_Request)(-1);
    other.destination = -1;

    return *this;
}
///** Move constructor for send message
//    to avoid copying vector contents*/
SendMessHolder::SendMessHolder(SendMessHolder&& other) noexcept {
    if (&other == this)return;

    this->theRequest = other.theRequest;
    this->mess_tag = other.mess_tag;
    this->destination = other.destination;
    this->mess_body.swap(other.mess_body);
    this->test_sync_mess_list.swap(other.test_sync_mess_list);
    other.theRequest = (MPI_Request)(-1);
    other.destination = -1;

}
// copy assignment
SendMessHolder& SendMessHolder::operator=(const SendMessHolder& other) {
    if (this == &other)return *this;

    this->theRequest = other.theRequest;
    this->mess_tag = other.mess_tag;
    this->destination = other.destination;

    this->mess_body.assign(other.mess_body.begin(), other.mess_body.end());
    this->test_sync_mess_list.assign(other.test_sync_mess_list.begin(), other.test_sync_mess_list.end());

    return *this;

}
SendMessHolder::SendMessHolder(const SendMessHolder& other) {
    this->theRequest = other.theRequest;
    this->mess_tag = other.mess_tag;
    this->destination = other.destination;

    this->mess_body.assign(other.mess_body.begin(), other.mess_body.end());
    this->test_sync_mess_list.assign(other.test_sync_mess_list.begin(), other.test_sync_mess_list.end());
}




#include "cpp_communicator/MPI_wrapper.h"
#include "cpp_communicator/input_parser.h"
#include "cpp_communicator/cpp_communicator.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Herbert::Utility;

TEST(TestCPPCommunicator, send_sync_multi_receive_sync_multi) {
    // testing test mode. It works this way only in test mode, while
    // real MPI should wait before delivering next data
    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;


    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);


    std::vector<uint8_t> test_mess(10, 1);

    wrap.labSend(9, 2, true, &test_mess[0], test_mess.size());

    test_mess.assign(10, 2);
    wrap.labSend(9, 2, true, &test_mess[0], test_mess.size());

    test_mess.assign(10, 3);
    wrap.labSend(9, 2, true, &test_mess[0], test_mess.size());


    // Receive first message and check it received correctly
    mxArray *plhs[(int)labReceive_Out::N_OUTPUT_Arguments];
    wrap.labReceive(9, 2, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 2);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 1);
    }
    // Receive second message and check it received correctly
    wrap.labReceive(9, 2, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 2);

    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 2);
    }

    // Receive third message and check it received correctly
    wrap.labReceive(9, 2, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 2);

    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 3);
    }



    ASSERT_FALSE(wrap.any_message_present());
}



TEST(TestCPPCommunicator, send_sync_receive_async) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;


    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);


    std::vector<uint8_t> test_mess(10, 3);

    wrap.labSend(9, 2, true, &test_mess[0], test_mess.size());

    // Receive this message and check it received correctly
    mxArray *plhs[(int)labReceive_Out::N_OUTPUT_Arguments];
    wrap.labReceive(9, 2, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 2);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 3);
    }

    ASSERT_FALSE(wrap.any_message_present());
}


TEST(TestCPPCommunicator, send_async_receive_sync) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;


    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);


    std::vector<uint8_t> test_mess(10, 3);

    wrap.labSend(9, 2, false, &test_mess[0], test_mess.size());

    // Receive this message and check it received correctly
    mxArray *plhs[(int)labReceive_Out::N_OUTPUT_Arguments];
    wrap.labReceive(9, 2, true, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 2);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 3);
    }

    ASSERT_FALSE(wrap.any_message_present());
}


TEST(TestCPPCommunicator, send_receive_synchronous) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;


    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);


    std::vector<uint8_t> test_mess(10, 1);

    wrap.labSend(9, 2, true, &test_mess[0], test_mess.size());
    auto pMess = wrap.get_sync_queue(9);

    ASSERT_EQ(pMess->mess_tag, 2);
    ASSERT_EQ(pMess->destination, 9);
    ASSERT_EQ(pMess->mess_body[0], 1);

    // "Deliver" message
    pMess->theRequest = (MPI_Request)1;
    ASSERT_FALSE(wrap.any_message_present());

    // send another message
    test_mess.assign(10, 2);
    wrap.labSend(9, 3, true, &test_mess[0], test_mess.size());
    pMess = wrap.get_sync_queue(9);
    ASSERT_EQ(pMess->mess_tag, 3);
    ASSERT_EQ(pMess->destination, 9);
    ASSERT_EQ(pMess->mess_body[0], 2);

    // Receive this message and check it received correctly
    mxArray *plhs[(int)labReceive_Out::N_OUTPUT_Arguments];
    wrap.labReceive(9, 3, true, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 9);
    ASSERT_EQ(pAddress[1], 3);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<uint8_t*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(pData[i], 2);
    }


    ASSERT_FALSE(wrap.any_message_present());
}


TEST(TestCPPCommunicator, send_message_holder_methods_send_delivered) {
    // check is_received and is_delivered methods

    SendMessHolder aHolder;
    ASSERT_FALSE(aHolder.is_send());
    ASSERT_FALSE(aHolder.is_delivered(true));

    std::vector<uint8_t> mess_data(10, 1);
    aHolder.init(&mess_data[0], 10, 10, 1);

    // in test mode it is considered send, in production mode
    // this parameter should be checked up by MPI_Wait or MPI_Test
    aHolder.theRequest = 0;
    ASSERT_TRUE(aHolder.is_send());
    ASSERT_FALSE(aHolder.is_delivered(true));

    // in test mode it is considered delivered, in production mode
    // it processed by MPI_Test operation
    aHolder.theRequest = (MPI_Request)1;
    ASSERT_TRUE(aHolder.is_send());
    ASSERT_TRUE(aHolder.is_delivered(true));


    aHolder.init(&mess_data[0], 10, 10, 1);
    ASSERT_TRUE(aHolder.is_send());
    ASSERT_FALSE(aHolder.is_delivered(true));

}


TEST(TestCPPCommunicator, send_interrupt_overrides_message) {
    // check interrupt is received if present instead of
    // requested message

    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;
    init_par.interrupt_tag = 100;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 4, false, &test_mess[0], test_mess.size());

    std::vector<uint8_t> interrupt_mess;
    interrupt_mess.assign(10, 10);
    wrap.labSend(5, init_par.interrupt_tag, false, &interrupt_mess[0], test_mess.size());

    mxArray* plhs[5];
    // ask message
    wrap.labReceive(5, 4, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);
    // got interrupt
    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t *>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], init_par.interrupt_tag);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto mess_data = reinterpret_cast<uint8_t *>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(interrupt_mess[i], mess_data[i]);
    }



    //  message still has to be received (and can be received)
    wrap.labReceive(5, 4, false, plhs, (int)labReceive_Out::N_OUTPUT_Arguments);
    // got interrupt
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    mess_data = reinterpret_cast<uint8_t *>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(test_mess[i], mess_data[i]);
    }

    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t *>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], 4);



    // message is taken in the cache, but its place kept for the following messages
    auto queue = wrap.get_async_queue();
    ASSERT_EQ(queue->size(), 1); // place in the queue is retained for the following messages
    auto contents = queue->begin();
    ASSERT_EQ(contents->destination, 5);
    ASSERT_TRUE(contents->is_delivered(true));

}


TEST(TestCPPCommunicator, send_probe_interrupt_overrides) {
    // check interrupt is reported if present instead of
    // the probed message


    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;
    init_par.interrupt_tag = 100;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    auto pInterrupt = wrap.get_interrupt_queue(5);
    ASSERT_FALSE(pInterrupt->is_send());
    ASSERT_FALSE(pInterrupt->is_delivered(true));

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 4, false, &test_mess[0], test_mess.size());
    std::vector<int32_t> req_address(1, 5);
    std::vector<int32_t> req_tag(1, 4);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_tag.size(), 1);
    ASSERT_EQ(got_address[0], 5);
    ASSERT_EQ(got_tag[0], 4);

    wrap.labSend(5, init_par.interrupt_tag, false, &test_mess[0], test_mess.size());
    ASSERT_TRUE(pInterrupt->is_send());
    ASSERT_FALSE(pInterrupt->is_delivered(true));


    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_tag.size(), 1);
    ASSERT_EQ(got_address[0], 5);
    ASSERT_EQ(got_tag[0], init_par.interrupt_tag);

    // but normal message is sitting in the cache somewhere
    auto queue = wrap.get_async_queue();
    ASSERT_EQ(queue->size(), 1);
    auto contents = queue->begin();
    ASSERT_EQ(contents->destination, 5);
    ASSERT_FALSE(contents->is_delivered(true));


}


TEST(TestCPPCommunicator, send_probe_interrupt) {
    // when asynchronously receving list of the same tag non-data messages retain only the last one

    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;
    init_par.interrupt_tag = 100;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    auto pInterrupt = wrap.get_interrupt_queue(5);
    ASSERT_FALSE(pInterrupt->is_send());
    ASSERT_FALSE(pInterrupt->is_delivered(true));

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, init_par.interrupt_tag, false, &test_mess[0], test_mess.size());
    ASSERT_TRUE(pInterrupt->is_send());
    ASSERT_FALSE(pInterrupt->is_delivered(true));

    std::vector<int32_t> req_address(1, 1);
    std::vector<int32_t> req_tag(1, -1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 5;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 5);
    ASSERT_EQ(got_tag[0], init_par.interrupt_tag);

    // ask for 1, got interrupt
    req_tag[0] = 1;
    req_address[0] = 5;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 5);
    ASSERT_EQ(got_tag[0], init_par.interrupt_tag);

}


TEST(TestCPPCommunicator, send_assynchroneous) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;


    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);
    EXPECT_EQ(MPI_wrapper::interrupt_mess_tag, 1010);

    EXPECT_EQ(wrap.labIndex, 1);
    EXPECT_EQ(wrap.numLabs, 10);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());
    // "Deliver" message
    auto queue = wrap.get_async_queue();
    queue->rbegin()->theRequest = (MPI_Request)1;

    test_mess.assign(10, 2);
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.async_queue_len());

    // "Deliver" message
    queue->rbegin()->theRequest = (MPI_Request)1;
    test_mess.assign(10, 3);
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.async_queue_len());

    wrap.labSend(9, 2, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(2, wrap.async_queue_len());

    wrap.labSend(8, 3, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(3, wrap.async_queue_len());

    wrap.labSend(7, 4, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(4, wrap.async_queue_len());
    // queue full
    ASSERT_ANY_THROW(wrap.labSend(6, 1, false, &test_mess[0], test_mess.size()));

    // Mark all messages as delivered
    auto MessCache = wrap.get_async_queue();

    auto last = MessCache->rbegin();
    last->theRequest = (MPI_Request)1; // mark last message delivered;
    wrap.labSend(5, 5, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.async_queue_len());


    for (auto &it : *MessCache) {
        it.theRequest = (MPI_Request)1;
    }
    wrap.labSend(4, 6, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());
    auto it = MessCache->begin();
    ASSERT_EQ(it->destination, 4);
    ASSERT_EQ(it->mess_tag, 6);
}

TEST(TestCPPCommunicator, send_assynch_random_receive1) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 6;
    init_par.data_message_tag = 9;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);
    for (int i = 1; i < 6; i++) {
        wrap.labSend(i, i, false, &test_mess[0], test_mess.size());

    }
    ASSERT_EQ(5, wrap.async_queue_len());

    auto MessCache = wrap.get_async_queue();
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        if (it->mess_tag % 2 == 0) {
            it->theRequest = (MPI_Request)1; // "Receive" all even messages
        }
    }


    wrap.labSend(7, 7, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.async_queue_len());
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        ASSERT_EQ(it->mess_tag % 2, 1);
    }

}
//
TEST(TestCPPCommunicator, send_assynch_random_receive2) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 6;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);
    for (int i = 1; i < 6; i++) {
        wrap.labSend(i, i, false, &test_mess[0], test_mess.size());

    }
    ASSERT_EQ(5, wrap.async_queue_len());

    auto MessCache = wrap.get_async_queue();
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        if (it->mess_tag % 2 == 1) {
            it->theRequest = (MPI_Request)1; // "Receive" all odd messages
        }
    }


    wrap.labSend(6, 6, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(3, wrap.async_queue_len());
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        ASSERT_EQ(it->mess_tag % 2, 0);
    }

}
//
TEST(TestCPPCommunicator, lab_probe_single) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    std::vector<int32_t> req_address(1, -1);
    std::vector<int32_t> req_tag(1, -1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    ASSERT_ANY_THROW(wrap.labProbe(req_address, req_tag, got_address, got_tag));
    req_address.resize(10);
    for (auto i = 0; i < 10; i++) {
        req_address[i] = i;
    }
    wrap.labProbe(req_address, req_tag, got_address, got_tag);

    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);


    std::vector<uint8_t> test_mess(10, 1);
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(9, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 1);

    req_address.resize(1);
    req_address[0] = 8;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 9;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 1);

    req_address[0] = 9;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 9;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 1);

    //
    wrap.labSend(8, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(wrap.async_queue_len(), 2);

    // Mark last messages as delivered
    auto MessCache = wrap.get_async_queue();
    auto lastMess = MessCache->rbegin();
    lastMess->theRequest = (MPI_Request)1;

    req_address[0] = 9;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);


    req_address[0] = 8;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 8;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_tag.size(), 1);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);
}

TEST(TestCPPCommunicator, lab_probe_multi) {

    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);


    std::vector<int32_t> req_address(10, -1);
    for (auto i = 0; i < 10; i++)req_address[i] = i;

    std::vector<int32_t> req_tag(1, -1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;


    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);


    std::vector<uint8_t> test_mess(10, 1);
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(8, 2, false, &test_mess[0], test_mess.size());
    wrap.labSend(5, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.async_queue_len());

    req_address.resize(2);
    req_address[0] = 8;
    req_address[1] = 3;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);

    req_tag[0] = 3;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 1);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);

    req_address.push_back(5);
    req_tag.push_back(5);
    req_tag.push_back(3);

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 2);
    ASSERT_EQ(got_address[0], 8);
    ASSERT_EQ(got_tag[0], 2);
    ASSERT_EQ(got_address[1], 5);
    ASSERT_EQ(got_tag[1], 3);


}

TEST(TestCPPCommunicator, lab_receive_as_send) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 9;
    init_par.interrupt_tag = 1010;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 11;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    mxArray* plhs[5];
    wrap.labReceive(10, 1, false, plhs, 5);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 0);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);

    // synchronous message absent in test mode
    ASSERT_ANY_THROW(wrap.labReceive(10, 1, true, plhs, 5));

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    for (int i = 0; i < test_mess.size(); i++) {
        test_mess[i] = i;
    }

    wrap.labSend(10, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());

    ASSERT_ANY_THROW(wrap.labReceive(-1, -1, false, plhs, 5));

    wrap.labReceive(10, -1, false, plhs, 5);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto pData = reinterpret_cast<char*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(test_mess[i], pData[i]);
    }
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t *>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 10);
    ASSERT_EQ(pAddress[1], 2);

    wrap.labReceive(10, 2, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 0);

    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);

    wrap.labSend(5, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());

    wrap.labReceive(5, 2, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 0);
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);


    wrap.labReceive(5, 3, false, plhs, 4);
    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    pData = reinterpret_cast<char*>(mxGetData(out));
    for (int i = 0; i < 10; i++) {
        EXPECT_EQ(test_mess[i], pData[i]);
    }
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], 3);


    //delete(plhs[(int)labReceive_Out::mess_contents]);
    //delete(plhs[(int)labReceive_Out::data_celarray]);
}

TEST(TestCPPCommunicator, receive_sequence_ignore_same_tag) {
    // when asynchronously receving list of the same tag non-data messages retain only the last one

    MPI_wrapper::MPI_wrapper_gtested = true;
    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 11;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    mxArray* plhs[4];

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());

    wrap.labReceive(5, 2, false, plhs, 4);
    // do send as the queue length is updated only at send
    wrap.labSend(4, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.async_queue_len());

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 10);
    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    auto pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], 2);

    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.async_queue_len());

    test_mess.assign(9, 2);
    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(3, wrap.async_queue_len());

    test_mess.assign(11, 3);
    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.async_queue_len());

    // drop all previous messages and receve only the last one
    wrap.labReceive(5, 2, false, plhs, 4);
    // do send as the queue length is updated only at send
    wrap.labSend(7, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.async_queue_len());
    //
    auto MessCache = wrap.get_async_queue();
    auto first = MessCache->begin();
    auto last = MessCache->rbegin();
    ASSERT_EQ(first->destination, 7);
    ASSERT_EQ(last->destination, 4);


    out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out), 1);
    ASSERT_EQ(mxGetN(out), 11);
    addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 2);
    pAddress = reinterpret_cast<int32_t*>(mxGetData(addrOut));
    ASSERT_EQ(pAddress[0], 5);
    ASSERT_EQ(pAddress[1], 2);
}

TEST(TestCPPCommunicator, clear_all) {
    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;

    init_par.debug_frmwk_param[0] = 1;
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    wrap.labSend(6, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.async_queue_len());

    wrap.clearAll();
    ASSERT_EQ(0, wrap.async_queue_len());

}
TEST(TestCPPCommunicator, MPI_wraper_ser_deser_info) {
    MPI_wrapper::MPI_wrapper_gtested = true;

    InitParamHolder init_par;
    init_par.is_tested = true;
    init_par.async_queue_length = 4;
    init_par.data_message_tag = 10;

    // labInd
    init_par.debug_frmwk_param[0] = 0;
    // numLabs
    init_par.debug_frmwk_param[1] = 10;


    auto wrap = MPI_wrapper();
    wrap.init(init_par);
    ASSERT_TRUE(wrap.isTested);

    std::vector<char> data_buf;
    wrap.pack_node_names_list(data_buf);

    auto wrap1 = MPI_wrapper();
    wrap1.isTested = true;
    wrap1.unpack_node_names_list(data_buf);
    for (int i = 0; i < 10; i++){
        EXPECT_EQ(wrap1.node_names[i], wrap.node_names[i]);
    }

}


int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

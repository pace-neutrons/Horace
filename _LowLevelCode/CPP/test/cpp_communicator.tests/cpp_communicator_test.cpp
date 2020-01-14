#include "cpp_communicator/MPI_wrapper.h"
#include "cpp_communicator/input_parser.h"
#include "cpp_communicator/cpp_communicator.h"
#include "utility/environment.h"

#include <gtest/gtest.h>

#include <vector>

using namespace Herbert::Utility;


TEST(TestCPPCommunicator, send_assynchroneous) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true,4,9);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(10,1,false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());
    // "Deliver" message
    auto queue = wrap.get_async_queue();
    queue->rbegin()->theRequest = (MPI_Request)1;

    test_mess.assign(10, 2);
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    // "Deliver" message
    queue->rbegin()->theRequest = 1;
    test_mess.assign(10, 3);
    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    // the previous message has been delivered.
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labSend(9, 2, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(2, wrap.assync_queue_len());

    wrap.labSend(8, 3, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(3, wrap.assync_queue_len());

    wrap.labSend(7, 4, false, &test_mess[0], test_mess.size());
    // the previous had not been delivered
    ASSERT_EQ(4, wrap.assync_queue_len());
    // queue full
    ASSERT_ANY_THROW(wrap.labSend(6, 1, false, &test_mess[0], test_mess.size()));

    // Mark all messages as delivered
    auto MessCache = wrap.get_async_queue();

    auto last = MessCache->rbegin();
    last->theRequest = 1; // mark last message delivered;
    wrap.labSend(5, 5, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.assync_queue_len());


    for (auto &it : *MessCache) {
        it.theRequest = (MPI_Request)1;
    }
    wrap.labSend(4, 6, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());
    auto it = MessCache->begin();
    ASSERT_EQ(it->destination, 4);
    ASSERT_EQ(it->mess_tag, 6);
}

TEST(TestCPPCommunicator, send_assynch_random_receive1) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 6, 9);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);
    for (int i = 1; i < 6; i++) {
        wrap.labSend(i, i, false, &test_mess[0], test_mess.size());

    }
    ASSERT_EQ(5, wrap.assync_queue_len());

    auto MessCache = wrap.get_async_queue();
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        if (it->mess_tag % 2 == 0) {
            it->theRequest = (MPI_Request)1; // "Receive" all even messages
        }
    }


    wrap.labSend(7, 7, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.assync_queue_len());
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        ASSERT_EQ(it->mess_tag % 2, 1);
    }

}
TEST(TestCPPCommunicator, send_assynch_random_receive2) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 6, 9);
    ASSERT_TRUE(wrap.isTested);

    EXPECT_EQ(MPI_wrapper::data_mess_tag, 9);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);
    for (int i = 1; i < 6; i++) {
        wrap.labSend(i, i, false, &test_mess[0], test_mess.size());

    }
    ASSERT_EQ(5, wrap.assync_queue_len());

    auto MessCache = wrap.get_async_queue();
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        if (it->mess_tag % 2 == 1) {
            it->theRequest = (MPI_Request)1; // "Receive" all odd messages
        }
    }


    wrap.labSend(6, 6, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(3, wrap.assync_queue_len());
    for (auto it = MessCache->begin(); it != MessCache->end(); it++) {
        ASSERT_EQ(it->mess_tag % 2, 0);
    }

}
TEST(TestCPPCommunicator, lab_probe_single) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    std::vector<int32_t> req_address(1,-1);
    std::vector<int32_t> req_tag(1,-1);
    std::vector<int32_t> got_address;
    std::vector<int32_t> got_tag;

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(),0);


    std::vector<uint8_t> test_mess(10,1);
    test_mess[0] = 0; // sent but not delivered

    wrap.labSend(10, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    req_address[0] = 9;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 10;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    req_address[0] = 10;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 10;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 10);
    ASSERT_EQ(got_tag[0], 1);

    //
    wrap.labSend(9, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(wrap.assync_queue_len(),2);

    // Mark last messages as delivered
    auto MessCache = wrap.get_async_queue();
    auto lastMess = MessCache->rbegin();
    lastMess->theRequest = 1;

    req_address[0] = -1;
    req_tag[0] = -1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 2);

    req_address[0] = 10;
    req_tag[0] = 1;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address.size(), 0);
    ASSERT_EQ(got_tag.size(), 0);

    req_address[0] = 9;
    req_tag[0] = 2;
    wrap.labProbe(req_address, req_tag, got_address, got_tag);
    ASSERT_EQ(got_address[0], 9);
    ASSERT_EQ(got_tag[0], 2);
}

TEST(TestCPPCommunicator, lab_probe_multi) {

    MPI_wrapper::MPI_wrapper_gtested = true;
    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    std::vector<int32_t> req_address(2, -1);
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
    ASSERT_EQ(2, wrap.assync_queue_len());

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

    auto wrap = MPI_wrapper();
    wrap.init(true, 4);
    ASSERT_TRUE(wrap.isTested);

    mxArray* plhs[5];
    wrap.labReceive(10, 1, false, plhs,5);

    auto out = plhs[(int)labReceive_Out::mess_contents];
    ASSERT_EQ(mxGetM(out),1);
    ASSERT_EQ(mxGetN(out), 0);

    auto addrOut = plhs[(int)labReceive_Out::real_source_address];
    ASSERT_EQ(mxGetM(addrOut), 1);
    ASSERT_EQ(mxGetN(addrOut), 0);


    ASSERT_ANY_THROW(wrap.labReceive(10, 1, true, plhs,5));

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    for (int i = 0; i < test_mess.size(); i++) {
        test_mess[i] = i;
    }

    wrap.labSend(10, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labReceive(-1, -1, false, plhs,5);

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
    ASSERT_EQ(1, wrap.assync_queue_len());

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

    auto wrap = MPI_wrapper();
    wrap.init(true, 4,10);
    ASSERT_TRUE(wrap.isTested);

    mxArray* plhs[4];

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

    wrap.labReceive(5, 2, false, plhs, 4);
    // do send as the queue length is updated only at send
    wrap.labSend(4, 1, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(1, wrap.assync_queue_len());

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
    ASSERT_EQ(2, wrap.assync_queue_len());

    test_mess.assign(9, 2);
    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(3, wrap.assync_queue_len());

    test_mess.assign(11, 3);
    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(4, wrap.assync_queue_len());

    // drop all previous messages and receve only the last one
    wrap.labReceive(5, 2, false, plhs, 4);
    // do send as the queue length is updated only at send
    wrap.labSend(7, 3, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.assync_queue_len());
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

    auto wrap = MPI_wrapper();
    wrap.init(true, 4, 10);
    ASSERT_TRUE(wrap.isTested);

    std::vector<uint8_t> test_mess;
    test_mess.assign(10, 1);

    wrap.labSend(5, 2, false, &test_mess[0], test_mess.size());
    wrap.labSend(6, 2, false, &test_mess[0], test_mess.size());
    ASSERT_EQ(2, wrap.assync_queue_len());

    wrap.clearAll();
    ASSERT_EQ(0, wrap.assync_queue_len());

}

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}

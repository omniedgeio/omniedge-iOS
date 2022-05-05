package io.omniedge.n2n.model;


public class EdgeStatus {
    public enum RunningStatus {
        CONNECTING,                     // Connecting to N2N network
        CONNECTED,                      // Connect to N2N network successfully
        SUPERNODE_DISCONNECT,           // Disconnect from the supernode
        DISCONNECT,                     // Disconnect from N2N network
        FAILED                          // Fail to connect to N2N network
    }

    public RunningStatus runningStatus;
}

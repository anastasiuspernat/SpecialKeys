
#define kDriverClassName		"ThinkpadHotkeyController"

// Data structure passed between the tool and the user client. This structure and its fields need to have
// the same size and alignment between the user client, 32-bit processes, and 64-bit processes.
// To avoid invisible compiler padding, align fields on 64-bit boundaries when possible
// and make the whole structure's size a multiple of 64 bits.

typedef struct MySampleStruct {
    uint64_t field1;	
    uint64_t field2;
} MySampleStruct;


// User client method dispatch selectors.
enum {
    kMyUserClientStartRecording,
    kMyUserClientStopRecording,   
	kMyUserUpdateKeys,
	kSetHotkeyPressedCallback,
	
    kMyScalarIStructIMethod,
    kMyScalarIStructOMethod,

	kClientTargetCount = kMyScalarIStructOMethod,
	
	kGetHotkeyMask,
	kSetHotkeyMask,
	
    kNumberOfMethods // Must be last 
};

typedef struct dataRefCon {
    char *       buffer;
} dataRefCon;



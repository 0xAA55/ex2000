%ifndef _TLS_INC_
%define _TLS_INC_ 1

%define TLS_CALLBACK_REASON_ON_INIT 'init'
%define TLS_CALLBACK_REASON_ON_FINI 'fini'

; DWORD TlsIndex;
extern _TlsIndex

; void TlsInit();
extern _TlsInit

; void TlsDeInit();
extern _TlsDeInit

; void TlsRegisterCallback(void (*TlsCallback)(int reason));
extern _TlsRegisterCallback

; void TlsInvokeCallbacks(int reason);
extern _TlsInvokeCallbacks

%endif

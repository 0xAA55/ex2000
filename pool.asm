%include "loaddll.inc"
%include "pool.inc"
%include "tls.inc"

struc Pool
	.cur_job_index resd 1
	.num_workers resd 1
	.num_jobs resd 1
	.work_proc resd 1
	.common_data resd 1
	.jobs resd 1
	.results resd 1
	.worker_handles resd 1
	.size equ $ - Pool
endstruc

DefFunc _WaitForAllMultipleObjects
	FrameBegin ebx, esi, edi
	NameParams %$NumObjects, %$Handles, %$Timeout
	DefVars %$TimeLow, %$TimeHigh

	mov ebx, %$NumObjects
	mov esi, %$Handles
	mov edi, %$Timeout
.loop_wait:
	invoke_dll_stdcall GetTickCount64
	mov %$TimeLow, eax
	mov %$TimeHigh, edx
	mov eax, 64
	cmp ebx, eax
	cmovb eax, ebx
	sub ebx, eax
	invoke_dll_stdcall WaitForMultipleObjects, eax, esi, 1, edi
	cmp eax, WAIT_TIMEOUT
	jnz .end
	invoke_dll_stdcall GetTickCount64
	sub eax, %$TimeLow
	sbb edx, %$TimeHigh
	cmp eax, edi
	jae .timeout_end
	sub edi, eax
	add esi, 64 * 4
	test ebx, ebx
	jnz .loop_wait
.timeout_end:
	mov eax, WAIT_TIMEOUT
.end:
	FrameEnd
	ret

DefFunc _PoolRun
	FrameBegin ebx, esi, edi
	NameParams %$WorkProc, %$CommonData, %$NumWorkers, %$NumJobs, %$JobList, %$StackSize, %$GrabResults

	invoke_cdecl _aligned_malloc, Pool.size, 32
	mov ebx, eax

	xor eax, eax
	mov edi, ebx
	mov ecx, Pool.size / 4
	rep stosd

	mov eax, %$NumWorkers
	mov ecx, %$NumJobs
	cmp eax, ecx
	cmova eax, ecx
	mov [ebx + Pool.num_workers], eax

	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + Pool.worker_handles], eax

	mov eax, %$NumJobs
	mov [ebx + Pool.num_jobs], eax

	cmp dword %$GrabResults, 0
	je .skip_grab_results
	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + Pool.results], eax
.skip_grab_results:

	mov eax, %$WorkProc
	mov ecx, %$CommonData
	mov edx, %$JobList
	mov [ebx + Pool.work_proc], eax
	mov [ebx + Pool.common_data], ecx
	mov [ebx + Pool.jobs], edx

	xor esi, esi
	mov edi, [ebx + Pool.worker_handles]
.start:
	invoke_dll_stdcall CreateThread, 0, %$StackSize, _PoolThreadProc@4, ebx, 0, 0
	lea edx, [edi + esi * 4]
	mov [edx], eax
	inc esi
	cmp esi, [ebx + Pool.num_workers]
	jb .start
.work:
	invoke_cdecl _WaitForAllMultipleObjects, [ebx + Pool.num_workers], [ebx + Pool.worker_handles], 0xFFFFFFFF
	cmp eax, WAIT_FAILED
	xor esi, esi
.loop_close_handles:
	invoke_dll_stdcall CloseHandle, [edi + esi * 4]
	inc esi
	cmp esi, [ebx + Pool.num_workers]
	jb .loop_close_handles
	jmp .end

.end:
	mov esi, [ebx + Pool.results]
	invoke_cdecl _free, [ebx + Pool.worker_handles]
	invoke_cdecl _aligned_free, ebx
	mov eax, esi
	FrameEnd
	ret

DefFunc _PoolThreadProc@4
	FrameBegin ebx, esi, edi
	NameParams %$PoolStatus
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_INIT
	mov ebx, %$PoolStatus
	mov edi, [ebx + Pool.results]
.find_next_job:
	invoke_dll_stdcall InterlockedIncrement, &[ebx + Pool.cur_job_index]
	lea esi, [eax - 1]
	cmp esi, [ebx + Pool.num_jobs]
	jae .quit
	mov eax, [ebx + Pool.jobs]
	test eax, eax
	jz .no_job_param
	mov eax, [eax + esi * 4]
.no_job_param:
	invoke_cdecl [ebx + Pool.work_proc], eax, [ebx + Pool.common_data], esi
	test edi, edi
	jz .find_next_job
	lea edx, [esi * 4]
	add edx, edi
	mov [edx], eax ; Here stores the return value of `work_proc()`
	jmp .find_next_job
.quit:
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_FINI
	xor eax, eax
	FrameEnd
	ret 4

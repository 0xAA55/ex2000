%include "loaddll.inc"
%include "pool.inc"
%include "tls.inc"

struc Pool
	.cur_job_index resd 1
	.num_workers resd 1
	.num_jobs resd 1
	.work_proc resd 1
	.jobs resd 1
	.results resd 1
	.worker_handles resd 1
	.size equ $ - Pool
endstruc

DefFunc _PoolRun
	FrameBegin 0, 2, ebx, esi, edi

	invoke_cdecl _aligned_malloc, Pool.size, 32
	mov ebx, eax

	xor eax, eax
	mov edi, ebx
	mov ecx, Pool.size / 4
	rep stosd

	mov eax, Param(1) ;num_workers
	mov ecx, Param(2) ;num_jobs
	cmp eax, ecx
	cmova eax, ecx
	mov [ebx + Pool.num_workers], eax

	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + Pool.worker_handles], eax

	mov eax, Param(2) ;num_jobs
	mov [ebx + Pool.num_jobs], eax

	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + Pool.results], eax

	mov eax, Param(0)
	mov ecx, Param(3)
	mov [ebx + Pool.work_proc], eax
	mov [ebx + Pool.jobs], ecx

	xor esi, esi
	mov edi, [ebx + Pool.worker_handles]
.start:
	invoke_dll_stdcall CreateThread, 0, Param(4), _PoolThreadProc, ebx, 0, 0
	test eax, eax
	jz .fail
	lea edx, [edi + esi * 4]
	mov [edx], eax
	inc esi
	cmp esi, [ebx + Pool.num_workers]
	jb .start
.work:
	invoke_dll_stdcall WaitForMultipleObjects, [ebx + Pool.num_workers], [ebx + Pool.worker_handles], 1, 0xFFFFFFFF
	cmp eax, [ebx + Pool.num_workers]
	jae .fail
	xor esi, esi
.loop_close_handles:
	invoke_dll_stdcall CloseHandle, [edi + esi * 4]
	inc esi
	cmp esi, [ebx + Pool.num_workers]
	jb .loop_close_handles
	jmp .end
.wrong_call:
.fail:
	int3
	jmp .wrong_call

.end:
	mov esi, [ebx + Pool.results]
	invoke_cdecl _free, [ebx + Pool.worker_handles]
	invoke_cdecl _aligned_free, ebx
	mov eax, esi
	FrameEnd
	ret

DefFunc _PoolThreadProc
	FrameBegin 0, 2, ebx, esi
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_INIT
	mov ebx, Param(0)
.find_next_job:
	invoke_dll_stdcall InterlockedIncrement, &[ebx + Pool.cur_job_index]
	lea esi, [eax - 1]
	cmp esi, [ebx + Pool.num_jobs]
	jae .quit
	lea eax, [esi * 4]
	add eax, [ebx + Pool.jobs]
	invoke_cdecl [ebx + Pool.work_proc], [eax], esi
	lea edx, [esi * 4]
	add edx, [ebx + Pool.results]
	mov [edx], eax ; Here stores the return value of `work_proc()`
	jmp .find_next_job
.quit:
	invoke_cdecl _TlsInvokeCallbacks, TLS_CALLBACK_REASON_ON_FINI
	xor eax, eax
	FrameEnd
	ret 4

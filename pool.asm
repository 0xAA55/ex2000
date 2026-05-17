%include "pool.inc"

%define STILL_ACTIVE 259

extern _calloc
extern _malloc
extern _realloc
extern _free

import_dll_func CreateThread
import_dll_func CloseHandle
import_dll_func WaitForMultipleObjects

segment .text
DefFunc _PoolRun
	FrameBegin 2, 2, ebx, esi, edi
	AssignVars _NUM_WORKERS, _JOBS_TODO

	invoke_cdecl _calloc, 1, Pool.size
	mov ebx, eax
	test eax, eax
	jz .end

	mov eax, Param(1)
	cmp eax, 64
	ja .wrong_call
	mov [ebx + Pool.num_workers], eax

	invoke_cdecl _malloc, &[eax * 4]
	mov [ebx + Pool.workers], eax
	test eax, eax
	jz .end

	mov eax, Param(2)
	invoke_cdecl _malloc, &[eax * 8]
	mov [ebx + Pool.worker_params], eax
	test eax, eax
	jz .end

	mov eax, Param(2)
	invoke_cdecl _calloc, 4, eax
	mov [ebx + Pool.results], eax
	test eax, eax
	jz .end

	mov eax, Param(0)
	mov ecx, Param(3)
	mov [ebx + Pool.work_proc], eax
	mov [ebx + Pool.jobs], ecx

	mov eax, Param(2)
	mov ecx, Param(1)
	sub eax, ecx
	mov _NUM_WORKERS, ecx
	jae .jobs_ae_workers
	mov eax, Param(2)
	mov _NUM_WORKERS, eax
	xor eax, eax
.jobs_ae_workers:
	mov _JOBS_TODO, eax
	mov eax, [ebx + Pool.worker_params]
	xor edx, edx
	mov esi, edx
	mov edi, eax
	mov ecx, Param(2)
.fill_params:
	mov [eax], ebx
	mov [eax + 4], edx
	inc edx
	add eax, 8
	loop .fill_params
.kick_start:
	invoke_dll_stdcall CreateThread, 0, Param(4), _PoolThreadProc, &[edi + esi * 8], 0, 0
	lea edx, [esi * 4]
	add edx, [ebx + Pool.workers]
	mov [edx], eax
	inc esi
	cmp esi, _NUM_WORKERS
	jb .kick_start
.work:
	invoke_dll_stdcall WaitForMultipleObjects, _NUM_WORKERS, [ebx + Pool.workers], 0, 0xFFFFFFFF
	cmp eax, 64
	jae .fail
	mov edi, eax
	mov edx, [ebx + Pool.workers]
	invoke_dll_stdcall CloseHandle, [eax * 4 + edx]
	cmp esi, Param(2)
	jb .more_jobs
	lea eax, [edi * 4]
	add eax, [ebx + Pool.workers]
	mov ecx, _NUM_WORKERS
	dec ecx
	jz .end
	mov _NUM_WORKERS, ecx
	lea ecx, [ecx * 4]
	add ecx, [ebx + Pool.workers]
	mov edx, [ecx]
	mov [eax], edx
	jmp .work
.more_jobs:
	mov eax, [ebx + Pool.worker_params]
	invoke_dll_stdcall CreateThread, 0, Param(4), _PoolThreadProc, &[eax + esi * 8], 0, 0
	lea ecx, [edi * 4]
	add ecx, [ebx + Pool.workers]
	mov [ecx], eax
	inc esi
	jmp .work
.wrong_call:
.fail:
	int3
	jmp .wrong_call

.end:
	mov esi, [ebx + Pool.results]
	invoke_cdecl _free, [ebx + Pool.worker_params]
	invoke_cdecl _free, [ebx + Pool.workers]
	invoke_cdecl _free, ebx
	mov eax, esi
	FrameEnd
	ret
	%undef _NUM_WORKERS
	%undef _JOBS_TODO

DefFunc _PoolThreadProc
	FrameBegin 0, 2, ebx, esi
	mov eax, Param(0)
	mov ebx, [eax]
	mov esi, [eax + 4]
	lea eax, [esi * 4]
	add eax, [ebx + Pool.jobs]
	invoke_cdecl [ebx + Pool.work_proc], [eax], esi
	lea esi, [esi * 4]
	add esi, [ebx + Pool.results]
	mov [esi], eax
	xor eax, eax
	FrameEnd
	ret 4

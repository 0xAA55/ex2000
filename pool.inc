%ifndef _POOL_INC_
%define _POOL_INC_ 1

%include "loaddll.inc"

struc Pool
.work_proc resd 1
.num_workers resd 1
.workers resd 1
.worker_params resd 1
.jobs resd 1
.results resd 1
.size equ $ - Pool
endstruc


%ifndef POOL_ASM
; void* PoolRun(int(*work_proc)(void *param), int num_workers, int num_jobs, void* job_list, int stack_size);
; // Returns a pointer to the newly allocated array containing the results from `work_proc`.
; // The caller is responsible for freeing this memory with `free()`.
extern _PoolRun
%endif

%endif


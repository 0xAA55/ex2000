%ifndef _POOL_INC_
%define _POOL_INC_ 1

; void* PoolRun(int(*work_proc)(void *param, size_t index), int num_workers, int num_jobs, void* job_list, int stack_size);
; // Returns a pointer to the newly allocated array containing the results from `work_proc`.
; // The caller is responsible for freeing this memory with `free()`.
extern _PoolRun

%endif


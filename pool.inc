%ifndef _POOL_INC_
%define _POOL_INC_ 1

;/**
; * @brief Executes a batch of jobs using a simple thread pool.
; *
; * This function creates a pool of worker threads to process a set of jobs
; * concurrently. It manages thread creation, task distribution, and
; * synchronization internally.
; *
; * @param work_proc     Pointer to the worker function executed by each thread.
; *                     Signature: void* work_proc(void* param, void* common_data, size_t index).
; *                     - `param`: The specific job parameter from `job_list`.
; *                     - `common_data`: Shared data passed to all threads.
; *                     - `index`: The zero-based index of the current job.
; * @param common_data   A pointer to data shared among all worker threads.
; *                     This is passed as the second argument to `work_proc`.
; *                     Can be NULL if no shared data is required.
; * @param num_workers   The requested number of worker threads. The actual number
; *                     of threads created is limited to `min(num_workers, num_jobs)`.
; * @param num_jobs      The total number of jobs to execute.
; * @param job_list      An array of `void*` pointers representing individual job
; *                     parameters. Each element is passed as the first argument
; *                     to `work_proc`. If this is NULL, NULL is passed as the
; *                     first argument to `work_proc` for every job.
; * @param stack_size    The stack size for each created thread, passed directly
; *                     to the WinAPI `CreateThread()` function. Use 0 for the
; *                     default stack size.
; * @param grab_results  If non-zero, collects return values of `work_proc` into a
; *                     heap-allocated array. If `work_proc` returns pointers to
; *                     allocated resources, the caller must free those resources
; *                     before freeing the array itself via `free()`. If
; *                     `grab_results` is zero, the function returns NULL.
; *
; * @return void**       If `grab_results` is non-zero, returns a heap-allocated
; *                     array of `void*` containing the return values of
; *                     `work_proc` for each job (size == num_jobs).
; *                     If `grab_results` is zero, returns NULL.
; *
; * @note Thread Limit & Synchronization:
; *       If the actual number of worker threads exceeds 64 (the limit for
; *       `WaitForMultipleObjects`), the internal waiting logic degrades from
; *       efficient object waiting to polling via `Sleep(10)`. This may impact
; *       performance and responsiveness.
; *
; * @warning If `grab_results` is non-zero, the returned array must be freed with
; *          `free()`. Note that if the array elements point to dynamically
; *          allocated resources, those must be cleaned up by the caller prior
; *          to freeing the array.
; */
;void** PoolRun(
;	void*(*work_proc)(void *param, void *common_data, size_t index),
;	void *common_data,
;	int num_workers,
;	int num_jobs,
;	void **job_list,
;	int stack_size,
;	int grab_results
;);
extern _PoolRun

%endif


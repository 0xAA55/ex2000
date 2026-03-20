%ifndef _RAII_INC_
%define _RAII_INC_ 1

%include "frame.inc"
%include "loaddll.inc"

%macro DefObjectType 2
	%ifndef SIZE_OF_ %+ %1
		%assign SIZE_OF_ %+ %1 %2
	%else
		%if SIZE_OF_ %+ %1 != %2
			%error Object type redefined
		%endif
	%endif
%endmacro

%macro DefConstructor 1
	%ifdef DEFINED_CNST_ %+ %1
		%error Constructor symbol already exists
	%endif
	%define DEFINED_CNST_ %+ %1
	segment .text
	global _ConstructorOf_ %+ %1
	_ConstructorOf_ %+ %1:
%endmacro

%macro DefDestructor 1
	%ifdef DEFINED_DEST_ %+ %1
		%error Destructor symbol already exists
	%endif
	%define DEFINED_DEST_ %+ %1
	segment .text
	global _DestructorOf_ %+ %1
	_DestructorOf_ %+ %1:
%endmacro

%macro ImportConstructor 1
	%ifndef DEFINED_CNST_ %+ %1
		%define DEFINED_CNST_ %+ %1
		extern _ConstructorOf_ %+ %1
	%endif
%endmacro

%macro ImportDestructor 1
	%ifndef DEFINED_DEST_ %+ %1
		%define DEFINED_DEST_ %+ %1
		extern _DestructorOf_ %+ %1
	%endif
%endmacro

%macro OnConstruct 2
	ImportConstructor %1
	PrepParam 0, %2
	call _ConstructorOf_ %+ %1
%endmacro

%macro OnDestruct 2
	ImportDestructor %1
	PrepParam 0, %2
	call _DestructorOf_ %+ %1
%endmacro

%endif

%include "common.inc"

DefFunc _SmootherStep
	FrameBegin 0

	fld dword Param(0)
	fimul word [_W6]
	fisub word [_W15]
	fmul dword Param(0)
	fiadd word [_W10]
	fmul dword Param(0)
	fmul dword Param(0)
	fmul dword Param(0)

	FrameEnd
	ret

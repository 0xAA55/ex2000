%include "common.inc"
%include "avlbst.inc"

; typedef struct CurvePoints_s
; {
; 	float volume;
; 	float weight;
; } CurvePoints_t, *CurvePoints_p;
;float curve(float value, CurvePoints_p curve, size_t num_curve_points)
;{
;	// data: {volume, weight}
;	// {
;	// 	{0.6f, 0.2f},
;	// 	{0.2f, 0.6f},
;	// 	{0.2f, 0.2f},
;	// }
;	float ret = 0.0f;
;	float weight_sum_rcp = 0.0f;
;	for (size_t i = 0; i < num_curve_points; i++) weight_sum_rcp += cur_point->weight;
;	weight_sum_rcp = 1.0f / weight_sum_rcp;
;
;	for (size_t i = 0; i < num_curve_points; i++)
;	{
;		CurvePoints_p cur_point = &curve[i];
;		float weight = cur_point->weight * weight_sum_rcp;
;		if (value > weight)
;			ret += cur_point->volume;
;		else if (value > 0.0f)
;			ret += value * cur_point->volume / weight;
;		value -= weight;
;	}
;
;	return ret;
;}
; void BatchCurve(float *data, size_t num_data, CurvePoints_p curve, size_t num_curve_points)
;{
;	for (size_t i = 0; i < num_data; i++)
;	{
;		data[i] = curve(data[i], curve, num_curve_points);
;	}
;}

DefFunc _BatchCurve
	FrameBegin 1, 0, ebx, esi, edi
	AssignVars DATA_TO_PROC

	mov edi, Param(0)
	mov eax, Param(1)
	mov esi, Param(2)
	xorps xmm5, xmm5
	xor edx, edx
	mov ecx, Param(3)
.sum_weights:
	addss xmm5, [esi + edx + CurvePoint.weight]
	add edx, 8
	loop .sum_weights
	shufps xmm5, xmm5, 0
	rcpps xmm5, xmm5
	mov DATA_TO_PROC, eax
	xorps xmm4, xmm4
.main_loop:
	test eax, eax
	jz .end
	mov ebx, eax
	test eax, 3
	jz .vector_process
	and ebx, 3
	sub eax, ebx
.scalar_process_loop:
	xorps xmm0, xmm0
	movss xmm1, [edi]
	xor edx, edx
	mov ecx, Param(3)
.loop_curve:
	movss xmm6, [esi + edx + CurvePoint.volume] ;volume
	movss xmm7, [esi + edx + CurvePoint.weight] ;weight
	mulss xmm7, xmm5 ;normalize weight
	movss xmm2, xmm1 ;temp_value_1
	movss xmm3, xmm1 ;temp_value_2
	xorps xmm4, xmm4
	cmpss xmm2, xmm7, _MM_LE_
	cmpss xmm3, xmm7, _MM_GT_
	cmpss xmm4, xmm1, _MM_LT_ ; 0 < value ?
	andps xmm2, xmm1 ;temp_value_1 = (value <= weight) ? value : 0.0f;
	andps xmm3, xmm6 ;temp_value_2 = (value > weight) ? volume : 0.0f;
	mulss xmm2, xmm6 ;temp_value_1 *= volume;
	divss xmm2, xmm7 ;temp_value_1 /= weight;
	andps xmm2, xmm4 ;temp_value_1 = (value > 0) ? temp_value_1 : 0.0f;
	subss xmm1, xmm7 ;value -= weight;
	addss xmm0, xmm2 ;ret += temp_value_1;
	addss xmm0, xmm3 ;ret += temp_value_2;
	add edx, 8
	loop .loop_curve
	movss [edi], xmm0 ;data = ret;
	add edi, 4
	dec ebx
	jnz .scalar_process_loop
	jmp .main_loop
.vector_process:
	shr ebx, 2
.vector_process_loop:
	xorps xmm0, xmm0 ;ret
	movups xmm1, [edi + 0x00] ;value
	xor edx, edx
	mov ecx, Param(3)
.loop_curve_2:
	movss xmm6, [esi + edx + CurvePoint.volume] ;volume
	movss xmm7, [esi + edx + CurvePoint.weight] ;weight
	shufps xmm6, xmm6, 0
	shufps xmm7, xmm7, 0
	mulps xmm7, xmm5 ;normalize weight
	movaps xmm2, xmm1 ;temp_value_1
	movaps xmm3, xmm1 ;temp_value_2
	xorps xmm4, xmm4
	cmpps xmm2, xmm7, _MM_LE_
	cmpps xmm3, xmm7, _MM_GT_
	cmpps xmm4, xmm1, _MM_LT_ ; 0 < value ?
	andps xmm2, xmm1 ;temp_value_1 = (value <= weight) ? value : 0.0f;
	andps xmm3, xmm6 ;temp_value_2 = (value > weight) ? volume : 0.0f;
	mulps xmm2, xmm6 ;temp_value_1 *= volume;
	divps xmm2, xmm7 ;temp_value_1 /= cur_point->weight;
	andps xmm2, xmm4 ;temp_value_1 = (value > 0) ? temp_value_1 : 0.0f;
	subps xmm1, xmm7 ;value -= weight;
	addps xmm0, xmm2 ;ret += temp_value_1;
	addps xmm0, xmm3 ;ret += temp_value_2;
	add edx, 8
	loop .loop_curve_2
	movups [edi + 0x00], xmm0 ;data = ret;
	add edi, 0x10
	dec ebx
	jnz .vector_process_loop

.end:
	FrameEnd
	ret

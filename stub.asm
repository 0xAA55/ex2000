bits 16

entry:
	.signature	db "MZ"
	.exsize		dw (.end - entry) % 512
	.pages		dw (.end - entry) / 512
	.num_relocs	dw 0
	.hdrsize	dw (.exeh_end - entry - 1) / 16 + 1
	.minmem		dw 0
	.maxmem		dw 0xFFFF
	.init_ss	dw 0
	.init_sp	dw 0xB8
	.checksum	dw 0
	.init_ip	dw .inst_start - entry
	.init_cs	dw 0
	.reloc_addr	dw .full_exeh_end - entry
	.overlay	dw 0
	.exeh_end:
	times 0x3C - (.exeh_end - entry) db 0
	.PE_pos		dd .end - entry
	.full_exeh_end:
	.inst_start:
		int 0x20
	.end:

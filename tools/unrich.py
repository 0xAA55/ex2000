import sys
import struct

def remove_rich_and_fix_entry(path):
	with open(path, "rb+") as f:
		data = bytearray(f.read())

		if data[:2] != b"MZ":
			raise ValueError("不是 MZ EXE")

		e_lfanew = struct.unpack_from("<I", data, 0x3C)[0]
		pe_offset = e_lfanew

		# 找 Rich 头
		rich_pos = -1
		for i in range(0x40, pe_offset - 4):
			if data[i:i+4] == b"Rich":
				rich_pos = i
				break

		if rich_pos == -1:
			print("没得 Rich 头，不用动")
			return

		rich_start = rich_pos - 8
		if rich_start < 0x40:
			rich_start = 0x40

		rich_size = pe_offset - rich_start

		# --- 修复 PE 头里的 RVA ---
		opt_hdr_off = pe_offset + 24
		magic = struct.unpack_from("<H", data, opt_hdr_off)[0]

		if magic == 0x10B:  # PE32
			entry_off = opt_hdr_off + 16
			base_code = opt_hdr_off + 20
			base_data = opt_hdr_off + 24
			img_size_off = opt_hdr_off + 56
			hdr_size_off = opt_hdr_off + 60
		else:
			raise ValueError("只支持 x86 PE32")

		entry_rva = struct.unpack_from("<I", data, entry_off)[0]
		base_code_rva = struct.unpack_from("<I", data, base_code)[0]
		base_data_rva = struct.unpack_from("<I", data, base_data)[0]

		struct.pack_into("<I", data, entry_off, entry_rva - rich_size)
		struct.pack_into("<I", data, base_code, base_code_rva - rich_size)
		struct.pack_into("<I", data, base_data, base_data_rva - rich_size)

		# --- 修复节表 RVA ---
		file_hdr_off = pe_offset + 4
		num_sections = struct.unpack_from("<H", data, file_hdr_off + 2)[0]
		sect_tbl_off = opt_hdr_off + struct.unpack_from("<H", data, opt_hdr_off + 16)[0]

		for i in range(num_sections):
			s = sect_tbl_off + i * 40
			virt_addr = struct.unpack_from("<I", data, s + 12)[0]
			struct.pack_into("<I", data, s + 12, virt_addr - rich_size)

		# --- 修复 SizeOfImage / SizeOfHeaders ---
		size_of_image = struct.unpack_from("<I", data, img_size_off)[0]
		struct.pack_into("<I", data, img_size_off, size_of_image - rich_size)

		size_of_headers = struct.unpack_from("<I", data, hdr_size_off)[0]
		struct.pack_into("<I", data, hdr_size_off, size_of_headers - rich_size)

		# --- 移动 PE 头及后面所有内容 ---
		data[rich_start:] = data[pe_offset:]
		struct.pack_into("<I", data, 0x3C, pe_offset - rich_size)

		# --- 截断文件 ---
		del data[rich_start + len(data) - rich_size:]

		f.seek(0)
		f.truncate()
		f.write(data)

	print(f"Rich 头已铲除，EntryPoint / 节表 / ImageSize 全部同步修正")

if __name__ == "__main__":
	if len(sys.argv) != 2:
		print("用法: python unrich.py your.exe")
	else:
		remove_rich_and_fix_entry(sys.argv[1])
